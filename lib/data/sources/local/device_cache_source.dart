import 'dart:async';
import 'package:logging/logging.dart';
import 'interfaces/device_cache_manager.dart';
import '../../models/bluetooth_device_model.dart';
import 'database_source.dart';
import '../../../../../core/utils/logger_helper.dart';

/// 设备内存管理器实现
class DeviceMemoryManager implements IDeviceMemoryManager {
  final Logger _logger = LoggerHelper.getCoreLogger('device_memory_manager');
  final DatabaseService _databaseService = DatabaseService();
  
  final StreamController<List<ConnectedDevice>> _devicesChangedController = 
      StreamController<List<ConnectedDevice>>.broadcast();
  
  DeviceMemoryManager() {
    _logger.fine('设备内存管理器初始化完成');
  }
  
  @override
  Future<void> saveConnectedDevice(ConnectedDevice device) async {
    _logger.fine('保存连接设备: ${device.name} (${device.id})');
    
    try {
      // 将ConnectedDevice转换为AppBluetoothDevice
      final appDevice = AppBluetoothDevice(
        deviceId: device.id,
        name: device.name,
        deviceType: device.type,
        lastConnectedAt: device.lastConnectedAt,
        autoConnect: device.autoConnect,
        priority: device.priority,
      );
      
      // 保存到数据库
      await _databaseService.saveBluetoothDevice(appDevice);
      
      // 通知设备列表变化
      _notifyDevicesChanged();
      
      _logger.fine('设备保存成功: ${device.name} (${device.id})');
    } catch (e) {
      _logger.severe('保存设备失败: ${device.id}, 错误: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<ConnectedDevice>> getSavedDevices() async {
    _logger.fine('获取所有保存的设备');
    
    try {
      final appDevices = await _databaseService.getAllBluetoothDevices();
      
      // 将AppBluetoothDevice转换为ConnectedDevice
      final connectedDevices = appDevices.map((appDevice) => ConnectedDevice(
        id: appDevice.deviceId,
        name: appDevice.name,
        type: appDevice.deviceType,
        lastConnectedAt: appDevice.lastConnectedAt,
        autoConnect: appDevice.autoConnect,
        priority: appDevice.priority,
      )).toList();
      
      _logger.fine('获取到 ${connectedDevices.length} 个保存的设备');
      return connectedDevices;
    } catch (e) {
      _logger.severe('获取保存设备失败: $e');
      return [];
    }
  }
  
  @override
  Future<ConnectedDevice?> getSavedDevice(String deviceId) async {
    _logger.fine('获取保存的设备: $deviceId');
    
    try {
      final appDevice = await _databaseService.getBluetoothDevice(deviceId);
      
      if (appDevice != null) {
        // 将AppBluetoothDevice转换为ConnectedDevice
        return ConnectedDevice(
          id: appDevice.deviceId,
          name: appDevice.name,
          type: appDevice.deviceType,
          lastConnectedAt: appDevice.lastConnectedAt,
          autoConnect: appDevice.autoConnect,
          priority: appDevice.priority,
        );
      }
      
      _logger.fine('未找到设备: $deviceId');
      return null;
    } catch (e) {
      _logger.severe('获取设备失败: $deviceId, 错误: $e');
      return null;
    }
  }
  
  @override
  Future<void> forgetDevice(String deviceId) async {
    _logger.info('忘记设备: $deviceId');
    
    try {
      await _databaseService.deleteBluetoothDevice(deviceId);
      
      // 通知设备列表变化
      _notifyDevicesChanged();
      
      _logger.fine('设备已忘记: $deviceId');
    } catch (e) {
      _logger.severe('忘记设备失败: $deviceId, 错误: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateAutoConnect(String deviceId, bool autoConnect) async {
    _logger.fine('更新设备自动连接状态: $deviceId, autoConnect: $autoConnect');
    
    try {
      final appDevice = await _databaseService.getBluetoothDevice(deviceId);
      
      if (appDevice != null) {
        appDevice.autoConnect = autoConnect;
        await _databaseService.updateBluetoothDevice(appDevice);
        
        // 通知设备列表变化
        _notifyDevicesChanged();
        
        _logger.fine('设备自动连接状态更新成功: $deviceId');
      } else {
        _logger.warning('未找到设备: $deviceId');
      }
    } catch (e) {
      _logger.severe('更新设备自动连接状态失败: $deviceId, 错误: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updatePriority(String deviceId, int priority) async {
    _logger.fine('更新设备优先级: $deviceId, priority: $priority');
    
    try {
      final appDevice = await _databaseService.getBluetoothDevice(deviceId);
      
      if (appDevice != null) {
        appDevice.priority = priority;
        await _databaseService.updateBluetoothDevice(appDevice);
        
        // 通知设备列表变化
        _notifyDevicesChanged();
        
        _logger.fine('设备优先级更新成功: $deviceId');
      } else {
        _logger.warning('未找到设备: $deviceId');
      }
    } catch (e) {
      _logger.severe('更新设备优先级失败: $deviceId, 错误: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clearAllDevices() async {
    _logger.info('清除所有保存的设备');
    
    try {
      // 这里需要注意：DatabaseService没有直接的clearAllBluetoothDevices方法
      // 我们需要获取所有设备，然后逐个删除
      final appDevices = await _databaseService.getAllBluetoothDevices();
      
      for (final device in appDevices) {
        await _databaseService.deleteBluetoothDevice(device.deviceId);
      }
      
      // 通知设备列表变化
      _notifyDevicesChanged();
      
      _logger.fine('所有设备已清除');
    } catch (e) {
      _logger.severe('清除所有设备失败: $e');
      rethrow;
    }
  }
  
  @override
  Stream<List<ConnectedDevice>> get onDevicesChanged => _devicesChangedController.stream;
  
  /// 通知设备列表变化
  Future<void> _notifyDevicesChanged() async {
    _logger.finer('通知设备列表变化');
    
    try {
      final devices = await getSavedDevices();
      _devicesChangedController.add(devices);
    } catch (e) {
      _logger.warning('通知设备列表变化失败: $e');
    }
  }
  
  /// 释放资源
  void dispose() {
    _logger.fine('释放设备内存管理器资源');
    _devicesChangedController.close();
  }
}