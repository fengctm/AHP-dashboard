import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 自定义按钮组件
/// 支持多种样式和动画效果
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final double? height;
  final double? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.loading = false,
    this.expanded = false,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = ElevatedButton.styleFrom(
      minimumSize: Size(
        expanded ? double.infinity : 0,
        height ?? 48,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );

    final mergedStyle = baseStyle.merge(style);

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: mergedStyle,
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  mergedStyle.foregroundColor?.resolve({}) ?? Colors.white,
                ),
              ),
            )
          : Animate(
              effects: [
                ScaleEffect(
                  begin: const Offset(1, 1),
                  end: const Offset(0.98, 0.98),
                  duration: 100.ms,
                  curve: Curves.easeOut,
                ),
              ],
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
            ),
    );
  }
}

/// 主要操作按钮
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      loading: loading,
      expanded: expanded,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

/// 次要操作按钮
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      loading: loading,
      expanded: expanded,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}

/// 成功状态按钮
class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const SuccessButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// 警告状态按钮
class WarningButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const WarningButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// 危险状态按钮
class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const DangerButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// 图标按钮
class IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const IconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
          begin: const Offset(1, 1),
          end: const Offset(0.9, 0.9),
          duration: 100.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                size: size ?? 24,
                color: color ?? Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 浮动图标按钮
class FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;

  const FloatingIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      mini: true,
      child: Icon(icon, size: size ?? 20),
    );
  }
}