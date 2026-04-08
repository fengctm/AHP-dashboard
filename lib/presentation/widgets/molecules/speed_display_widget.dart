import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/dashboard/dashboard_provider.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../atoms/fault_indicator.dart';

class SpeedDisplayWidget extends ConsumerWidget {
  const SpeedDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isHorizontal = dashboardState.isHorizontal;

    final double currentSpeed = dashboardState.displaySpeed;
    final String speedText = currentSpeed.toStringAsFixed(0).padLeft(3, '0');
    final String unitLabel = dashboardState.speedUnitLabel;
    final bool isBraking = dashboardState.isBraking;
    final faultIndicators = _buildFaultIndicators(dashboardState);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        final double speedFontSize = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.35).clamp(56.0, 96.0)
            : 72.0;
        final double unitFontSize = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.08).clamp(14.0, 24.0)
            : 18.0;

        final double verticalPadding = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.03).clamp(4.0, 12.0)
            : 20.0;
        final double topSpacing = isHorizontal && availableHeight > 0
            ? (availableHeight * 0.02).clamp(2.0, 10.0)
            : 20.0;

        return Card.filled(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: topSpacing),
                if (isBraking)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BrakeIndicator(colorScheme: colorScheme),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      speedText,
                      style: TextStyle(
                        fontSize: speedFontSize,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'RobotoMono',
                        height: 1.0,
                        letterSpacing: -4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unitLabel,
                          style: TextStyle(
                            fontSize: unitFontSize,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<SpeedUnit>(
                  segments: const [
                    ButtonSegment<SpeedUnit>(
                      value: SpeedUnit.kmh,
                      label: Text('KM/H'),
                    ),
                    ButtonSegment<SpeedUnit>(
                      value: SpeedUnit.mph,
                      label: Text('MPH'),
                    ),
                  ],
                  selected: {dashboardState.speedUnit},
                  onSelectionChanged: (Set<SpeedUnit> newSelection) {
                    ref.read(dashboardStateProvider.notifier).toggleSpeedUnit();
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (faultIndicators.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _FaultIndicatorGroup(
                      indicators: faultIndicators,
                      colorScheme: colorScheme,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

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

class _BrakeIndicator extends StatefulWidget {
  final ColorScheme colorScheme;
  const _BrakeIndicator({required this.colorScheme});

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
        return Chip(
          avatar: Icon(
            Icons.warning_amber_rounded,
            color: widget.colorScheme.onError,
            size: 18,
          ),
          label: const Text('刹车中'),
          backgroundColor: widget.colorScheme.errorContainer,
          labelStyle: TextStyle(
            color: widget.colorScheme.onErrorContainer,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class _FaultIndicatorGroup extends StatelessWidget {
  final List<FaultIndicator> indicators;
  final ColorScheme colorScheme;

  const _FaultIndicatorGroup({required this.indicators, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: indicators.map((i) => Tooltip(
        message: i.tooltip,
        child: Chip(
          avatar: Icon(
            _getIcon(i.type),
            color: i.severity == FaultSeverity.error
                ? colorScheme.onError
                : colorScheme.onTertiary,
            size: 18,
          ),
          label: Text(_getLabel(i.type)),
          backgroundColor: i.severity == FaultSeverity.error
              ? colorScheme.errorContainer
              : colorScheme.tertiaryContainer,
          labelStyle: TextStyle(
            color: i.severity == FaultSeverity.error
                ? colorScheme.onErrorContainer
                : colorScheme.onTertiaryContainer,
            fontSize: 12,
          ),
          visualDensity: VisualDensity.compact,
        ),
      )).toList(),
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

  String _getLabel(FaultType type) {
     switch (type) {
        case FaultType.gps: return 'GPS';
        case FaultType.controller: return '控制器';
        case FaultType.bms: return '电池';
        case FaultType.temperature: return '温度';
        case FaultType.connectivity: return '连接';
     }
  }
}
