import 'package:flutter/material.dart';

/// Material Design 3 配色方案
/// 遵循 Google Material Design 3 设计规范
class AppColors {
  // 主色调 - Material 3 蓝色（动态色彩种子）
  static const Color primary = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDBE2FE);
  static const Color onPrimaryContainer = Color(0xFF0E1F6B);

  // 次要色
  static const Color secondary = Color(0xFF5C6BC0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE0E7FF);
  static const Color onSecondaryContainer = Color(0xFF172B4D);

  // 第三色
  static const Color tertiary = Color(0xFF7C4DFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFEDE7F6);
  static const Color onTertiaryContainer = Color(0xFF311B92);

  // 错误色
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // 表面色（浅色主题）
  static const Color surfaceLight = Color(0xFFFEFBFF);
  static const Color onSurfaceLight = Color(0xFF1A1C1E);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF7F2F9);
  static const Color surfaceContainerLight = Color(0xFFF3EDF7);
  static const Color surfaceContainerHighLight = Color(0xFFE9E4EA);
  static const Color surfaceContainerHighestLight = Color(0xFFE0D9E1);

  // 表面色（深色主题）
  static const Color surfaceDark = Color(0xFF1A1C1E);
  static const Color onSurfaceDark = Color(0xFFE3E2E6);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);
  static const Color surfaceContainerLowestDark = Color(0xFF0F0D13);
  static const Color surfaceContainerLowDark = Color(0xFF1D1B20);
  static const Color surfaceContainerDark = Color(0xFF211F26);
  static const Color surfaceContainerHighDark = Color(0xFF2B2930);
  static const Color surfaceContainerHighestDark = Color(0xFF36343B);

  // 背景色
  static const Color backgroundLight = Color(0xFFFEFBFF);
  static const Color onBackgroundLight = Color(0xFF1A1C1E);
  static const Color backgroundDark = Color(0xFF1A1C1E);
  static const Color onBackgroundDark = Color(0xFFE3E2E6);

  // 轮廓色
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantLight = Color(0xFFCAC4D0);
  static const Color outlineVariantDark = Color(0xFF49454F);

  // 阴影色
  static const Color shadowLight = Color(0xFF000000);
  static const Color shadowDark = Color(0xFF000000);

  // 反色（用于深色/浅色主题切换）
  static const Color inverseSurfaceLight = Color(0xFF2F3033);
  static const Color inverseOnSurfaceLight = Color(0xFFF4EFF4);
  static const Color inversePrimaryLight = Color(0xFFB3C6FF);
  static const Color inverseSurfaceDark = Color(0xFFE3E2E6);
  static const Color inverseOnSurfaceDark = Color(0xFF1A1C1E);
  static const Color inversePrimaryDark = Color(0xFF2563EB);

  // 数据可视化专用颜色（Material 3 风格）
  static const Color speed = Color(0xFF0B7285);
  static const Color power = Color(0xFFE67700);
  static const Color battery = Color(0xFF2B8A3E);
  static const Color temperature = Color(0xFFC92A2A);

  // 连接状态颜色
  static const Color connected = Color(0xFF2B8A3E);
  static const Color connecting = Color(0xFFE67700);
  static const Color disconnected = Color(0xFF868E96);
  static const Color errorState = Color(0xFFC92A2A);

  // 通用颜色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}

/// Material Design 3 语义化颜色系统
class SemanticColors {
  // 状态颜色
  static const Color success = Color(0xFF2B8A3E);
  static const Color warning = Color(0xFFE67700);
  static const Color error = Color(0xFFC92A2A);
  static const Color info = Color(0xFF2563EB);

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
}

/// Material Design 3 浅色主题配色
class LightThemeColors {
  static const Color primary = AppColors.primary;
  static const Color onPrimary = AppColors.onPrimary;
  static const Color primaryContainer = AppColors.primaryContainer;
  static const Color onPrimaryContainer = AppColors.onPrimaryContainer;

  static const Color secondary = AppColors.secondary;
  static const Color onSecondary = AppColors.onSecondary;
  static const Color secondaryContainer = AppColors.secondaryContainer;
  static const Color onSecondaryContainer = AppColors.onSecondaryContainer;

  static const Color tertiary = AppColors.tertiary;
  static const Color onTertiary = AppColors.onTertiary;
  static const Color tertiaryContainer = AppColors.tertiaryContainer;
  static const Color onTertiaryContainer = AppColors.onTertiaryContainer;

  static const Color error = AppColors.error;
  static const Color onError = AppColors.onError;
  static const Color errorContainer = AppColors.errorContainer;
  static const Color onErrorContainer = AppColors.onErrorContainer;

  static const Color surface = AppColors.surfaceLight;
  static const Color onSurface = AppColors.onSurfaceLight;
  static const Color surfaceVariant = AppColors.surfaceVariantLight;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariantLight;
  static const Color surfaceContainerLowest = AppColors.surfaceContainerLowestLight;
  static const Color surfaceContainerLow = AppColors.surfaceContainerLowLight;
  static const Color surfaceContainer = AppColors.surfaceContainerLight;
  static const Color surfaceContainerHigh = AppColors.surfaceContainerHighLight;
  static const Color surfaceContainerHighest = AppColors.surfaceContainerHighestLight;

  static const Color background = AppColors.backgroundLight;
  static const Color onBackground = AppColors.onBackgroundLight;

  static const Color outline = AppColors.outlineLight;
  static const Color outlineVariant = AppColors.outlineVariantLight;

  static const Color shadow = AppColors.shadowLight;
  static const Color scrim = AppColors.black;

  static const Color inverseSurface = AppColors.inverseSurfaceLight;
  static const Color inverseOnSurface = AppColors.inverseOnSurfaceLight;
  static const Color inversePrimary = AppColors.inversePrimaryLight;
}

/// Material Design 3 深色主题配色
class DarkThemeColors {
  static const Color primary = Color(0xFFB3C6FF);
  static const Color onPrimary = Color(0xFF0E1F6B);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFDBE2FE);

  static const Color secondary = Color(0xFFC4C6FF);
  static const Color onSecondary = Color(0xFF1E192B);
  static const Color secondaryContainer = Color(0xFF332D41);
  static const Color onSecondaryContainer = Color(0xFFE8DEF8);

  static const Color tertiary = Color(0xFFCEBCFF);
  static const Color onTertiary = Color(0xFF381E72);
  static const Color tertiaryContainer = Color(0xFF7C4DFF);
  static const Color onTertiaryContainer = Color(0xFFEDE7F6);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color surface = AppColors.surfaceDark;
  static const Color onSurface = AppColors.onSurfaceDark;
  static const Color surfaceVariant = AppColors.surfaceVariantDark;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariantDark;
  static const Color surfaceContainerLowest = AppColors.surfaceContainerLowestDark;
  static const Color surfaceContainerLow = AppColors.surfaceContainerLowDark;
  static const Color surfaceContainer = AppColors.surfaceContainerDark;
  static const Color surfaceContainerHigh = AppColors.surfaceContainerHighDark;
  static const Color surfaceContainerHighest = AppColors.surfaceContainerHighestDark;

  static const Color background = AppColors.backgroundDark;
  static const Color onBackground = AppColors.onBackgroundDark;

  static const Color outline = AppColors.outlineDark;
  static const Color outlineVariant = AppColors.outlineVariantDark;

  static const Color shadow = AppColors.shadowDark;
  static const Color scrim = AppColors.black;

  static const Color inverseSurface = AppColors.inverseSurfaceDark;
  static const Color inverseOnSurface = AppColors.inverseOnSurfaceDark;
  static const Color inversePrimary = AppColors.inversePrimaryDark;
}
