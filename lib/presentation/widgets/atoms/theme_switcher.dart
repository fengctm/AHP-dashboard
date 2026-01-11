import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

/// 主题切换器组件
/// 提供直观的主题切换界面
class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    
    return themeMode.when(
      data: (mode) => _buildSwitcher(context, ref, mode),
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => IconButton(
        icon: const Icon(Icons.error_outline),
        onPressed: () {},
        tooltip: '主题加载失败',
      ),
    );
  }

  Widget _buildSwitcher(BuildContext context, WidgetRef ref, ThemeMode mode) {
    return PopupMenuButton<ThemeMode>(
      icon: Icon(
        _getIcon(mode),
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      onSelected: (newMode) {
        ref.read(themeNotifierProvider.notifier).setTheme(newMode);
        _showSnackBar(context, _getModeDescription(newMode));
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          ThemeMode.system,
          Icons.system_update,
          '跟随系统',
          mode == ThemeMode.system,
          '根据系统设置自动切换主题',
        ),
        _buildMenuItem(
          context,
          ThemeMode.light,
          Icons.light_mode,
          '浅色主题',
          mode == ThemeMode.light,
          '使用明亮的界面主题',
        ),
        _buildMenuItem(
          context,
          ThemeMode.dark,
          Icons.dark_mode,
          '深色主题',
          mode == ThemeMode.dark,
          '使用暗色的界面主题',
        ),
      ],
      padding: EdgeInsets.zero,
      tooltip: '切换主题',
    );
  }

  PopupMenuItem<ThemeMode> _buildMenuItem(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String title,
    bool isSelected,
    String subtitle,
  ) {
    return PopupMenuItem<ThemeMode>(
      value: mode,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  IconData _getIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.system_update;
    }
  }

  String _getModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '已切换到浅色主题';
      case ThemeMode.dark:
        return '已切换到深色主题';
      case ThemeMode.system:
        return '已切换到跟随系统';
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.palette, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// 主题切换按钮（带文字）
class ThemeSwitcherButton extends ConsumerWidget {
  const ThemeSwitcherButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeUtils = ref.watch(themeUtilsProvider);
    
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(themeNotifierProvider.notifier).toggleTheme();
      },
      icon: Icon(themeUtils.currentMode == ThemeMode.dark 
        ? Icons.light_mode 
        : Icons.dark_mode),
      label: Text(themeUtils.isSystemMode ? '切换主题' : '切换主题'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

/// 主题指示器（显示当前主题状态）
class ThemeIndicator extends ConsumerWidget {
  const ThemeIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeUtils = ref.watch(themeUtilsProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            themeUtils.currentMode == ThemeMode.dark 
              ? Icons.dark_mode 
              : Icons.light_mode,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            themeUtils.modeString.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}