import 'package:flutter/material.dart';

/// 权限相关常量定义
class PermissionConstants {
  // 权限类型
  static const String bluetooth = 'bluetooth';
  static const String location = 'location';
  static const String locationAlways = 'location_always';
  static const String bluetoothScan = 'bluetooth_scan';
  static const String bluetoothConnect = 'bluetooth_connect';

  // 权限显示信息
  static const Map<String, Map<String, dynamic>> permissionInfo = {
    bluetooth: {
      'title': '蓝牙权限',
      'description': '需要蓝牙权限来扫描和连接附近的蓝牙设备',
      'icon': Icons.bluetooth,
      'color': Colors.blue,
      'required': true,
    },
    location: {
      'title': '精确定位',
      'description': '需要高精度定位来发现附近的蓝牙设备（蓝牙扫描需要定位权限）',
      'icon': Icons.location_on,
      'color': Colors.green,
      'required': true,
    },
    locationAlways: {
      'title': '后台定位',
      'description': '允许应用在后台持续获取位置信息，用于保持蓝牙连接',
      'icon': Icons.location_pin,
      'color': Colors.orange,
      'required': false,
    },
    bluetoothScan: {
      'title': '蓝牙扫描',
      'description': '允许应用扫描附近的蓝牙设备',
      'icon': Icons.search,
      'color': Colors.blue,
      'required': true,
    },
    bluetoothConnect: {
      'title': '蓝牙连接',
      'description': '允许应用连接到蓝牙设备',
      'icon': Icons.link,
      'color': Colors.blue,
      'required': true,
    },
  };

  // 权限说明文案
  static const String permissionRequiredTitle = '权限请求';
  static const String permissionRequiredDescription = '为了提供完整的功能，我们需要以下权限。请授予所有必要的权限以继续使用应用。';
  static const String permissionOptionalDescription = '以下权限是可选的，但推荐授予以获得最佳体验。';
  
  static const String permissionGranted = '已授予';
  static const String permissionDenied = '已拒绝';
  static const String permissionPermanentlyDenied = '永久拒绝';
  
  static const String grantPermission = '授予权限';
  static const String checkPermission = '检查权限';
  static const String openSettings = '打开设置';
  
  static const String allPermissionsGranted = '所有权限已授予';
  static const String missingPermissions = '缺少必要权限';
  
  static const String bluetoothRequired = '蓝牙权限是必需的';
  static const String locationRequired = '定位权限是必需的';
  static const String bluetoothScanRequired = '蓝牙扫描权限是必需的';
  static const String bluetoothConnectRequired = '蓝牙连接权限是必需的';

  // 错误信息
  static const String permissionCheckFailed = '权限检查失败';
  static const String permissionRequestFailed = '权限请求失败';
  static const String settingsOpenFailed = '无法打开设置页面';

  // 按钮文本
  static const String continueText = '继续';
  static const String skipOptional = '跳过可选权限';
  static const String requestAll = '请求所有权限';
  static const String tryAgain = '重试';

  // 提示信息
  static const String permissionGuide = '权限说明';
  static const String whyNeedPermissions = '为什么需要这些权限？';
  static const String bluetoothExplanation = '蓝牙权限用于扫描和连接您的摩托车/电动车设备';
  static const String locationExplanation = '定位权限用于蓝牙设备发现（Android系统要求）';
  static const String backgroundExplanation = '后台定位用于保持设备连接和数据同步';

  // 成功消息
  static const String permissionGrantedSuccessfully = '权限授予成功';
  static const String readyToProceed = '准备就绪，可以进入主界面';

  // 失败消息
  static const String permissionDeniedMessage = '您拒绝了必要的权限，应用无法正常运行';
  static const String permissionRequiredMessage = '请授予所有必要权限才能继续';
}

/// 权限状态枚举
enum PermissionStatus {
  granted,           // 已授予
  denied,            // 已拒绝
  permanentlyDenied, // 永久拒绝
  restricted,        // 受限（iOS）
  limited,           // 有限（iOS）
  unknown,           // 未知
}

/// 权限类型枚举
enum PermissionType {
  bluetooth,         // 蓝牙
  location,          // 定位
  locationAlways,    // 后台定位
  bluetoothScan,     // 蓝牙扫描
  bluetoothConnect,  // 蓝牙连接
}

/// 权限分组
class PermissionGroup {
  static const List<PermissionType> required = [
    PermissionType.bluetooth,
    PermissionType.location,
    PermissionType.bluetoothScan,
    PermissionType.bluetoothConnect,
  ];

  static const List<PermissionType> optional = [
    PermissionType.locationAlways,
  ];

  static const List<PermissionType> all = [
    ...required,
    ...optional,
  ];
}