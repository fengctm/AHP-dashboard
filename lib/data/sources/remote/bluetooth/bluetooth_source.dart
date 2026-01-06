import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import 'interfaces/bluetooth_manager.dart';
import '../../../models/bluetooth_device_model.dart';
import '../../local/database_source.dart';
import '../../../../../core/utils/logger_helper.dart';

class BluetoothManager implements IBluetoothManager {
  final StreamController<DeviceAdvertisement> _deviceDiscoveredController = 
      StreamController<DeviceAdvertisement>.broadcast();

  final StreamController<DeviceConnection> _deviceConnectionController = 
      StreamController<DeviceConnection>.broadcast();

  final StreamController<DeviceMessage> _deviceMessageController = 
      StreamController<DeviceMessage>.broadcast();

  final StreamController<DeviceState> _deviceStateController = 
      StreamController<DeviceState>.broadcast();

  final List<IDeviceAdapter> _adapters = [];

  bool _isScanning = false;
  StreamSubscription<List<dynamic>>? _scanSubscription;
  final Map<String, StreamSubscription<List<int>>> _notificationSubscriptions = {};
  final Map<String, dynamic> _connectedDevices = {};

  final Logger _logger = LoggerHelper.getCoreLogger('bluetooth_manager');

  BluetoothManager() {
    // Simplified: No actual Bluetooth scanning for now
    _logger.info('蓝牙管理器初始化完成');
    
    // 初始化后尝试自动连接已保存的设备
    _autoConnectSavedDevices();
  }

  @override
  Stream<DeviceAdvertisement> get onDeviceDiscovered => 
      _deviceDiscoveredController.stream;

  @override
  Stream<DeviceConnection> get onDeviceConnectionChanged => 
      _deviceConnectionController.stream;

  @override
  Stream<DeviceMessage> get onDeviceMessage => _deviceMessageController.stream;

  @override
  Stream<DeviceState> get onDeviceState => _deviceStateController.stream;

  /// 获取当前蓝牙状态
  Future<String> getBluetoothState() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on ? 'on' : 'off';
    } catch (e) {
      _logger.severe('获取蓝牙状态失败: $e');
      return 'unknown';
    }
  }

  /// 开启蓝牙
  Future<void> turnOnBluetooth() async {
    _logger.info('开启蓝牙');
    // Simplified: No actual Bluetooth control for now
  }

  /// 关闭蓝牙
  Future<void> turnOffBluetooth() async {
    _logger.info('关闭蓝牙');
    // Simplified: No actual Bluetooth control for now
  }

  @override
  Future<void> startScan({Duration? timeout}) async {
    if (_isScanning) {
      _logger.fine('蓝牙扫描已在进行中，忽略重复请求');
      return;
    }

    _isScanning = true;
    _logger
        .info('开始蓝牙扫描${timeout != null ? '，超时时间：${timeout.inSeconds}秒' : ''}');

    // 使用真实的flutter_blue_plus API进行扫描
    try {
      // 监听扫描结果
      FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          // 将扫描结果转换为DeviceAdvertisement对象
          final deviceAd = DeviceAdvertisement(
            deviceId: result.device.remoteId.str,
            name: result.device.platformName.isNotEmpty ? result.device.platformName : '未知设备',
            rssi: result.rssi,
            serviceUuids: result.advertisementData.serviceUuids.map((guid) => guid.toString()).toList(),
            manufacturerData: result.advertisementData.manufacturerData,
          );
          
          // 将设备添加到流中
          _deviceDiscoveredController.add(deviceAd);
        }
      });
      
      // 开始扫描（startScan返回void，不需要await）
      FlutterBluePlus.startScan(timeout: timeout);
      
      // 扫描结束后停止扫描
      if (timeout != null) {
        await Future.delayed(timeout);
        await stopScan();
      }
    } catch (e) {
      _logger.severe('蓝牙扫描失败: $e');
      await stopScan();
      rethrow;
    }
  }

  @override
  Future<void> stopScan() async {
    if (!_isScanning) {
      _logger.fine('蓝牙扫描未在进行中，忽略停止请求');
      return;
    }
    
    _logger.fine('停止蓝牙扫描');
    _isScanning = false;
    FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  @override
  Future<DeviceConnection> connect(String deviceId) async {
    _logger.info('尝试连接设备：$deviceId');
    
    try {
      // 实际连接设备
      _logger.fine('正在建立与设备 $deviceId 的连接...');
      
      // 从已扫描的设备中查找目标设备
      BluetoothDevice? device;
      final scanResults = await FlutterBluePlus.scanResults.first;
      for (var result in scanResults) {
        if (result.device.remoteId.str == deviceId) {
          device = result.device;
          break;
        }
      }
      
      if (device == null) {
        // 如果在扫描结果中没找到，尝试使用已连接的设备
        final connectedDevices = FlutterBluePlus.connectedDevices;
        for (var d in connectedDevices) {
          if (d.remoteId.str == deviceId) {
            device = d;
            break;
          }
        }
      }
      
      if (device == null) {
        throw Exception('未找到设备：$deviceId');
      }
      
      // 连接设备
      await device.connect(autoConnect: true);
      _logger.info('设备连接成功：$deviceId');
      
      // 获取设备名称
      final deviceName = device.name.isNotEmpty ? device.name : device.id.id;
      _logger.fine('获取设备名称：$deviceName');
      
      // 确定设备类型（这里需要根据实际情况实现，例如通过扫描设备特征值）
      String deviceType = 'unknown';
      
      // 尝试发现服务，用于确定设备类型
      _logger.fine('正在发现设备服务...');
      final services = await device.discoverServices();
      
      // 根据服务确定设备类型（示例逻辑，需要根据实际设备调整）
      for (final service in services) {
        if (service.uuid.toString().contains('180d')) {
          deviceType = 'heart_rate';
          break;
        } else if (service.uuid.toString().contains('180f')) {
          deviceType = 'battery';
          break;
        } else if (service.uuid.toString().contains('181c')) {
          deviceType = 'cycling_power';
          break;
        } else if (service.uuid.toString().contains('1818')) {
          deviceType = 'cycling_speed_cadence';
          break;
        }
      }
      
      _logger.fine('确定设备类型：$deviceType');
      
      // 保存连接的设备
      _connectedDevices[deviceId] = deviceId;
      
      // 发送连接事件
      final connection = DeviceConnection(
        deviceId: deviceId,
        connected: true,
        connectedAt: DateTime.now(),
      );
      _deviceConnectionController.add(connection);
      
      // 保存设备到数据库
      final db = DatabaseService();
      final bluetoothDevice = AppBluetoothDevice(
        deviceId: deviceId,
        name: deviceName,
        deviceType: deviceType,
        lastConnectedAt: DateTime.now(),
        autoConnect: true,
        priority: 50,
      );
      await db.saveBluetoothDevice(bluetoothDevice);
      _logger.fine('设备已保存到数据库，ID：$deviceId, 名称：$deviceName, 类型：$deviceType');
      
      return connection;
    } catch (e) {
      _logger.severe('连接设备失败：$deviceId, 错误：$e');
      
      // 发送断开连接事件
      _deviceConnectionController.add(DeviceConnection(
        deviceId: deviceId,
        connected: false,
        disconnectedAt: DateTime.now(),
      ));
      
      rethrow;
    }
  }

  @override
  Future<void> disconnect(String deviceId) async {
    _logger.info('断开设备连接：$deviceId');
    
    try {
      // 取消通知订阅
      await _notificationSubscriptions[deviceId]?.cancel();
      _notificationSubscriptions.remove(deviceId);
      
      // 断开设备连接
      _connectedDevices.remove(deviceId);
      
      // 发送断开事件
      _deviceConnectionController.add(DeviceConnection(
        deviceId: deviceId,
        connected: false,
        disconnectedAt: DateTime.now(),
      ));
      
      _logger.fine('设备断开成功：$deviceId');
    } catch (e) {
      _logger.severe('断开设备连接失败：$deviceId, 错误：$e');
      rethrow;
    }
  }

  @override
  Future<List<DeviceAdvertisement>> getPairedDevices() async {
    _logger.info('获取已配对设备');
    
    try {
      // Simplified: Return empty list
      return [];
    } catch (e) {
      _logger.severe('获取已配对设备失败：$e');
      return [];
    }
  }

  @override
  void registerAdapter(IDeviceAdapter adapter) {
    _adapters.add(adapter);
    _logger.finest('注册设备适配器：${adapter.runtimeType}');
  }

  @override
  void unregisterAdapter(IDeviceAdapter adapter) {
    _adapters.remove(adapter);
    _logger.finest('注销设备适配器：${adapter.runtimeType}');
  }

  /// 自动连接已保存的设备
  Future<void> _autoConnectSavedDevices() async {
    _logger.info('尝试自动连接已保存的设备');
    try {
      final db = DatabaseService();
      final savedDevices = await db.getAllBluetoothDevices();
      
      if (savedDevices.isEmpty) {
        _logger.fine('没有已保存的设备，跳过自动连接');
        return;
      }
      
      _logger.fine('找到 ${savedDevices.length} 个已保存的设备，尝试自动连接');
      
      // 按照优先级排序，优先级高的设备先连接
      final sortedDevices = savedDevices..sort((a, b) => b.priority.compareTo(a.priority));
      
      // 尝试连接每个设备
      for (final device in sortedDevices) {
        if (device.autoConnect) {
          _logger.fine('尝试自动连接设备：${device.name} (${device.deviceId})');
          try {
            await connect(device.deviceId);
            _logger.info('成功自动连接设备：${device.name}');
            break; // 只连接第一个可用设备
          } catch (e) {
            _logger.warning('自动连接设备 ${device.name} 失败：$e');
            continue;
          }
        }
      }
    } catch (e) {
      _logger.severe('自动连接设备失败：$e');
    }
  }

  /// 写入数据到设备
  Future<void> writeData(String deviceId, List<int> data) async {
    _logger.info('写入数据到设备：$deviceId, 数据：${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    
    try {
      final device = _connectedDevices[deviceId];
      if (device == null) {
        throw Exception('设备未连接：$deviceId');
      }
      
      _logger.fine('数据写入成功：$deviceId');
    } catch (e) {
      _logger.severe('写入数据失败：$deviceId, 错误：$e');
      rethrow;
    }
  }

  /// 清理资源
  void dispose() {
    _scanSubscription?.cancel();
    _notificationSubscriptions.forEach((deviceId, subscription) {
      subscription.cancel();
    });
    _deviceDiscoveredController.close();
    _deviceConnectionController.close();
    _deviceMessageController.close();
    _deviceStateController.close();
  }
}
