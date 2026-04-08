import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;

import '../../core/services/bluetooth_service.dart';
import '../../domain/models/ble_packet.dart';
import 'bluetooth_state.dart';

/// 蓝牙服务Provider
final bluetoothServiceProvider = Provider<YuanquBluetoothService>((ref) {
  final service = YuanquBluetoothService();

  ref.onDispose(() {
    if (kDebugMode) {
      print('BluetoothServiceProvider: dispose called');
    }
  });

  return service;
});

/// 蓝牙状态Provider
final bluetoothStateProvider =
    StateNotifierProvider<BluetoothNotifier, BluetoothState>((ref) {
  final service = ref.watch(bluetoothServiceProvider);

  final notifier = BluetoothNotifier(service);

  // 初始化蓝牙
  notifier.initialize();

  return notifier;
});

/// 蓝牙状态管理器
class BluetoothNotifier extends StateNotifier<BluetoothState> {
  final YuanquBluetoothService _service;

  // 流订阅
  StreamSubscription<BleConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<ble.ScanResult>>? _scanResultsSubscription;
  StreamSubscription<YuanquDeviceData>? _dataSubscription;
  StreamSubscription<String>? _errorSubscription;

  BluetoothNotifier(this._service) : super(BluetoothState.initial());

  /// 初始化蓝牙
  Future<void> initialize() async {
    final success = await _service.initialize();
    if (!success) {
      state = state.copyWith(
        errorMessage: '蓝牙初始化失败',
      );
    }
    _setupStreamSubscriptions();
  }

  /// 设置流订阅
  void _setupStreamSubscriptions() {
    // 连接状态流
    _connectionStateSubscription =
        _service.connectionStateStream.listen((connectionState) {
      state = state.copyWith(
        connectionState: connectionState,
        isConnected: connectionState == BleConnectionState.connected,
        isScanning: connectionState == BleConnectionState.scanning,
      );
    });

    // 扫描结果流
    _scanResultsSubscription = _service.scanResultsStream.listen((results) {
      state = state.copyWith(scanResults: results);
    });

    // 数据流
    _dataSubscription = _service.dataStream.listen((data) {
      // 合并新数据
      final currentData = state.latestData;
      final mergedData = currentData?.merge(data) ?? data;

      state = state.copyWith(
        latestData: mergedData,
        clearError: true,
      );

      if (kDebugMode) {
        print('BluetoothNotifier: received data - $data');
      }
    });

    // 错误流
    _errorSubscription = _service.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error);
    });
  }

  /// 开始扫描设备
  Future<void> startScan({int duration = 4, int timeout = 30}) async {
    state = state.copyWith(clearError: true);

    try {
      await _service.startScan(duration: duration, timeout: timeout);
    } catch (e) {
      state = state.copyWith(errorMessage: '扫描失败: $e');
    }
  }

  /// 停止扫描
  Future<void> stopScan() async {
    try {
      await _service.stopScan();
    } catch (e) {
      state = state.copyWith(errorMessage: '停止扫描失败: $e');
    }
  }

  /// 连接设备
  Future<bool> connect(ble.BluetoothDevice device) async {
    state = state.copyWith(clearError: true);

    try {
      final success = await _service.connect(device);
      if (!success) {
        state = state.copyWith(errorMessage: '连接失败');
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: '连接异常: $e');
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    try {
      await _service.disconnect();
    } catch (e) {
      state = state.copyWith(errorMessage: '断开连接失败: $e');
    }
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 模拟接收数据（用于测试）
  void simulateData(String hexString) {
    _service.simulateDataFromHex(hexString);
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _dataSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }
}

/// 便捷Provider：获取最新控制器数据
final latestControllerDataProvider =
    Provider<ControllerData?>((ref) {
  final bluetoothState = ref.watch(bluetoothStateProvider);
  return bluetoothState.latestData?.controller;
});

/// 便捷Provider：获取最新BMS数据
final latestBmsDataProvider = Provider<BmsData?>((ref) {
  final bluetoothState = ref.watch(bluetoothStateProvider);
  return bluetoothState.latestData?.bms;
});

/// 便捷Provider：是否有蓝牙数据
final hasBluetoothDataProvider = Provider<bool>((ref) {
  final bluetoothState = ref.watch(bluetoothStateProvider);
  return bluetoothState.latestData?.hasAnyData ?? false;
});
