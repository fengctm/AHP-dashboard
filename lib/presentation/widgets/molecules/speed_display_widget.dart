import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../../application/dashboard/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../atoms/adaptive_card.dart';
import '../atoms/fault_indicator.dart';

/// 速度显示组件 - 支持主题适配和横竖屏，集成故障指示器
class SpeedDisplayWidget extends ConsumerWidget {
  const SpeedDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHorizontal = dashboardState.isHorizontal;

    // 获取颜色
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final accentColor = isDark ? AppColors.cyanNeon : AppColors.primaryBlue;
    final glowColor = isDark ? AppColors.cyanNeon.withValues(alpha: 0.5) : Colors.transparent;

    // 根据横竖屏调整字体大小
    final speedFontSize = isHorizontal ? 140.0 : 80.0;
    final unitFontSize = isHorizontal ? 24.0 : 16.0;
    final labelFontSize = isHorizontal ? 16.0 : 12.0;

    // 速度值（已转换单位）
    final displaySpeed = dashboardState.displaySpeed;
    final speedText = displaySpeed.toStringAsFixed(0).padLeft(3, '0');
    final unitLabel = dashboardState.speedUnitLabel;

    // 刹车状态
    final isBraking = dashboardState.isBraking;

    // 构建故障指示器列表
    final faultIndicators = _buildFaultIndicators(dashboardState);

    return AdaptiveCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: isDark ? 8 : 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 速度显示区域
          Stack(
            alignment: Alignment.center,
            children: [
              // 发光效果（深色主题）
              if (isDark)
                Container(
                  width: double.infinity,
                  height: speedFontSize + 20,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        glowColor,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

              // 速度数字
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // 数字部分
                  Text(
                    speedText,
                    style: TextStyle(
                      fontSize: speedFontSize,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      fontFamily: 'RobotoMono',
                      height: 1.0,
                      shadows: isDark
                          ? [
                              Shadow(
                                color: glowColor,
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: glowColor,
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                              ),
                            ]
                          : [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 单位
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unitLabel,
                        style: TextStyle(
                          fontSize: unitFontSize,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          height: 1.0,
                        ),
                      ),
                      if (isHorizontal) const SizedBox(height: 4),
                      if (isHorizontal)
                        Text(
                          'SPEED',
                          style: TextStyle(
                            fontSize: labelFontSize,
                            color: textColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // 刹车指示器（覆盖在速度上）
              if (isBraking)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'BRAKE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 故障指示器（右上角）
              if (faultIndicators.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: FaultIndicatorGroup(
                    indicators: faultIndicators,
                    spacing: 4,
                    horizontal: true,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 单位切换按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUnitToggle(
                context: context,
                label: 'KMH',
                isActive: dashboardState.speedUnit == SpeedUnit.kmh,
                onTap: () => ref.read(dashboardStateProvider.notifier).toggleSpeedUnit(),
              ),
              const SizedBox(width: 12),
              _buildUnitToggle(
                context: context,
                label: 'MPH',
                isActive: dashboardState.speedUnit == SpeedUnit.mph,
                onTap: () => ref.read(dashboardStateProvider.notifier).toggleSpeedUnit(),
              ),
            ],
          ),

          if (!isHorizontal) const SizedBox(height: 8),

          // 速度状态标签
          if (!isHorizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.speed,
                  size: 14,
                  color: textColor.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '实时速度',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 构建故障指示器列表
  List<FaultIndicator> _buildFaultIndicators(DashboardState state) {
    final indicators = <FaultIndicator>[];

    // GPS 故障指示
    final gpsSeverity = _getGpsSeverity(state.gpsStatus);
    if (gpsSeverity != FaultSeverity.none) {
      indicators.add(
        FaultIndicator(
          type: FaultType.gps,
          severity: gpsSeverity,
          tooltip: _getGpsTooltip(state.gpsStatus),
        ),
      );
    }

    // 控制器故障指示
    final controllerSeverity = _getControllerSeverity(state.controller);
    if (controllerSeverity != FaultSeverity.none) {
      indicators.add(
        FaultIndicator(
          type: FaultType.controller,
          severity: controllerSeverity,
          tooltip: _getControllerTooltip(state.controller),
        ),
      );
    }

    // BMS 故障指示
    final bmsSeverity = _getBmsSeverity(state.bms);
    if (bmsSeverity != FaultSeverity.none) {
      indicators.add(
        FaultIndicator(
          type: FaultType.bms,
          severity: bmsSeverity,
          tooltip: _getBmsTooltip(state.bms),
        ),
      );
    }

    // 温度故障指示
    final tempSeverity = _getTemperatureSeverity(state.controller.temperature);
    if (tempSeverity != FaultSeverity.none) {
      indicators.add(
        FaultIndicator(
          type: FaultType.temperature,
          severity: tempSeverity,
          tooltip: '控制器温度过高: ${state.controller.temperature}°C',
        ),
      );
    }

    return indicators;
  }

  /// 获取 GPS 严重程度
  FaultSeverity _getGpsSeverity(GpsSignalStatus status) {
    switch (status) {
      case GpsSignalStatus.excellent:
      case GpsSignalStatus.good:
        return FaultSeverity.none;
      case GpsSignalStatus.poor:
        return FaultSeverity.warning;
      case GpsSignalStatus.none:
        return FaultSeverity.error;
    }
  }

  /// 获取 GPS 提示文本
  String _getGpsTooltip(GpsSignalStatus status) {
    switch (status) {
      case GpsSignalStatus.excellent:
        return 'GPS信号优秀';
      case GpsSignalStatus.good:
        return 'GPS信号良好';
      case GpsSignalStatus.poor:
        return 'GPS信号较差';
      case GpsSignalStatus.none:
        return 'GPS无信号';
    }
  }

  /// 获取控制器严重程度
  FaultSeverity _getControllerSeverity(ControllerStatus controller) {
    if (controller.level == FaultLevel.error) {
      return FaultSeverity.error;
    }
    if (controller.level == FaultLevel.warning || controller.temperature > 80) {
      return FaultSeverity.warning;
    }
    return FaultSeverity.none;
  }

  /// 获取控制器提示文本
  String _getControllerTooltip(ControllerStatus controller) {
    if (controller.level == FaultLevel.error) {
      return '控制器故障';
    }
    if (controller.level == FaultLevel.warning || controller.temperature > 80) {
      return '控制器温度警告: ${controller.temperature}°C';
    }
    return '控制器正常';
  }

  /// 获取 BMS 严重程度
  FaultSeverity _getBmsSeverity(BmsStatus bms) {
    if (bms.level == FaultLevel.error) {
      return FaultSeverity.error;
    }
    if (bms.level == FaultLevel.warning || bms.batteryLevel < 20) {
      return FaultSeverity.warning;
    }
    return FaultSeverity.none;
  }

  /// 获取 BMS 提示文本
  String _getBmsTooltip(BmsStatus bms) {
    if (bms.level == FaultLevel.error) {
      return '电池管理系统故障';
    }
    if (bms.level == FaultLevel.warning || bms.batteryLevel < 20) {
      return '电量低: ${bms.batteryLevel}%';
    }
    return '电池正常';
  }

  /// 获取温度严重程度
  FaultSeverity _getTemperatureSeverity(double temperature) {
    if (temperature > 90) {
      return FaultSeverity.error;
    }
    if (temperature > 80) {
      return FaultSeverity.warning;
    }
    return FaultSeverity.none;
  }

  /// 构建单位切换按钮
  Widget _buildUnitToggle({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.cyanNeon : AppColors.primaryBlue)
                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? (isDark ? AppColors.cyanNeon : AppColors.primaryBlue)
                  : (isDark ? Colors.white24 : Colors.black12),
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (isDark ? AppColors.cyanNeon : AppColors.primaryBlue)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
