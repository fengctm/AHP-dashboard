import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 状态指示器组件
/// 用于显示连接状态、系统状态等
class StatusIndicator extends StatelessWidget {
  final StatusType type;
  final String? label;
  final bool animated;
  final double size;

  const StatusIndicator({
    Key? key,
    required this.type,
    this.label,
    this.animated = true,
    this.size = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColor(type);
    final Widget indicator = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: size,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    if (!animated) {
      return _buildContent(indicator);
    }

    return _buildAnimatedIndicator(indicator);
  }

  Widget _buildAnimatedIndicator(Widget indicator) {
    return Animate(
      effects: [
        if (type == StatusType.connecting) ...[
          FadeEffect(
            duration: 800.ms,
            curve: Curves.easeInOut,
            begin: 0.3,
            end: 1.0,
          ),
          ScaleEffect(
            duration: 800.ms,
            curve: Curves.easeInOut,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
        ],
        if (type == StatusType.connected) ...[
          ScaleEffect(
            duration: 300.ms,
            curve: Curves.elasticOut,
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            duration: 300.ms,
            curve: Curves.easeOut,
          ),
        ],
      ],
      child: indicator,
    );
  }

  Widget _buildContent(Widget indicator) {
    if (label == null) return indicator;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(width: 8),
        Text(
          label!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _getColor(type),
          ),
        ),
      ],
    );
  }

  Color _getColor(StatusType type) {
    switch (type) {
      case StatusType.connected:
        return Colors.green;
      case StatusType.connecting:
        return Colors.orange;
      case StatusType.disconnected:
        return Colors.grey;
      case StatusType.error:
        return Colors.red;
      case StatusType.warning:
        return Colors.yellow;
      case StatusType.success:
        return Colors.green;
    }
  }
}

/// 状态类型枚举
enum StatusType {
  connected,
  connecting,
  disconnected,
  error,
  warning,
  success,
}

/// 连接状态指示器
class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final String? label;

  const ConnectionIndicator({
    Key? key,
    required this.isConnected,
    this.isConnecting = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = isConnecting
        ? StatusType.connecting
        : isConnected
            ? StatusType.connected
            : StatusType.disconnected;

    final displayLabel = label ?? (isConnecting ? '连接中...' : isConnected ? '已连接' : '未连接');

    return StatusIndicator(
      type: type,
      label: displayLabel,
    );
  }
}

/// 电池状态指示器
class BatteryIndicator extends StatelessWidget {
  final int level;
  final bool charging;
  final double width;

  const BatteryIndicator({
    Key? key,
    required this.level,
    this.charging = false,
    this.width = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    if (charging) {
      color = Colors.green;
    } else if (level <= 20) {
      color = Colors.red;
    } else if (level <= 50) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Animate(
      effects: [
        if (charging) ...[
          ShakeEffect(
            duration: 1000.ms,
            curve: Curves.easeInOut,
            rotation: 0.1,
          ),
        ],
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 电池主体
          Container(
            width: width,
            height: width * 0.5,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // 电量填充
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: width * (level / 100),
                  height: width * 0.5,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 电量百分比文字
                Center(
                  child: Text(
                    '$level%',
                    style: TextStyle(
                      fontSize: width * 0.25,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 充电图标
          if (charging) ...[
            const SizedBox(width: 4),
            Icon(Icons.bolt, color: color, size: width * 0.4),
          ],
        ],
      ),
    );
  }
}

/// 信号强度指示器
class SignalIndicator extends StatelessWidget {
  final int strength; // 0-4
  final bool connected;

  const SignalIndicator({
    Key? key,
    required this.strength,
    this.connected = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!connected) {
      return const Icon(Icons.signal_wifi_off, color: Colors.grey);
    }

    final color = strength >= 3 ? Colors.green : strength >= 2 ? Colors.orange : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 4; i++)
          Container(
            width: 3,
            height: (i + 1) * 4.0,
            margin: const EdgeInsets.only(left: 1),
            decoration: BoxDecoration(
              color: i < strength ? color : Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}

/// 加载指示器
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// 进度指示器
class ProgressIndicator extends StatelessWidget {
  final double value;
  final String? label;
  final Color? color;
  final double height;

  const ProgressIndicator({
    Key? key,
    required this.value,
    this.label,
    this.color,
    this.height = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: displayColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(displayColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}