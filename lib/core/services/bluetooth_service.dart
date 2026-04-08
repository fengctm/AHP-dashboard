import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../parsers/yuanqu_ble_parser.dart';
import '../utils/logging_service.dart';
import '../../domain/models/ble_packet.dart';

/// 蓝牙连接状态（自定义，不与flutter_blue_plus冲突）
enum BleConnectionState {
  disconnected,   // 未连接
  scanning,       // 扫描中
  connecting,     // 连接中
  connected,      // 已连接
  disconnecting,  // 断开中
  error,          // 错误
}

/// 远驱控制器蓝牙服务
///
/// 提供蓝牙扫描、连接、数据接收和解析功能
class YuanquBluetoothService {
  // 单例模式
  static final YuanquBluetoothService _instance =
      YuanquBluetoothService._internal();
  factory YuanquBluetoothService() => _instance;
  YuanquBluetoothService._internal();

  // 状态流控制器
  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  final _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  final _dataController =
      StreamController<YuanquDeviceData>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // 内部状态
  BleConnectionState _currentState = BleConnectionState.disconnected;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _dataSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  Timer? _validationTimer; // 数据验证定时器
  bool _hasReceivedValidData = false; // 是否收到过有效数据

  // 远驱控制器的特征UUID
  // 远驱控制器常用的UUID配置
  static const String serviceUuid = '0000fff0-0000-1000-8000-00805f9b34fb';
  static const String notifyCharacteristicUuid =
      '0000fff4-0000-1000-8000-00805f9b34fb'; // 通知特征
  static const String writeCharacteristicUuid =
      '0000fff3-0000-1000-8000-00805f9b34fb'; // 写特征（如果需要）

  // 设备名称过滤（用于识别远驱控制器）
  static const List<String> deviceNameFilters = [
    '远驱',
    'YuanQu',
    'YUANQU',
    'yuanqu',
    'Controller',
    'controller',
    'BLE',
    'ble',
  ];

  // ========== 公开流 ==========

  /// 连接状态流
  Stream<BleConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// 当前连接状态
  BleConnectionState get currentState => _currentState;

  /// 扫描结果流
  Stream<List<ScanResult>> get scanResultsStream =>
      _scanResultsController.stream;

  /// 解析后的数据流
  Stream<YuanquDeviceData> get dataStream => _dataController.stream;

  /// 错误流
  Stream<String> get errorStream => _errorController.stream;

  /// 是否已连接
  bool get isConnected => _currentState == BleConnectionState.connected;

  /// 已连接的设备
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // ========== 蓝牙初始化 ==========

  /// 初始化蓝牙
  Future<bool> initialize() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        _errorController.add('此设备不支持蓝牙');
        return false;
      }

      // 检查并监听蓝牙适配器状态
      await _setupAdapterStateListener();

      // 检查蓝牙是否开启
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        _errorController.add('请开启蓝牙');
        return false;
      }

      _updateState(BleConnectionState.disconnected);
      return true;
    } catch (e) {
      _errorController.add('蓝牙初始化失败: $e');
      _updateState(BleConnectionState.error);
      return false;
    }
  }

  /// 设置蓝牙适配器状态监听
  Future<void> _setupAdapterStateListener() async {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        if (_currentState == BleConnectionState.error) {
          _updateState(BleConnectionState.disconnected);
        }
      } else {
        // 蓝牙关闭时清理连接
        if (_connectedDevice != null) {
          _handleDisconnection();
        }
        _errorController.add('蓝牙已关闭');
        _updateState(BleConnectionState.disconnected);
      }
    });
  }

  // ========== 扫描设备 ==========

  /// 开始扫描设备
  ///
  /// [duration] - 扫描时长（秒），默认10秒
  /// [timeout] - 扫描超时（秒），默认30秒
  Future<void> startScan({int duration = 10, int timeout = 30}) async {
    try {
      if (_currentState == BleConnectionState.scanning) {
        return;
      }

      // 检查蓝牙是否开启
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        _errorController.add('蓝牙未开启，请先开启蓝牙');
        return;
      }

      _updateState(BleConnectionState.scanning);

      // 开始扫描
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: duration),
      );

      // 监听扫描结果
      StreamSubscription<List<ScanResult>>? scanSubscription;
      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        // 只显示可能是远驱控制器的设备
        final filteredResults = results.where((result) {
          return _isYuanquDevice(result);
        }).toList();

        // 排序：远驱相关设备优先，有名称的优先
        filteredResults.sort((a, b) {
          final aName = a.device.platformName.toLowerCase();
          final bName = b.device.platformName.toLowerCase();

          // 检查是否是远驱设备
          bool aIsYuanqu = _isYuanquDevice(a);
          bool bIsYuanqu = _isYuanquDevice(b);

          if (aIsYuanqu && !bIsYuanqu) return -1;
          if (!aIsYuanqu && bIsYuanqu) return 1;

          // 有名称的排前面
          if (aName.isEmpty && bName.isNotEmpty) return 1;
          if (aName.isNotEmpty && bName.isEmpty) return -1;

          return 0;
        });

        _scanResultsController.add(filteredResults);
      });

      // 扫描超时后停止
      Future.delayed(Duration(seconds: timeout), () {
        scanSubscription?.cancel();
        if (_currentState == BleConnectionState.scanning) {
          stopScan();
        }
      });
    } catch (e) {
      _errorController.add('扫描失败: $e');
      _updateState(BleConnectionState.error);
    }
  }

  /// 判断是否是远驱控制器设备
  bool _isYuanquDevice(ScanResult result) {
    final name = result.device.platformName.toLowerCase();

    // 检查设备名称
    for (final filter in deviceNameFilters) {
      if (name.contains(filter.toLowerCase())) {
        return true;
      }
    }

    // 如果没有名称，也显示在列表中（可能是未命名的远驱设备）
    if (name.isEmpty) {
      return true;
    }

    return false;
  }

  /// 停止扫描
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      if (_currentState == BleConnectionState.scanning) {
        _updateState(BleConnectionState.disconnected);
      }
    } catch (e) {
      _errorController.add('停止扫描失败: $e');
    }
  }

  // ========== 连接设备 ==========

  /// 连接到设备
  Future<bool> connect(BluetoothDevice device) async {
    try {
      if (_currentState == BleConnectionState.connected) {
        await disconnect();
      }

      _updateState(BleConnectionState.connecting);
      _connectedDevice = device;

      _errorController.add('正在连接到 ${device.platformName}...');
      logger.info('开始连接设备: ${device.platformName} (${device.remoteId})');

      // 连接设备
      await device.connect(
        timeout: const Duration(seconds: 30),
      );

      _errorController.add('连接成功，正在发现服务...');

      // 等待连接成功
      await device.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .first
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('连接超时');
            },
          );

      // 发现服务
      _errorController.add('正在发现服务...');
      final services = await device.discoverServices().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('服务发现超时');
        },
      );

      BluetoothCharacteristic? targetCharacteristic;

      // 尝试多种方式查找特征
      for (var service in services) {
        logger.debug('Service: ${service.uuid}');
        for (var c in service.characteristics) {
          logger.debug('  Characteristic: ${c.uuid}, properties: ${c.properties}');
        }

        // 按服务UUID匹配
        if (service.uuid.toString().toLowerCase().replaceAll('-', '') ==
            serviceUuid.toLowerCase().replaceAll('-', '')) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase().replaceAll('-', '') ==
                notifyCharacteristicUuid.toLowerCase().replaceAll('-', '')) {
              targetCharacteristic = characteristic;
              break;
            }
          }
        }

        // 如果没找到，尝试查找任何有notify属性的特征
        if (targetCharacteristic == null) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.notify ||
                characteristic.properties.indicate) {
              targetCharacteristic = characteristic;
              logger.debug('使用备用特征: ${characteristic.uuid}');
              break;
            }
          }
        }

        if (targetCharacteristic != null) break;
      }

      if (targetCharacteristic == null) {
        _errorController.add('未找到可用的数据特征，请确认设备兼容');
        await disconnect();
        return false;
      }

      // 订阅特征通知
      _errorController.add('正在订阅数据...');
      await targetCharacteristic.setNotifyValue(true);

      // 重置验证状态
      _hasReceivedValidData = false;

      // 监听数据
      _dataSubscription = targetCharacteristic.onValueReceived.listen((data) {
        _handleIncomingData(Uint8List.fromList(data));
      });

      // 监听连接状态变化
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      _errorController.add('连接成功！正在验证设备数据...');

      // 启动数据验证定时器（30秒内必须收到有效数据）
      _validationTimer = Timer(const Duration(seconds: 30), () {
        if (!_hasReceivedValidData) {
          logger.warning('30秒内未收到有效数据，断开连接');
          _errorController.add('设备验证失败：未收到远驱控制器数据');
          disconnect();
        }
      });

      logger.info('开始验证设备数据，30秒内必须收到有效数据');

      _updateState(BleConnectionState.connected);
      return true;
    } catch (e) {
      _errorController.add('连接失败: $e');
      _updateState(BleConnectionState.error);
      _connectedDevice = null;
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    try {
      _updateState(BleConnectionState.disconnecting);
      _errorController.add('正在断开连接...');

      // 取消验证定时器
      _validationTimer?.cancel();
      _validationTimer = null;
      _hasReceivedValidData = false;

      await _dataSubscription?.cancel();
      _dataSubscription = null;

      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = null;

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
      }

      _updateState(BleConnectionState.disconnected);
      _errorController.add('已断开连接');
    } catch (e) {
      _errorController.add('断开连接失败: $e');
      _updateState(BleConnectionState.error);
    }
  }

  // ========== 数据处理 ==========

  /// 处理接收到的数据
  void _handleIncomingData(Uint8List data) {
    try {
      final hex = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      logger.debug('收到数据: $hex (${data.length}字节)');

      // 验证数据包
      if (data.length < 16) {
        logger.warning('数据包长度不足: ${data.length}字节');
        return;
      }

      if (data[0] != 0xAA) {
        logger.warning('数据包起始字节不正确: 0x${data[0].toRadixString(16)}');
        return;
      }

      // 解析数据包
      final parsed = YuanquBleParser.parsePacket(data);

      if (parsed != null && parsed.isNotEmpty) {
        // 收到有效数据！
        if (!_hasReceivedValidData) {
          _hasReceivedValidData = true;
          _validationTimer?.cancel();
          _validationTimer = null;
          _errorController.add('设备验证成功！正在接收实时数据...');
          logger.info('设备验证成功！开始接收实时数据');
        }

        // 转换为设备数据
        final deviceData = YuanquDeviceData.fromParsedData(parsed);
        logger.info('解析成功: ${deviceData.controller}');

        // 发送到数据流
        if (!(_dataController.isClosed)) {
          _dataController.add(deviceData);
        }
      } else {
        logger.warning('解析失败: 数据包格式不正确');
      }
    } catch (e) {
      _errorController.add('解析数据失败: $e');
      logger.error('解析数据失败: $e');
    }
  }

  /// 处理意外断开
  void _handleDisconnection() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _connectedDevice = null;
    _updateState(BleConnectionState.disconnected);
    _errorController.add('设备已断开连接');
  }

  // ========== 辅助方法 ==========

  /// 更新连接状态
  void _updateState(BleConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      if (!(_connectionStateController.isClosed)) {
        _connectionStateController.add(newState);
      }
      logger.info('蓝牙状态: $newState');
    }
  }

  /// 从hex字符串模拟接收数据（用于测试）
  void simulateDataFromHex(String hexString) {
    try {
      logger.info('模拟数据: $hexString');
      final parsed = YuanquBleParser.parseFromHex(hexString);
      if (parsed != null) {
        final deviceData = YuanquDeviceData.fromParsedData(parsed);
        if (!(_dataController.isClosed)) {
          _dataController.add(deviceData);
        }
      }
    } catch (e) {
      _errorController.add('模拟数据解析失败: $e');
      logger.error('模拟数据解析失败: $e');
    }
  }

  // ========== 资源释放 ==========

  /// 释放资源
  void dispose() {
    _dataSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _connectionStateController.close();
    _scanResultsController.close();
    _dataController.close();
    _errorController.close();
  }
}
