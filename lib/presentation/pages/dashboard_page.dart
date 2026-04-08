import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../application/dashboard/dashboard_state.dart';
import '../../application/dashboard/dashboard_provider.dart';
import '../../application/bluetooth/bluetooth_provider.dart';
import '../../core/services/bluetooth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/logging_service.dart';
import '../widgets/molecules/speed_display_widget.dart';
import '../widgets/organisms/info_section_widget.dart';
import '../widgets/atoms/theme_switcher.dart';
import 'bluetooth_connect_page.dart';
import 'log_viewer_page.dart';

/// 仪表盘主页面 - Material Design 3 版本
/// 遵循 Google Material Design 3 设计规范
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // 设置支持的屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 更新屏幕方向状态
  void _updateOrientation(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isHorizontal = orientation == Orientation.landscape;
    ref.read(dashboardStateProvider.notifier).updateOrientation(isHorizontal);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    final isHorizontal = dashboardState.isHorizontal;

    // 更新方向状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOrientation(context);
    });

    return Scaffold(
      // Material Design 3 使用主题中的背景色
      body: SafeArea(
        child: isHorizontal
            ? _buildHorizontalLayout(context, dashboardState)
            : _buildVerticalLayout(context, dashboardState),
      ),
      // Material Design 3 悬浮操作按钮
      floatingActionButton: _buildFloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 竖屏布局
  Widget _buildVerticalLayout(
    BuildContext context,
    DashboardState state,
  ) {
    return CustomScrollView(
      slivers: [
        // Material Design 3 应用栏
        SliverAppBar.large(
          title: const Text('AHP Dashboard'),
          actions: [
            // 蓝牙状态指示
            _BluetoothStatusIndicator(),
            const SizedBox(width: 8),
            // 蓝牙连接按钮
            _BluetoothConnectButton(),
            const SizedBox(width: 8),
            // 主题切换
            const ThemeSwitcher(),
            const SizedBox(width: 16),
          ],
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // 速度显示
                const SizedBox(
                  height: 280,
                  child: SpeedDisplayWidget(),
                ),
                const SizedBox(height: 24),
                // 信息区域
                const SizedBox(
                  height: 400,
                  child: InfoSectionWidget(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 横屏布局
  Widget _buildHorizontalLayout(
    BuildContext context,
    DashboardState state,
  ) {
    return Row(
      children: [
        // 左侧仪表盘区域
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Material Design 3 顶部栏（横屏模式）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AHP Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Row(
                      children: [
                        _BluetoothStatusIndicator(),
                        const SizedBox(width: 8),
                        _BluetoothConnectButton(),
                        const SizedBox(width: 8),
                        const ThemeSwitcher(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 速度显示
                const Expanded(
                  child: Center(
                    child: SpeedDisplayWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 右侧信息区域
        const Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: InfoSectionWidget(),
          ),
        ),
      ],
    );
  }

  /// 悬浮操作按钮
  Widget _buildFloatingActions() {
    return Consumer(
      builder: (context, ref, child) {
        final dashboardState = ref.watch(dashboardStateProvider);
        final isHorizontal = dashboardState.isHorizontal;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 日志按钮
            FloatingActionButton.small(
              heroTag: 'log',
              onPressed: () async {
                await logger.initialize();
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogViewerPage(),
                    ),
                  );
                }
              },
              child: const Icon(Icons.bug_report),
            ),
            const SizedBox(height: 8),
            // 横屏时显示菜单按钮
            if (isHorizontal)
              FloatingActionButton.small(
                heroTag: 'menu',
                onPressed: () => _showMenuDialog(context, ref),
                child: const Icon(Icons.more_vert),
              ),
          ],
        );
      },
    );
  }

  /// 显示菜单对话框（Material Design 3 风格）
  void _showMenuDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('菜单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('重置数据'),
              onTap: () {
                Navigator.pop(context);
                ref.read(dashboardStateProvider.notifier).reset();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 蓝牙状态指示器（Material Design 3 风格）
class _BluetoothStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (bluetoothState.connectionState) {
      case BleConnectionState.connected:
        statusColor = AppColors.connected;
        statusIcon = Icons.bluetooth_connected;
        statusText = '已连接';
        break;
      case BleConnectionState.scanning:
      case BleConnectionState.connecting:
        statusColor = AppColors.connecting;
        statusIcon = Icons.bluetooth_searching;
        statusText = '连接中';
        break;
      default:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.bluetooth_disabled;
        statusText = '未连接';
    }

    // Material Design 3 芯片组件
    return Chip(
      avatar: Icon(
        statusIcon,
        size: 18,
        color: statusColor,
      ),
      label: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// 蓝牙连接按钮（Material Design 3 风格）
class _BluetoothConnectButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final theme = Theme.of(context);
    final isConnected = bluetoothState.isConnected;

    // Material Design 3 填充按钮组件
    return FilledButton.icon(
      onPressed: () async {
        if (isConnected) {
          // 断开连接
          await ref.read(bluetoothStateProvider.notifier).disconnect();
        } else {
          // 打开连接页面
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const BluetoothConnectPage(),
            ),
          );
        }
      },
      icon: Icon(isConnected ? Icons.link : Icons.link_off),
      label: Text(isConnected ? '断开' : '连接'),
      style: FilledButton.styleFrom(
        backgroundColor: isConnected
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primary,
        foregroundColor: isConnected
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onPrimary,
      ),
    );
  }
}
