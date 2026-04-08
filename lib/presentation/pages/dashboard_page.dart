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

/// 菜单按钮组件
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 仪表盘主页面 - 科技感重新设计
/// 支持上下分屏、横竖屏适配、深浅色主题
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 监听屏幕方向变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOrientation();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });

    // 监听方向变化
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 更新屏幕方向状态
  void _updateOrientation() {
    final orientation = MediaQuery.of(context).orientation;
    final isHorizontal = orientation == Orientation.landscape;
    ref.read(dashboardStateProvider.notifier).updateOrientation(isHorizontal);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHorizontal = dashboardState.isHorizontal;

    // 监听方向变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOrientation();
    });

    return Scaffold(
      // 使用渐变背景
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.9),
                    AppColors.backgroundDark.withValues(alpha: 0.8),
                  ]
                : [
                    AppColors.backgroundLight,
                    AppColors.backgroundLight.withValues(alpha: 0.95),
                    AppColors.backgroundLight.withValues(alpha: 0.9),
                  ],
          ),
        ),
        child: SafeArea(
          child: isHorizontal
              ? _buildHorizontalLayout(context, dashboardState, isDark)
              : _buildVerticalLayout(context, dashboardState, isDark),
        ),
      ),

      // 悬浮操作按钮
      floatingActionButton: _buildFloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 竖屏布局 - 上下分屏
  Widget _buildVerticalLayout(
    BuildContext context,
    DashboardState state,
    bool isDark,
  ) {
    return Column(
      children: [
        // 顶部栏
        _buildTopBar(context, isDark, false),

        // 上部仪表盘区域 (45%)
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 速度显示（已集成故障指示器）
                    SpeedDisplayWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 下部信息区域 (55%)
        const Expanded(
          flex: 55,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InfoSectionWidget(),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  /// 横屏布局 - 左右分栏
  Widget _buildHorizontalLayout(
    BuildContext context,
    DashboardState state,
    bool isDark,
  ) {
    return Row(
      children: [
        // 左侧仪表盘区域 (40%) - 占满高度
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                // 速度显示（已集成故障指示器）
                SpeedDisplayWidget(),
              ],
            ),
          ),
        ),

        // 右侧信息区域 (60%)
        const Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InfoSectionWidget(),
          ),
        ),
      ],
    );
  }

  /// 顶部栏
  Widget _buildTopBar(BuildContext context, bool isDark, bool showBackButton) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题和返回按钮
          Row(
            children: [
              if (showBackButton) ...[
                // 返回旧版按钮
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    tooltip: '返回旧版',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.speed,
                color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AHP Dashboard',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          // 操作按钮组
          Row(
            children: [
              // 蓝牙状态指示
              _BluetoothStatusIndicator(),
              const SizedBox(width: 8),
              // 蓝牙连接按钮
              _BluetoothConnectButton(),
              const SizedBox(width: 8),
              // 主题切换
              const ThemeSwitcher(),
            ],
          ),
        ],
      ),
    );
  }

  /// 悬浮菜单按钮（横屏时显示）
  Widget _buildFloatingMenuButton(BuildContext context, bool isDark) {
    return FloatingActionButton(
      onPressed: () => _showMenuDialog(context, isDark),
      backgroundColor: isDark ? Colors.black54 : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 4,
      child: const Icon(Icons.menu),
    );
  }

  /// 显示菜单对话框
  void _showMenuDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black87 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AHP Dashboard',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // 功能按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MenuButton(
                    icon: Icons.arrow_back,
                    label: '返回旧版',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                  _MenuButton(
                    icon: Icons.brightness_6,
                    label: '切换主题',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      // 主题切换在 ThemeSwitcher 中处理
                    },
                  ),
                  _MenuButton(
                    icon: Icons.refresh,
                    label: '重置数据',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(dashboardStateProvider.notifier).reset();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 关闭按钮
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '关闭',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 悬浮操作按钮
  Widget _buildFloatingActions() {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dashboardState = ref.watch(dashboardStateProvider);
        final isHorizontal = dashboardState.isHorizontal;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 日志按钮（新增）
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                heroTag: 'log',
                mini: true,
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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
                child: const Icon(Icons.bug_report, size: 20),
              ),
            ),

            // 横屏时显示菜单按钮
            if (isHorizontal)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: _buildFloatingMenuButton(context, isDark),
              ),

            // GPS状态指示器
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.black54 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed,
                    size: 14,
                    color: _getGpsColor(dashboardState.gpsStatus, isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getGpsText(dashboardState.gpsStatus),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 获取GPS颜色
  Color _getGpsColor(GpsSignalStatus status, bool isDark) {
    switch (status) {
      case GpsSignalStatus.excellent:
      case GpsSignalStatus.good:
        return isDark ? AppColors.successNeon : AppColors.success;
      case GpsSignalStatus.poor:
        return isDark ? AppColors.warningNeon : AppColors.warning;
      case GpsSignalStatus.none:
        return isDark ? AppColors.errorNeon : AppColors.error;
    }
  }

  /// 获取GPS文本
  String _getGpsText(GpsSignalStatus status) {
    switch (status) {
      case GpsSignalStatus.excellent:
        return 'GPS: 优秀';
      case GpsSignalStatus.good:
        return 'GPS: 良好';
      case GpsSignalStatus.poor:
        return 'GPS: 较差';
      case GpsSignalStatus.none:
        return 'GPS: 无信号';
    }
  }
}

/// 蓝牙状态指示器
class _BluetoothStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (bluetoothState.connectionState) {
      case BleConnectionState.connected:
        statusColor = Colors.green;
        statusIcon = Icons.bluetooth_connected;
        statusText = '已连接';
        break;
      case BleConnectionState.scanning:
      case BleConnectionState.connecting:
        statusColor = Colors.orange;
        statusIcon = Icons.bluetooth_searching;
        statusText = '连接中';
        break;
      default:
        statusColor = isDark ? Colors.white54 : Colors.black54;
        statusIcon = Icons.bluetooth_disabled;
        statusText = '未连接';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black38 : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 蓝牙连接按钮
class _BluetoothConnectButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isConnected = bluetoothState.isConnected;

    return GestureDetector(
      onTap: () async {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isConnected
              ? Colors.green.withValues(alpha: 0.2)
              : (isDark ? Colors.white10 : Colors.black12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? Colors.green.withValues(alpha: 0.5)
                : (isDark ? Colors.white24 : Colors.black26),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnected ? Icons.link : Icons.link_off,
              size: 16,
              color: isConnected
                  ? Colors.green
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 4),
            Text(
              isConnected ? '断开' : '连接',
              style: TextStyle(
                color: isConnected
                    ? Colors.green
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

