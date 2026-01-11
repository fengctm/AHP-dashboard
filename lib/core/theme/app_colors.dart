import 'package:flutter/material.dart';

/// 应用基础配色方案
/// 遵循科技、扁平化、速度、万物互联的设计理念
class AppColors {
  // 主色调 - 科技蓝
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // 次要色 - 活力橙
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);

  // 强调色 - 速度绿
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF388E3C);

  // 语义化状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 霓虹色（深色主题专用）
  static const Color cyanNeon = Color(0xFF00E5FF);
  static const Color successNeon = Color(0xFF00FF88);
  static const Color warningNeon = Color(0xFFFFD600);
  static const Color errorNeon = Color(0xFFFF1744);
  static const Color purpleNeon = Color(0xFFB388FF);

  // 主题表面颜色
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // 文本颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // 额外颜色
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color purple = Color(0xFF9C27B0);

  // 数据可视化专用颜色
  static const Color speed = Color(0xFF00BCD4);      // 速度 - 青色
  static const Color power = Color(0xFFFF9800);      // 功率 - 橙色
  static const Color battery = Color(0xFF4CAF50);    // 电量 - 绿色
  static const Color temperature = Color(0xFFF44336); // 温度 - 红色

  // 连接状态颜色
  static const Color connected = Color(0xFF4CAF50);
  static const Color connecting = Color(0xFFFFC107);
  static const Color disconnected = Color(0xFF9E9E9E);
  static const Color errorState = Color(0xFFF44336);

  // 中性色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
}

/// 语义化颜色系统
/// 用于表达特定含义的颜色
class SemanticColors {
  // 状态颜色
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;

  // 数据可视化
  static const Color speed = AppColors.speed;
  static const Color power = AppColors.power;
  static const Color battery = AppColors.battery;
  static const Color temperature = AppColors.temperature;

  // 连接状态
  static const Color connected = AppColors.connected;
  static const Color connecting = AppColors.connecting;
  static const Color disconnected = AppColors.disconnected;
  static const Color errorState = AppColors.errorState;

  // 交通信号
  static const Color red = Color(0xFFF44336);
  static const Color yellow = Color(0xFFFFC107);
  static const Color green = Color(0xFF4CAF50);
}

/// 浅色主题配色
class LightThemeColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE3E3E3);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF212121);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color hint = Color(0xFF757575);
  static const Color disabled = Color(0xFFBDBDBD);
}

/// 深色主题配色
class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onBackground = Color(0xFFE0E0E0);

  static const Color divider = Color(0xFF333333);
  static const Color hint = Color(0xFF9E9E9E);
  static const Color disabled = Color(0xFF616161);
}