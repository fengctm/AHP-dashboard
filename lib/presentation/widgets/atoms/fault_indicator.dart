import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 故障指示器类型
enum FaultType {
  gps,           // GPS信号
  controller,    // 控制器
  bms,           // BMS电池管理
  temperature,   // 温度
  connectivity,  // 连接状态
}

/// 故障严重程度
enum FaultSeverity {
  none,      // 无故障
  warning,   // 警告
  error,     // 错误
}

/// 故障指示器组件
/// 支持动态扩展，仅在有故障时显示
class FaultIndicator extends StatelessWidget {
  /// 故障类型
  final FaultType type;
  
  /// 故障严重程度
  final FaultSeverity severity;
  
  /// 自定义图标（可选）
  final IconData? customIcon;
  
  /// 提示文本
  final String? tooltip;
  
  /// 图标大小
  final double size;
  
  /// 是否显示动画
  final bool animate;

  const FaultIndicator({
    super.key,
    required this.type,
    this.severity = FaultSeverity.none,
    this.customIcon,
    this.tooltip,
    this.size = 24,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    // 无故障时不显示
    if (severity == FaultSeverity.none) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: tooltip ?? _getTooltip(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          shape: BoxShape.circle,
          boxShadow: severity == FaultSeverity.error
              ? [
                  BoxShadow(
                    color: _getColor().withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          customIcon ?? _getIcon(),
          size: size,
          color: _getColor(),
        ),
      ),
    );
  }

  /// 获取图标
  IconData _getIcon() {
    switch (type) {
      case FaultType.gps:
        return Icons.gps_fixed;
      case FaultType.controller:
        return Icons.memory;
      case FaultType.bms:
        return Icons.battery_alert;
      case FaultType.temperature:
        return Icons.thermostat;
      case FaultType.connectivity:
        return Icons.wifi_off;
    }
  }

  /// 获取颜色
  Color _getColor() {
    switch (severity) {
      case FaultSeverity.none:
        return Colors.transparent;
      case FaultSeverity.warning:
        return AppColors.warningNeon;
      case FaultSeverity.error:
        return AppColors.errorNeon;
    }
  }

  /// 获取背景色
  Color _getBackgroundColor() {
    switch (severity) {
      case FaultSeverity.none:
        return Colors.transparent;
      case FaultSeverity.warning:
        return AppColors.warning.withValues(alpha: 0.2);
      case FaultSeverity.error:
        return AppColors.error.withValues(alpha: 0.3);
    }
  }

  /// 获取提示文本
  String _getTooltip() {
    final typeText = _getTypeText();
    final severityText = severity == FaultSeverity.warning ? '警告' : '故障';
    return '$typeText$severityText';
  }

  /// 获取类型文本
  String _getTypeText() {
    switch (type) {
      case FaultType.gps:
        return 'GPS信号';
      case FaultType.controller:
        return '控制器';
      case FaultType.bms:
        return '电池管理';
      case FaultType.temperature:
        return '温度';
      case FaultType.connectivity:
        return '连接';
    }
  }
}

/// 故障指示器组
/// 在速度显示区域显示多个故障图标
class FaultIndicatorGroup extends StatelessWidget {
  /// 故障指示器列表
  final List<FaultIndicator> indicators;
  
  /// 图标间距
  final double spacing;
  
  /// 是否水平排列
  final bool horizontal;

  const FaultIndicatorGroup({
    super.key,
    required this.indicators,
    this.spacing = 8,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    // 过滤掉无故障的指示器
    final activeIndicators = indicators.where((i) => i.severity != FaultSeverity.none).toList();
    
    if (activeIndicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(activeIndicators),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(activeIndicators),
          );
  }

  List<Widget> _buildChildren(List<FaultIndicator> indicators) {
    final children = <Widget>[];
    for (int i = 0; i < indicators.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: spacing));
      }
      children.add(indicators[i]);
    }
    return children;
  }
}
