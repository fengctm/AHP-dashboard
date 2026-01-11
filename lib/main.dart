import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/permission_provider.dart';
import 'core/theme/theme_config.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/permission_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return themeMode.when(
      data: (mode) {
        return MaterialApp(
          title: 'AHP Dashboard',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const PermissionWrapper(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/dashboard': (context) => const DashboardPage(),
            '/permission': (context) => const PermissionPage(),
          },
        );
      },
      loading: () {
        return const MaterialApp(
          title: 'AHP Dashboard',
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('正在初始化...'),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return MaterialApp(
          title: 'AHP Dashboard',
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  Text('初始化失败: $error'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 权限包装器组件
/// 负责检查权限并决定显示哪个页面
class PermissionWrapper extends ConsumerStatefulWidget {
  const PermissionWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends ConsumerState<PermissionWrapper> {
  bool _isChecking = true;
  bool _hasAllPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // 等待权限提供者初始化
    await Future.delayed(const Duration(milliseconds: 500));

    final permissionUtils = ref.read(permissionUtilsProvider);
    final hasPermissions = await permissionUtils.hasAllRequiredPermissions;

    if (mounted) {
      setState(() {
        _isChecking = false;
        _hasAllPermissions = hasPermissions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // 检查权限时的加载界面
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                '正在检查权限...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '请稍候',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    // 根据权限状态显示相应页面
    if (_hasAllPermissions) {
      return const DashboardPage(); // 默认使用新版本仪表盘
    } else {
      return const PermissionPage();
    }
  }
}

