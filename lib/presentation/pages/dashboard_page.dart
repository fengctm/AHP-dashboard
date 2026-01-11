import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../application/dashboard/dashboard_state.dart';
import '../../application/dashboard/dashboard_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/molecules/speed_display_widget.dart';
import '../widgets/organisms/info_section_widget.dart';
import '../widgets/atoms/theme_switcher.dart';

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
  bool _isSimulationRunning = false;

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

  /// 切换模拟数据
  void _toggleSimulation() {
    setState(() {
      _isSimulationRunning = !_isSimulationRunning;
    });

    if (_isSimulationRunning) {
      ref.read(dashboardStateProvider.notifier).startSimulation();
    } else {
      ref.read(dashboardStateProvider.notifier).stopSimulation();
    }
  }

  /// 重置数据
  void _resetData() {
    ref.read(dashboardStateProvider.notifier).reset();
    if (_isSimulationRunning) {
      ref.read(dashboardStateProvider.notifier).stopSimulation();
      setState(() {
        _isSimulationRunning = false;
      });
    }
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

        // 上部仪表盘区域 (60%)
        const Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 速度显示（已集成故障指示器）
                SpeedDisplayWidget(),
              ],
            ),
          ),
        ),

        // 下部信息区域 (40%)
        const Expanded(
          flex: 4,
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
        // 左侧仪表盘区域 (50%)
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // 顶部栏（横屏时放在左侧顶部）
              _buildTopBar(context, isDark, false),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 速度显示（已集成故障指示器）
                      SpeedDisplayWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 右侧信息区域 (50%)
        const Expanded(
          flex: 5,
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
              // 模拟按钮
              IconButton(
                icon: Icon(
                  _isSimulationRunning ? Icons.pause : Icons.play_arrow,
                  size: 20,
                  color: _isSimulationRunning
                      ? (isDark ? AppColors.warningNeon : AppColors.warning)
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                onPressed: _toggleSimulation,
                tooltip: _isSimulationRunning ? '停止模拟' : '启动模拟',
              ),

              // 重置按钮
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: _resetData,
                tooltip: '重置数据',
              ),

              // 主题切换
              const ThemeSwitcher(),
            ],
          ),
        ],
      ),
    );
  }

  /// 悬浮操作按钮
  Widget _buildFloatingActions() {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dashboardState = ref.watch(dashboardStateProvider);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模拟状态指示器
            if (_isSimulationRunning)
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
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.successNeon,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successNeon.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '模拟中',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
