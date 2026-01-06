import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../data/sources/local/database_source.dart';
import '../../../../../core/utils/logger_helper.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Logger _logger = LoggerHelper.getCoreLogger('theme_provider');

  ThemeModeNotifier() : super(ThemeMode.system) {
    _logger.info('初始化主题管理器');
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _logger.fine('加载主题设置');
    final config = await DatabaseService().getAppConfig();
    final themeMode = _stringToThemeMode(config.themeMode);
    state = themeMode;
    _logger.info('主题加载完成: $themeMode');
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _logger.info('切换主题: $state -> $newMode');
    state = newMode;
    await _saveThemeMode(newMode);
    _logger.fine('主题切换完成');
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    _logger.fine('保存主题设置: $mode');
    final config = await DatabaseService().getAppConfig();
    config.themeMode = _themeModeToString(mode);
    await DatabaseService().saveAppConfig(config);
    _logger.fine('主题设置保存完成');
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  return themeMode == ThemeMode.dark ? _darkTheme : _lightTheme;
});

final _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.grey[100],
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: Colors.black87,
    ),
  ),
);

final _darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  cardTheme: CardThemeData(
    color: Colors.grey[800],
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      color: Colors.white70,
    ),
  ),
);
