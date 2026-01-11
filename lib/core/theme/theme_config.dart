import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 浅色主题配置
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: LightThemeColors.surface,
    surfaceContainerHighest: LightThemeColors.surfaceVariant,
    onPrimary: LightThemeColors.onPrimary,
    onSecondary: LightThemeColors.onSecondary,
    onSurface: LightThemeColors.onSurface,
  ),
  scaffoldBackgroundColor: LightThemeColors.background,
  cardColor: LightThemeColors.surface,
  dividerColor: LightThemeColors.divider,
  hintColor: LightThemeColors.hint,
  disabledColor: LightThemeColors.disabled,
  
  // 文字主题
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: LightThemeColors.onSurface,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: LightThemeColors.onSurface,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: LightThemeColors.onSurface,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: LightThemeColors.onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: LightThemeColors.onSurface,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: LightThemeColors.onSurface,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: LightThemeColors.onSurface,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: LightThemeColors.hint,
      height: 1.3,
    ),
  ),

  // 应用栏主题
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: LightThemeColors.onPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  // 卡片主题
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: LightThemeColors.surface,
  ),

  // 按钮主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: LightThemeColors.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // 文本按钮主题
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // 图标主题
  iconTheme: const IconThemeData(
    color: LightThemeColors.onSurface,
    size: 24,
  ),

  // 分割线主题
  dividerTheme: const DividerThemeData(
    color: LightThemeColors.divider,
    thickness: 1,
    space: 1,
  ),

  // 输入框主题
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: LightThemeColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: LightThemeColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: LightThemeColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // 悬浮按钮主题
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: LightThemeColors.onPrimary,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // 导航栏主题
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: LightThemeColors.surface,
    elevation: 1,
    indicatorColor: AppColors.primary.withValues(alpha: 0.2),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),

  // 进度指示器主题
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: LightThemeColors.divider,
  ),
);

/// 深色主题配置
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    surface: DarkThemeColors.surface,
    surfaceContainerHighest: DarkThemeColors.surfaceVariant,
    onPrimary: DarkThemeColors.onPrimary,
    onSecondary: DarkThemeColors.onSecondary,
    onSurface: DarkThemeColors.onSurface,
  ),
  scaffoldBackgroundColor: DarkThemeColors.background,
  cardColor: DarkThemeColors.surface,
  dividerColor: DarkThemeColors.divider,
  hintColor: DarkThemeColors.hint,
  disabledColor: DarkThemeColors.disabled,

  // 文字主题
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: DarkThemeColors.onSurface,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: DarkThemeColors.onSurface,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: DarkThemeColors.onSurface,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: DarkThemeColors.onBackground,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: DarkThemeColors.onSurface,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: DarkThemeColors.onSurface,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: DarkThemeColors.onSurface,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: DarkThemeColors.hint,
      height: 1.3,
    ),
  ),

  // 应用栏主题
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkThemeColors.surface,
    foregroundColor: DarkThemeColors.onSurface,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  // 卡片主题
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: DarkThemeColors.surface,
  ),

  // 按钮主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: DarkThemeColors.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // 文本按钮主题
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // 图标主题
  iconTheme: const IconThemeData(
    color: DarkThemeColors.onSurface,
    size: 24,
  ),

  // 分割线主题
  dividerTheme: const DividerThemeData(
    color: DarkThemeColors.divider,
    thickness: 1,
    space: 1,
  ),

  // 输入框主题
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DarkThemeColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DarkThemeColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    filled: true,
    fillColor: DarkThemeColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // 悬浮按钮主题
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: DarkThemeColors.onPrimary,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // 导航栏主题
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: DarkThemeColors.surface,
    elevation: 1,
    indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),

  // 进度指示器主题
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primaryLight,
    linearTrackColor: DarkThemeColors.divider,
  ),
);