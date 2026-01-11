import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../atoms/adaptive_card.dart';
import '../../../core/theme/app_colors.dart';

/// 统计卡片组件
/// 显示单一统计数据，支持动画和交互
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool animated;
  final int index;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.onTap,
    this.animated = true,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和图标
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              title,
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
    );

    if (animated) {
      content = Animate(
        effects: [
          FadeEffect(
            duration: 300.ms,
            delay: (index * 50).ms,
            curve: Curves.easeOutCubic,
          ),
          SlideEffect(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
            duration: 400.ms,
            delay: (index * 50).ms,
            curve: Curves.easeOutCubic,
          ),
        ],
        child: content,
      );
    }

    return AdaptiveCard(
      onTap: onTap,
      child: content,
    );
  }
}

/// 速度卡片（特殊样式）
class SpeedCard extends StatelessWidget {
  final double speed;
  final String unit;
  final VoidCallback? onTap;
  final bool animated;

  const SpeedCard({
    Key? key,
    required this.speed,
    this.unit = 'km/h',
    this.onTap,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.speed, size: 22, color: AppColors.speed),
            const SizedBox(width: 6),
            Text(
              '当前速度',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              speed.toStringAsFixed(0),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.speed,
                fontSize: orientation == Orientation.landscape ? 32 : 36,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              unit,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.speed,
              ),
            ),
          ],
        ),
      ],
    );

    if (animated) {
      content = Animate(
        effects: [
          FadeEffect(
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ),
          ScaleEffect(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.elasticOut,
          ),
        ],
        child: content,
      );
    }

    return AdaptiveCard(
      onTap: onTap,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A3A4A)
          : const Color(0xFFE3F2FD),
      child: content,
    );
  }
}

/// 电池卡片
class BatteryCard extends StatelessWidget {
  final int level;
  final bool charging;
  final VoidCallback? onTap;

  const BatteryCard({
    Key? key,
    required this.level,
    this.charging = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    if (charging) {
      color = AppColors.battery;
    } else if (level <= 20) {
      color = AppColors.error;
    } else if (level <= 50) {
      color = AppColors.warning;
    } else {
      color = AppColors.battery;
    }

    return TitledAdaptiveCard(
      title: '电池状态',
      icon: charging ? Icons.bolt : Icons.battery_full,
      iconColor: color,
      onTap: onTap,
      trailing: charging
          ? Animate(
              effects: [
                ShakeEffect(
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                  rotation: 0.15,
                ),
              ],
              child: Icon(Icons.bolt, color: color, size: 18),
            )
          : null,
      child: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: level / 100,
            color: color,
            backgroundColor: Colors.grey[300],
            minHeight: 10, // 使用minHeight代替height
          ),
          const SizedBox(height: 8),
          // 详细信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '剩余电量',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$level%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (charging) ...[
            const SizedBox(height: 4),
            Text(
              '正在充电...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 功率卡片
class PowerCard extends StatelessWidget {
  final double power;
  final VoidCallback? onTap;

  const PowerCard({
    Key? key,
    required this.power,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TitledAdaptiveCard(
      title: '实时功率',
      icon: Icons.bolt,
      iconColor: AppColors.power,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                power.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.power,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kW',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.power,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 功率条
          LayoutBuilder(
            builder: (context, constraints) {
              final percentage = (power / 10).clamp(0.0, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * percentage,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.power,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.power.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 温度卡片
class TemperatureCard extends StatelessWidget {
  final double temperature;
  final VoidCallback? onTap;

  const TemperatureCard({
    Key? key,
    required this.temperature,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    if (temperature >= 80) {
      color = AppColors.error;
    } else if (temperature >= 60) {
      color = AppColors.warning;
    } else {
      color = AppColors.temperature;
    }

    return TitledAdaptiveCard(
      title: '温度',
      icon: Icons.thermostat,
      iconColor: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                temperature.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '°C',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 温度指示器
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.temperature,
                  AppColors.warning,
                  AppColors.error,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: (temperature / 100).clamp(0.0, 1.0) * 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 连接状态卡片
class ConnectionCard extends StatelessWidget {
  final bool connected;
  final bool connecting;
  final String? deviceName;
  final VoidCallback? onTap;

  const ConnectionCard({
    Key? key,
    required this.connected,
    this.connecting = false,
    this.deviceName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = connecting ? '连接中' : (connected ? '已连接' : '未连接');
    final color = connecting
        ? AppColors.connecting
        : connected
            ? AppColors.connected
            : AppColors.disconnected;

    return TitledAdaptiveCard(
      title: '设备连接',
      icon: Icons.bluetooth,
      iconColor: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (deviceName != null && connected) ...[
            const SizedBox(height: 8),
            Text(
              deviceName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
          if (connecting) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}