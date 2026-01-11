import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_service.dart';
import '../../core/theme/theme_config.dart';

/// 主题状态管理器
/// 使用 Riverpod 管理应用主题状态
class ThemeNotifier extends StateNotifier<AsyncValue<ThemeMode>> {
  final ThemeService _themeService;

  ThemeNotifier(this._themeService) : super(const AsyncValue.loading()) {
    _init();
  }

  /// 初始化：加载保存的主题设置
  Future<void> _init() async {
    try {
      final mode = await _themeService.loadThemeMode();
      state = AsyncValue.data(mode);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 切换主题（浅色 ↔ 深色）
  Future<void> toggleTheme() async {
    final currentMode = state.value ?? ThemeMode.system;
    ThemeMode newMode;

    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (currentMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // 如果当前是系统模式，则根据系统亮度切换
      newMode = _themeService.isSystemDarkMode() ? ThemeMode.light : ThemeMode.dark;
    }

    await setTheme(newMode);
  }

  /// 设置特定主题模式
  Future<void> setTheme(ThemeMode mode) async {
    try {
      // 先保存到本地存储
      await _themeService.saveThemeMode(mode);
      // 更新状态
      state = AsyncValue.data(mode);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 重置为系统主题
  Future<void> resetToSystem() async {
    await setTheme(ThemeMode.system);
  }

  /// 获取当前主题数据
  ThemeData getThemeData(BuildContext context) {
    final mode = state.value ?? ThemeMode.system;
    
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  /// 获取当前主题模式的描述文本
  String getThemeDescription() {
    final mode = state.value ?? ThemeMode.system;
    switch (mode) {
      case ThemeMode.light:
        return '浅色主题';
      case ThemeMode.dark:
        return '深色主题';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  /// 获取当前主题模式的图标
  IconData getThemeIcon() {
    final mode = state.value ?? ThemeMode.system;
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.system_update;
    }
  }

  /// 检查当前是否为深色模式
  bool isDarkMode(BuildContext context) {
    final mode = state.value ?? ThemeMode.system;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}

/// 主题状态提供者
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AsyncValue<ThemeMode>>((ref) {
  return ThemeNotifier(ThemeService());
});

/// 主题工具提供者（用于获取主题相关工具方法）
final themeUtilsProvider = Provider<ThemeUtils>((ref) {
  return ThemeUtils(ref);
});

/// 主题工具类
class ThemeUtils {
  final Ref _ref;

  ThemeUtils(this._ref);

  /// 获取当前主题模式
  ThemeMode get currentMode {
    return _ref.watch(themeNotifierProvider).value ?? ThemeMode.system;
  }

  /// 检查是否为深色模式
  bool isDarkMode(BuildContext context) {
    return _ref.watch(themeNotifierProvider).when(
      data: (mode) {
        if (mode == ThemeMode.dark) return true;
        if (mode == ThemeMode.light) return false;
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// 获取主题模式的字符串表示
  String get modeString {
    return currentMode.toString().split('.').last;
  }

  /// 检查是否跟随系统
  bool get isSystemMode => currentMode == ThemeMode.system;
}