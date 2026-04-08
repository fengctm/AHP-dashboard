import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/dashboard/dashboard_provider.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../../core/theme/app_colors.dart';
import '../atoms/fault_indicator.dart';

/// 速度显示组件 - 科技风格增强版 V2.0
class SpeedDisplayWidget extends ConsumerWidget {
  const SpeedDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHorizontal = dashboardState.isHorizontal;

    // --- 1. 颜色系统定义 ---
    final Color primaryColor =
        isDark ? const Color(0xFF00E5FF) : AppColors.primaryBlue; // 霓虹青 / 科技蓝
    final Color secondaryColor =
        isDark ? const Color(0xFF2979FF) : const Color(0xFF1565C0);
    final Color accentColor =
        isDark ? const Color(0xFFFF4081) : const Color(0xFFD500F9); // 强调色
    final Color surfaceColor = isDark
        ? const Color(0xFF121212).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.8);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subTextColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45;

    // 数据准备
    final double currentSpeed = dashboardState.displaySpeed;
    final double maxSpeed = 120.0; // 假设最大速度
    final double speedProgress = (currentSpeed / maxSpeed).clamp(0.0, 1.0);
    final String speedText = currentSpeed.toStringAsFixed(0).padLeft(3, '0');
    final String unitLabel = dashboardState.speedUnitLabel;
    final bool isBraking = dashboardState.isBraking;
    final faultIndicators = _buildFaultIndicators(dashboardState);

    // 使用 LayoutBuilder 动态计算尺寸
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取可用空间
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // 动态计算合适的字体大小 - 横屏时根据可用高度调整
        final double speedFontSize = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.35).clamp(56.0, 96.0)
            : 72.0;
        final double unitFontSize = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.08).clamp(14.0, 24.0)
            : 18.0;

        // 动态计算 padding - 横屏时减小padding
        final double verticalPadding = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.03).clamp(4.0, 12.0)
            : 20.0;
        final double topSpacing = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.02).clamp(2.0, 10.0)
            : 20.0;

        return Container(
          constraints: BoxConstraints(
            minHeight: isHorizontal ? 160 : 220,  // 降低横屏最小高度
            minWidth: 220,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: surfaceColor,
            border: Border.all(
              color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.1),
              width: 1.5,
            ),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- 中心数字内容 ---
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: topSpacing),
                        // 速度数值
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            // 动态数字
                            _HolographicText(
                              text: speedText,
                              fontSize: speedFontSize,
                              color: textColor,
                              glowColor: primaryColor,
                              isDark: isDark,
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
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 装饰线
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: 80,
                            height: 2,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withValues(alpha: 0.0),
                                    primaryColor,
                                    primaryColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 底部切换器
                        _TechUnitToggle(
                          isKmh: dashboardState.speedUnit == SpeedUnit.kmh,
                          isDark: isDark,
                          activeColor: primaryColor,
                          onToggle: () => ref
                              .read(dashboardStateProvider.notifier)
                              .toggleSpeedUnit(),
                        ),
                      ],
                    ),
                  ),

                  // --- 刹车指示 ---
                  if (isBraking)
                    Positioned(
                      top: 20,
                      child: _BrakeIndicator(accentColor: accentColor),
                    ),

                  // --- 故障指示 ---
                  if (faultIndicators.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      child: _FaultIndicatorGroup(
                        indicators: faultIndicators,
                        isDark: isDark,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (保留原有的 _buildFaultIndicators 和相关 helper 方法)
  List<FaultIndicator> _buildFaultIndicators(DashboardState state) {
    final indicators = <FaultIndicator>[];

    final gpsSeverity = _getGpsSeverity(state.gpsStatus);
    if (gpsSeverity != FaultSeverity.none) {
      indicators.add(FaultIndicator(
        type: FaultType.gps,
        severity: gpsSeverity,
        tooltip: _getGpsTooltip(state.gpsStatus),
      ));
    }

    final controllerSeverity = _getControllerSeverity(state.controller);
    if (controllerSeverity != FaultSeverity.none) {
      indicators.add(FaultIndicator(
        type: FaultType.controller,
        severity: controllerSeverity,
        tooltip: _getControllerTooltip(state.controller),
      ));
    }

    final bmsSeverity = _getBmsSeverity(state.bms);
    if (bmsSeverity != FaultSeverity.none) {
      indicators.add(FaultIndicator(
        type: FaultType.bms,
        severity: bmsSeverity,
        tooltip: _getBmsTooltip(state.bms),
      ));
    }

    final tempSeverity = _getTemperatureSeverity(state.controller.temperature);
    if (tempSeverity != FaultSeverity.none) {
      indicators.add(FaultIndicator(
        type: FaultType.temperature,
        severity: tempSeverity,
        tooltip: '控制器温度过高: ${state.controller.temperature}°C',
      ));
    }

    return indicators;
  }

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

  FaultSeverity _getControllerSeverity(ControllerStatus controller) {
    if (controller.level == FaultLevel.error) {
      return FaultSeverity.error;
    }
    if (controller.level == FaultLevel.warning || controller.temperature > 80) {
      return FaultSeverity.warning;
    }
    return FaultSeverity.none;
  }

  String _getControllerTooltip(ControllerStatus controller) {
    if (controller.level == FaultLevel.error) return '控制器故障';
    if (controller.level == FaultLevel.warning || controller.temperature > 80) {
      return '控制器温度警告: ${controller.temperature}°C';
    }
    return '控制器正常';
  }

  FaultSeverity _getBmsSeverity(BmsStatus bms) {
    if (bms.level == FaultLevel.error) {
      return FaultSeverity.error;
    }
    if (bms.level == FaultLevel.warning || bms.batteryLevel < 20) {
      return FaultSeverity.warning;
    }
    return FaultSeverity.none;
  }

  String _getBmsTooltip(BmsStatus bms) {
    if (bms.level == FaultLevel.error) {
      return '电池管理系统故障';
    }
    if (bms.level == FaultLevel.warning || bms.batteryLevel < 20) {
      return '电量低: ${bms.batteryLevel}%';
    }
    return '电池正常';
  }

  FaultSeverity _getTemperatureSeverity(double temperature) {
    if (temperature > 90) {
      return FaultSeverity.error;
    }
    if (temperature > 80) {
      return FaultSeverity.warning;
    }
    return FaultSeverity.none;
  }
}

/// 仪表盘绘制器
class _SpeedGaugePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  _SpeedGaugePainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 适配横竖屏，取较小边作为直径参考，并留出padding
    final radius = math.min(size.width, size.height) / 2 - 10;
    const startAngle = 135 * math.pi / 180;
    const sweepAngle = 270 * math.pi / 180;

    // 1. 绘制背景轨道
    final trackPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. 绘制进度条 (渐变)
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [secondaryColor, primaryColor, if (progress > 0.8) Colors.redAccent else primaryColor],
      stops: const [0.0, 0.7, 1.0],
      transform: GradientRotation(math.pi / 2), // 稍微旋转以匹配 startAngle
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    // 只有当有速度时才绘制
    if (progress > 0.01) {
       // 添加发光效果
      if (isDark) {
        final glowPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        
         canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle * progress,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        progressPaint,
      );
    }

    // 3. 绘制刻度线
    final tickPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 2;

    final activeTickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..strokeWidth = 2;

    const int totalTicks = 40;
    final double tickRadius = radius - 20;
    final double tickLength = 8;

    for (int i = 0; i <= totalTicks; i++) {
      final double angle = startAngle + (sweepAngle * i / totalTicks);
      final bool isActive = (i / totalTicks) <= progress;
      
      final p1 = Offset(
        center.dx + math.cos(angle) * tickRadius,
        center.dy + math.sin(angle) * tickRadius,
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * (tickRadius - tickLength),
        center.dy + math.sin(angle) * (tickRadius - tickLength),
      );

      canvas.drawLine(p1, p2, isActive ? activeTickPaint : tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.isDark != isDark;
  }
}

/// 带有全息/霓虹效果的文字
class _HolographicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color glowColor;
  final bool isDark;

  const _HolographicText({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.glowColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        fontFamily: 'RobotoMono', // 使用等宽字体
        height: 1.0,
        letterSpacing: -4,
        shadows: isDark
            ? [
                Shadow(
                  color: glowColor.withValues(alpha: 0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
                Shadow(
                  color: glowColor.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 0),
                ),
              ]
            : [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
      ),
    );
  }
}

/// 科技风格单位切换器
class _TechUnitToggle extends StatelessWidget {
  final bool isKmh;
  final bool isDark;
  final Color activeColor;
  final VoidCallback onToggle;

  const _TechUnitToggle({
    required this.isKmh,
    required this.isDark,
    required this.activeColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UnitChip(label: 'KM/H', isActive: isKmh, activeColor: activeColor, isDark: isDark),
              _UnitChip(label: 'MPH', isActive: !isKmh, activeColor: activeColor, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final bool isDark;

  const _UnitChip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive
            ? [BoxShadow(color: activeColor.withValues(alpha: 0.4), blurRadius: 8)]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? (isDark ? Colors.black : Colors.white)
              : (isDark ? Colors.white54 : Colors.black54),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 刹车指示器
class _BrakeIndicator extends StatefulWidget {
  final Color accentColor;
  const _BrakeIndicator({required this.accentColor});

  @override
  State<_BrakeIndicator> createState() => _BrakeIndicatorState();
}

class _BrakeIndicatorState extends State<_BrakeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.6 * _controller.value),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'BRAKE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaultIndicatorGroup extends StatelessWidget {
  final List<FaultIndicator> indicators;
  final bool isDark;

  const _FaultIndicatorGroup({required this.indicators, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: indicators.map((i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            _getIcon(i.type),
            color: i.severity == FaultSeverity.error ? Colors.red : Colors.orange,
            size: 20,
          ),
        )).toList(),
      ),
    );
  }

  IconData _getIcon(FaultType type) {
     switch (type) {
        case FaultType.gps: return Icons.gps_off;
        case FaultType.controller: return Icons.memory;
        case FaultType.bms: return Icons.battery_alert;
        case FaultType.temperature: return Icons.thermostat;
        case FaultType.connectivity: return Icons.cloud_off;
     }
  }
}
