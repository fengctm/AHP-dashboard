import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题服务类
/// 负责主题设置的本地存储和读取
class ThemeService {
  static const String _themeKey = 'app_theme_mode';

  /// 保存主题模式到本地存储
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      print('保存主题设置失败: $e');
    }
  }

  /// 从本地存储加载主题模式
  Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_themeKey);

      if (modeString == null) {
        return ThemeMode.system; // 默认跟随系统
      }

      // 将字符串转换为 ThemeMode
      return ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    } catch (e) {
      print('加载主题设置失败: $e');
      return ThemeMode.system;
    }
  }

  /// 清除保存的主题设置
  Future<void> clearThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
    } catch (e) {
      print('清除主题设置失败: $e');
    }
  }

  /// 获取当前系统主题模式
  Brightness getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  /// 检查是否为深色系统主题
  bool isSystemDarkMode() {
    return getSystemBrightness() == Brightness.dark;
  }

  /// 根据主题模式和系统设置获取实际的亮度
  Brightness getActualBrightness(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return getSystemBrightness();
    }
  }
}
