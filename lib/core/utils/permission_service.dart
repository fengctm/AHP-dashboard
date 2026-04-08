import 'package:permission_handler/permission_handler.dart' as plugin;
import 'package:location/location.dart' as loc;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../constants/permission_constants.dart';

/// 权限服务类
/// 负责处理所有权限相关的操作
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// 检查单个权限状态
  Future<PermissionStatus> checkPermission(PermissionType type) async {
    try {
      switch (type) {
        case PermissionType.bluetooth:
          // Android 12+ 需要蓝牙扫描和连接权限
          if (await _isAndroid12OrAbove()) {
            final scanStatus = await _checkBluetoothScan();
            final connectStatus = await _checkBluetoothConnect();
            if (scanStatus == PermissionStatus.granted && 
                connectStatus == PermissionStatus.granted) {
              return PermissionStatus.granted;
            }
            return PermissionStatus.denied;
          }
          // Android 11 及以下
          final status = await plugin.Permission.bluetooth.status;
          return _convertStatus(status);

        case PermissionType.location:
          final status = await plugin.Permission.location.status;
          return _convertStatus(status);

        case PermissionType.locationAlways:
          final status = await plugin.Permission.locationAlways.status;
          return _convertStatus(status);

        case PermissionType.bluetoothScan:
          return await _checkBluetoothScan();

        case PermissionType.bluetoothConnect:
          return await _checkBluetoothConnect();
      }
    } catch (e) {
      // 日志记录: 检查权限失败
      return PermissionStatus.unknown;
    }
  }

  /// 检查蓝牙扫描权限
  Future<PermissionStatus> _checkBluetoothScan() async {
    if (await _isAndroid12OrAbove()) {
      final status = await plugin.Permission.bluetoothScan.status;
      return _convertStatus(status);
    }
    return PermissionStatus.granted;
  }

  /// 检查蓝牙连接权限
  Future<PermissionStatus> _checkBluetoothConnect() async {
    if (await _isAndroid12OrAbove()) {
      final status = await plugin.Permission.bluetoothConnect.status;
      return _convertStatus(status);
    }
    return PermissionStatus.granted;
  }

  /// 请求单个权限
  Future<PermissionStatus> requestPermission(PermissionType type) async {
    try {
      switch (type) {
        case PermissionType.bluetooth:
          if (await _isAndroid12OrAbove()) {
            final scanResult = await _requestBluetoothScan();
            final connectResult = await _requestBluetoothConnect();
            if (scanResult == PermissionStatus.granted && 
                connectResult == PermissionStatus.granted) {
              return PermissionStatus.granted;
            }
            return PermissionStatus.denied;
          }
          final status = await plugin.Permission.bluetooth.request();
          return _convertStatus(status);

        case PermissionType.location:
          final status = await plugin.Permission.location.request();
          return _convertStatus(status);

        case PermissionType.locationAlways:
          final status = await plugin.Permission.locationAlways.request();
          return _convertStatus(status);

        case PermissionType.bluetoothScan:
          return await _requestBluetoothScan();

        case PermissionType.bluetoothConnect:
          return await _requestBluetoothConnect();
      }
    } catch (e) {
      // 日志记录: 请求权限失败
      return PermissionStatus.unknown;
    }
  }

  /// 请求蓝牙扫描权限
  Future<PermissionStatus> _requestBluetoothScan() async {
    if (await _isAndroid12OrAbove()) {
      final status = await plugin.Permission.bluetoothScan.request();
      return _convertStatus(status);
    }
    return PermissionStatus.granted;
  }

  /// 请求蓝牙连接权限
  Future<PermissionStatus> _requestBluetoothConnect() async {
    if (await _isAndroid12OrAbove()) {
      final status = await plugin.Permission.bluetoothConnect.request();
      return _convertStatus(status);
    }
    return PermissionStatus.granted;
  }

  /// 检查所有必要权限
  Future<Map<PermissionType, PermissionStatus>> checkAllRequiredPermissions() async {
    final results = <PermissionType, PermissionStatus>{};
    
    for (var type in PermissionGroup.required) {
      results[type] = await checkPermission(type);
    }
    
    return results;
  }

  /// 请求所有必要权限
  Future<Map<PermissionType, PermissionStatus>> requestAllRequiredPermissions() async {
    final results = <PermissionType, PermissionStatus>{};
    
    for (var type in PermissionGroup.required) {
      results[type] = await requestPermission(type);
    }
    
    return results;
  }

  /// 检查所有权限（包括可选）
  Future<Map<PermissionType, PermissionStatus>> checkAllPermissions() async {
    final results = <PermissionType, PermissionStatus>{};
    
    for (var type in PermissionGroup.all) {
      results[type] = await checkPermission(type);
    }
    
    return results;
  }

  /// 检查是否所有必要权限都已授予
  Future<bool> hasAllRequiredPermissions() async {
    final results = await checkAllRequiredPermissions();
    return results.values.every((status) => status == PermissionStatus.granted);
  }

  /// 检查是否所有权限都已授予（包括可选）
  Future<bool> hasAllPermissions() async {
    final results = await checkAllPermissions();
    return results.values.every((status) => status == PermissionStatus.granted);
  }

  /// 获取缺失的必要权限列表
  Future<List<PermissionType>> getMissingRequiredPermissions() async {
    final results = await checkAllRequiredPermissions();
    return results.entries
        .where((entry) => entry.value != PermissionStatus.granted)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取缺失的所有权限列表
  Future<List<PermissionType>> getMissingPermissions() async {
    final results = await checkAllPermissions();
    return results.entries
        .where((entry) => entry.value != PermissionStatus.granted)
        .map((entry) => entry.key)
        .toList();
  }

  /// 检查是否有权限被永久拒绝
  Future<bool> hasPermanentlyDeniedPermission() async {
    final results = await checkAllPermissions();
    return results.values.any((status) => status == PermissionStatus.permanentlyDenied);
  }

  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    try {
      return await plugin.openAppSettings();
    } catch (e) {
      // 日志记录: 打开设置失败
      return false;
    }
  }

  /// 检查定位服务是否开启
  Future<bool> isLocationServiceEnabled() async {
    try {
      final location = loc.Location();
      final serviceEnabled = await location.serviceEnabled();
      return serviceEnabled;
    } catch (e) {
      // 日志记录: 检查定位服务失败
      return false;
    }
  }

  /// 请求开启定位服务
  Future<bool> requestLocationService() async {
    try {
      final location = loc.Location();
      final serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        return await location.requestService();
      }
      return true;
    } catch (e) {
      // 日志记录: 请求定位服务失败
      return false;
    }
  }

  /// 检查蓝牙是否开启
  Future<bool> isBluetoothEnabled() async {
    try {
      // 使用 FlutterBluePlus 检查蓝牙状态
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      // 日志记录: 检查蓝牙状态失败
      return false;
    }
  }

  /// 请求开启蓝牙（Android）
  Future<bool> requestBluetoothEnable() async {
    try {
      // 在 Android 上，这通常需要用户手动开启
      // 我们可以提示用户去开启
      return await isBluetoothEnabled();
    } catch (e) {
      // 日志记录: 请求蓝牙开启失败
      return false;
    }
  }

  /// 检查平台是否为 Android 12+
  Future<bool> _isAndroid12OrAbove() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 31;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 转换权限状态
  PermissionStatus _convertStatus(plugin.PermissionStatus status) {
    switch (status) {
      case plugin.PermissionStatus.granted:
        return PermissionStatus.granted;
      case plugin.PermissionStatus.denied:
        return PermissionStatus.denied;
      case plugin.PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case plugin.PermissionStatus.restricted:
        return PermissionStatus.restricted;
      case plugin.PermissionStatus.limited:
        return PermissionStatus.limited;
      default:
        return PermissionStatus.unknown;
    }
  }

  /// 获取权限状态的描述文本
  String getStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionConstants.permissionGranted;
      case PermissionStatus.denied:
        return PermissionConstants.permissionDenied;
      case PermissionStatus.permanentlyDenied:
        return PermissionConstants.permissionPermanentlyDenied;
      case PermissionStatus.restricted:
        return '受限';
      case PermissionStatus.limited:
        return '有限';
      case PermissionStatus.unknown:
        return '未知';
    }
  }

  /// 检查权限是否可以请求
  Future<bool> canRequestPermission(PermissionType type) async {
    final status = await checkPermission(type);
    return status != PermissionStatus.permanentlyDenied && 
           status != PermissionStatus.granted;
  }

  /// 获取权限解释文本
  String getPermissionExplanation(PermissionType type) {
    switch (type) {
      case PermissionType.bluetooth:
        return '蓝牙权限用于扫描和连接您的摩托车/电动车设备';
      case PermissionType.location:
        return '定位权限用于蓝牙设备发现（Android系统要求）';
      case PermissionType.locationAlways:
        return '后台定位用于保持设备连接和数据同步';
      case PermissionType.bluetoothScan:
        return '扫描附近的蓝牙设备';
      case PermissionType.bluetoothConnect:
        return '连接到蓝牙设备';
    }
  }
}