import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material Design 3 浅色主题配置
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: LightThemeColors.primary,
    onPrimary: LightThemeColors.onPrimary,
    primaryContainer: LightThemeColors.primaryContainer,
    onPrimaryContainer: LightThemeColors.onPrimaryContainer,
    secondary: LightThemeColors.secondary,
    onSecondary: LightThemeColors.onSecondary,
    secondaryContainer: LightThemeColors.secondaryContainer,
    onSecondaryContainer: LightThemeColors.onSecondaryContainer,
    tertiary: LightThemeColors.tertiary,
    onTertiary: LightThemeColors.onTertiary,
    tertiaryContainer: LightThemeColors.tertiaryContainer,
    onTertiaryContainer: LightThemeColors.onTertiaryContainer,
    error: LightThemeColors.error,
    onError: LightThemeColors.onError,
    errorContainer: LightThemeColors.errorContainer,
    onErrorContainer: LightThemeColors.onErrorContainer,
    surface: LightThemeColors.surface,
    onSurface: LightThemeColors.onSurface,
    surfaceVariant: LightThemeColors.surfaceVariant,
    onSurfaceVariant: LightThemeColors.onSurfaceVariant,
    outline: LightThemeColors.outline,
    outlineVariant: LightThemeColors.outlineVariant,
    shadow: LightThemeColors.shadow,
    scrim: LightThemeColors.scrim,
    inverseSurface: LightThemeColors.inverseSurface,
    onInverseSurface: LightThemeColors.inverseOnSurface,
    inversePrimary: LightThemeColors.inversePrimary,
  ),
  scaffoldBackgroundColor: LightThemeColors.background,
  cardColor: LightThemeColors.surface,
  dividerColor: LightThemeColors.outlineVariant,
  hintColor: LightThemeColors.onSurface.withOpacity(0.6),
  disabledColor: LightThemeColors.onSurface.withOpacity(0.38),
  
  // Material Design 3 文字主题
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.12,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: LightThemeColors.onSurface,
      height: 1.50,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: LightThemeColors.onSurface,
      height: 1.43,
      letterSpacing: 0.10,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.50,
      letterSpacing: 0.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.43,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
      height: 1.33,
      letterSpacing: 0.40,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: LightThemeColors.onSurface,
      height: 1.43,
      letterSpacing: 0.10,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: LightThemeColors.onSurface,
      height: 1.33,
      letterSpacing: 0.50,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: LightThemeColors.onSurface,
      height: 1.45,
      letterSpacing: 0.50,
    ),
  ),

  // Material Design 3 应用栏主题
  appBarTheme: AppBarTheme(
    backgroundColor: LightThemeColors.surface,
    foregroundColor: LightThemeColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 2,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
    ),
    surfaceTintColor: LightThemeColors.primary,
  ),

  // Material Design 3 卡片主题
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: LightThemeColors.outlineVariant),
    ),
    color: LightThemeColors.surface,
    surfaceTintColor: LightThemeColors.primary,
    margin: const EdgeInsets.all(0),
    clipBehavior: Clip.antiAlias,
  ),

  // Material Design 3 按钮主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LightThemeColors.primary,
      foregroundColor: LightThemeColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.10,
      ),
    ),
  ),

  // Material Design 3 填充按钮主题
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: LightThemeColors.primary,
      foregroundColor: LightThemeColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.10,
      ),
    ),
  ),

  // Material Design 3 文本按钮主题
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: LightThemeColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.10,
      ),
    ),
  ),

  // Material Design 3 图标主题
  iconTheme: IconThemeData(
    color: LightThemeColors.onSurface,
    size: 24,
  ),

  // Material Design 3 分割线主题
  dividerTheme: DividerThemeData(
    color: LightThemeColors.outlineVariant,
    thickness: 1,
    space: 1,
  ),

  // Material Design 3 输入框主题
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightThemeColors.surfaceVariant.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: LightThemeColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: LightThemeColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: LightThemeColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: LightThemeColors.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: LightThemeColors.error, width: 2),
    ),
  ),

  // Material Design 3 悬浮按钮主题
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: LightThemeColors.primaryContainer,
    foregroundColor: LightThemeColors.onPrimaryContainer,
    elevation: 3,
    shape: const CircleBorder(),
  ),

  // Material Design 3 导航栏主题
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: LightThemeColors.surface,
    elevation: 0,
    indicatorColor: LightThemeColors.secondaryContainer,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    height: 80,
    surfaceTintColor: LightThemeColors.primary,
  ),

  // Material Design 3 进度指示器主题
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: LightThemeColors.primary,
    linearTrackColor: LightThemeColors.surfaceVariant,
    circularTrackColor: LightThemeColors.surfaceVariant,
  ),

  // Material Design 3 芯片主题
  chipTheme: ChipThemeData(
    backgroundColor: LightThemeColors.surfaceVariant,
    deleteIconColor: LightThemeColors.onSurfaceVariant,
    disabledColor: LightThemeColors.onSurface.withOpacity(0.12),
    selectedColor: LightThemeColors.secondaryContainer,
    secondarySelectedColor: LightThemeColors.tertiaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    labelStyle: TextStyle(color: LightThemeColors.onSurface),
    secondaryLabelStyle: TextStyle(color: LightThemeColors.onSurface),
    brightness: Brightness.light,
    elevation: 0,
    pressElevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide.none,
    ),
  ),

  // Material Design 3 底部Sheet主题
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: LightThemeColors.surface,
    elevation: 1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    modalBackgroundColor: LightThemeColors.surface,
    modalElevation: 3,
  ),

  // Material Design 3 对话框主题
  dialogTheme: DialogTheme(
    backgroundColor: LightThemeColors.surface,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    alignment: Alignment.center,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: LightThemeColors.onSurface,
    ),
  ),
);

/// Material Design 3 深色主题配置
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: DarkThemeColors.primary,
    onPrimary: DarkThemeColors.onPrimary,
    primaryContainer: DarkThemeColors.primaryContainer,
    onPrimaryContainer: DarkThemeColors.onPrimaryContainer,
    secondary: DarkThemeColors.secondary,
    onSecondary: DarkThemeColors.onSecondary,
    secondaryContainer: DarkThemeColors.secondaryContainer,
    onSecondaryContainer: DarkThemeColors.onSecondaryContainer,
    tertiary: DarkThemeColors.tertiary,
    onTertiary: DarkThemeColors.onTertiary,
    tertiaryContainer: DarkThemeColors.tertiaryContainer,
    onTertiaryContainer: DarkThemeColors.onTertiaryContainer,
    error: DarkThemeColors.error,
    onError: DarkThemeColors.onError,
    errorContainer: DarkThemeColors.errorContainer,
    onErrorContainer: DarkThemeColors.onErrorContainer,
    surface: DarkThemeColors.surface,
    onSurface: DarkThemeColors.onSurface,
    surfaceVariant: DarkThemeColors.surfaceVariant,
    onSurfaceVariant: DarkThemeColors.onSurfaceVariant,
    outline: DarkThemeColors.outline,
    outlineVariant: DarkThemeColors.outlineVariant,
    shadow: DarkThemeColors.shadow,
    scrim: DarkThemeColors.scrim,
    inverseSurface: DarkThemeColors.inverseSurface,
    onInverseSurface: DarkThemeColors.inverseOnSurface,
    inversePrimary: DarkThemeColors.inversePrimary,
  ),
  scaffoldBackgroundColor: DarkThemeColors.background,
  cardColor: DarkThemeColors.surface,
  dividerColor: DarkThemeColors.outlineVariant,
  hintColor: DarkThemeColors.onSurface.withOpacity(0.6),
  disabledColor: DarkThemeColors.onSurface.withOpacity(0.38),

  // Material Design 3 文字主题
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.12,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: DarkThemeColors.onSurface,
      height: 1.50,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: DarkThemeColors.onSurface,
      height: 1.43,
      letterSpacing: 0.10,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.50,
      letterSpacing: 0.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.43,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
      height: 1.33,
      letterSpacing: 0.40,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: DarkThemeColors.onSurface,
      height: 1.43,
      letterSpacing: 0.10,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: DarkThemeColors.onSurface,
      height: 1.33,
      letterSpacing: 0.50,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: DarkThemeColors.onSurface,
      height: 1.45,
      letterSpacing: 0.50,
    ),
  ),

  // Material Design 3 应用栏主题
  appBarTheme: AppBarTheme(
    backgroundColor: DarkThemeColors.surface,
    foregroundColor: DarkThemeColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 2,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
    ),
    surfaceTintColor: DarkThemeColors.primary,
  ),

  // Material Design 3 卡片主题
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: DarkThemeColors.outlineVariant),
    ),
    color: DarkThemeColors.surface,
    surfaceTintColor: DarkThemeColors.primary,
    margin: const EdgeInsets.all(0),
    clipBehavior: Clip.antiAlias,
  ),

  // Material Design 3 按钮主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkThemeColors.primary,
      foregroundColor: DarkThemeColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.10,
      ),
    ),
  ),

  // Material Design 3 填充按钮主题
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DarkThemeColors.primary,
      foregroundColor: DarkThemeColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.10,
      ),
    ),
  ),

  // Material Design 3 文本按钮主题
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DarkThemeColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.10,
      ),
    ),
  ),

  // Material Design 3 图标主题
  iconTheme: IconThemeData(
    color: DarkThemeColors.onSurface,
    size: 24,
  ),

  // Material Design 3 分割线主题
  dividerTheme: DividerThemeData(
    color: DarkThemeColors.outlineVariant,
    thickness: 1,
    space: 1,
  ),

  // Material Design 3 输入框主题
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkThemeColors.surfaceVariant.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: DarkThemeColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: DarkThemeColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: DarkThemeColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: DarkThemeColors.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: DarkThemeColors.error, width: 2),
    ),
  ),

  // Material Design 3 悬浮按钮主题
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: DarkThemeColors.primaryContainer,
    foregroundColor: DarkThemeColors.onPrimaryContainer,
    elevation: 3,
    shape: const CircleBorder(),
  ),

  // Material Design 3 导航栏主题
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: DarkThemeColors.surface,
    elevation: 0,
    indicatorColor: DarkThemeColors.secondaryContainer,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    height: 80,
    surfaceTintColor: DarkThemeColors.primary,
  ),

  // Material Design 3 进度指示器主题
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: DarkThemeColors.primary,
    linearTrackColor: DarkThemeColors.surfaceVariant,
    circularTrackColor: DarkThemeColors.surfaceVariant,
  ),

  // Material Design 3 芯片主题
  chipTheme: ChipThemeData(
    backgroundColor: DarkThemeColors.surfaceVariant,
    deleteIconColor: DarkThemeColors.onSurfaceVariant,
    disabledColor: DarkThemeColors.onSurface.withOpacity(0.12),
    selectedColor: DarkThemeColors.secondaryContainer,
    secondarySelectedColor: DarkThemeColors.tertiaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    labelStyle: TextStyle(color: DarkThemeColors.onSurface),
    secondaryLabelStyle: TextStyle(color: DarkThemeColors.onSurface),
    brightness: Brightness.dark,
    elevation: 0,
    pressElevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide.none,
    ),
  ),

  // Material Design 3 底部Sheet主题
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: DarkThemeColors.surface,
    elevation: 1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    modalBackgroundColor: DarkThemeColors.surface,
    modalElevation: 3,
  ),

  // Material Design 3 对话框主题
  dialogTheme: DialogTheme(
    backgroundColor: DarkThemeColors.surface,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    alignment: Alignment.center,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: DarkThemeColors.onSurface,
    ),
  ),
);
