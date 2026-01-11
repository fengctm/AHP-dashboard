import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 响应式卡片组件
/// 支持横竖屏适配，包含动画效果
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AdaptiveCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    // 根据屏幕尺寸调整间距
    final horizontalPadding = orientation == Orientation.landscape ? 12.0 : 16.0;

    // 根据屏幕尺寸调整圆角
    final cornerRadius = orientation == Orientation.landscape ? 8.0 : 12.0;

    return Animate(
      effects: [
        FadeEffect(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        ),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Container(
        margin: margin ?? EdgeInsets.all(orientation == Orientation.landscape ? 6.0 : 8.0),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardColor,
          borderRadius: borderRadius ?? BorderRadius.circular(cornerRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: elevation ?? (orientation == Orientation.landscape ? 2.0 : 4.0),
              offset: Offset(0, orientation == Orientation.landscape ? 1.0 : 2.0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(cornerRadius),
            child: Padding(
              padding: padding ?? EdgeInsets.all(horizontalPadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 带标题的响应式卡片
class TitledAdaptiveCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const TitledAdaptiveCard({
    Key? key,
    required this.title,
    required this.child,
    this.onTap,
    this.icon,
    this.iconColor,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return AdaptiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: orientation == Orientation.landscape ? 8 : 12),
          // 内容区域
          child,
        ],
      ),
    );
  }
}

/// 统计数据卡片
class StatAdaptiveCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatAdaptiveCard({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return AdaptiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标和标签
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 数值和单位
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: orientation == Orientation.landscape ? 22 : 24,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}