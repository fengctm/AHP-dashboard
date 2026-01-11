import 'package:flutter/material.dart';

/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'AHP Dashboard';
  static const String appVersion = '1.0.0';
  static const String appDescription = '摩托车/电动车智能仪表盘';

  // 动画时长（毫秒）
  static const int animationFast = 100;
  static const int animationNormal = 200;
  static const int animationSlow = 300;
  static const int animationVerySlow = 400;

  // 布局常量
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // 圆角
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;

  // 断点
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1200.0;

  // 数据限制
  static const double maxSpeed = 200.0;
  static const double maxPower = 20.0;
  static const double maxTemperature = 150.0;

  // 本地存储键
  static const String themeKey = 'app_theme_mode';
  static const String deviceKey = 'connected_device';
  static const String settingsKey = 'app_settings';

  // 设备相关
  static const int connectionTimeout = 5000; // 5秒
  static const int syncInterval = 3000; // 3秒

  // 颜色透明度
  static const double opacityLow = 0.1;
  static const double opacityMedium = 0.3;
  static const double opacityHigh = 0.6;
}

/// 应用配置
class AppConfig {
  // 是否启用动画
  static const bool enableAnimations = true;

  // 是否启用调试模式
  static const bool debugMode = false;

  // 默认主题
  static const ThemeMode defaultTheme = ThemeMode.system;

  // 数据刷新间隔（毫秒）
  static const int dataRefreshInterval = 1000;

  // 最大历史记录数
  static const int maxHistoryRecords = 100;
}

/// 路由定义
class AppRoutes {
  static const String dashboard = '/';
  static const String settings = '/settings';
  static const String deviceList = '/devices';
  static const String deviceDetail = '/device/detail';
  static const String history = '/history';
  static const String export = '/export';
}

/// 事件名称
class AppEvents {
  static const String themeChanged = 'theme_changed';
  static const String deviceConnected = 'device_connected';
  static const String deviceDisconnected = 'device_disconnected';
  static const String dataUpdated = 'data_updated';
  static const String errorOccurred = 'error_occurred';
}

/// 消息定义
class AppMessages {
  static const String connecting = '正在连接设备...';
  static const String connected = '设备已连接';
  static const String disconnected = '设备已断开';
  static const String connectionFailed = '连接失败';
  static const String dataSyncing = '正在同步数据...';
  static const String dataSynced = '数据同步完成';
  static const String dataSyncFailed = '数据同步失败';
  static const String themeChanged = '主题已切换';
  static const String settingsSaved = '设置已保存';
  static const String exportSuccess = '数据导出成功';
  static const String exportFailed = '数据导出失败';
  static const String permissionDenied = '权限被拒绝';
  static const String networkError = '网络连接错误';
  static const String unknownError = '未知错误';
}

/// 数据字段定义
class DataFields {
  static const String speed = 'speed';
  static const String battery = 'battery';
  static const String power = 'power';
  static const String temperature = 'temperature';
  static const String mileage = 'mileage';
  static const String energy = 'energy';
  static const String connection = 'connection';
  static const String firmware = 'firmware';
}

/// 单位定义
class Units {
  static const String speed = 'km/h';
  static const String power = 'kW';
  static const String temperature = '°C';
  static const String battery = '%';
  static const String mileage = 'km';
  static const String energy = 'kWh/100km';
}