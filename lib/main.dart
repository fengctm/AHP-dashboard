import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/permission_provider.dart';
import 'core/theme/theme_config.dart';
import 'core/constants/permission_constants.dart';
import 'core/utils/logging_service.dart';
import 'application/bluetooth/bluetooth_dashboard_sync.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/permission_page.dart';

void main() async {
  // 初始化日志服务
  await logger.initialize();

  runApp(
    ProviderScope(
      observers: [
        BluetoothSyncObserver(), // 添加蓝牙数据同步观察者
      ],
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
class PermissionWrapper extends ConsumerWidget {
  const PermissionWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionProvider);

    return permissionState.when(
      data: (permissions) {
        // 检查是否所有必要权限都已授予
        final hasAllRequired = PermissionGroup.required.every(
          (type) => permissions[type] == PermissionStatus.granted
        );

        if (hasAllRequired) {
          return const DashboardPage();
        } else {
          return const PermissionPage();
        }
      },
      loading: () => Scaffold(
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
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => const PermissionPage(),
    );
  }
}

