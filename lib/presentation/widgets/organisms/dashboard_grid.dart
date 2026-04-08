import 'package:flutter/material.dart';
import '../molecules/stat_card.dart';
import '../atoms/responsive_builder.dart';
import '../../../core/theme/app_colors.dart';

/// 仪表盘网格组件
/// 组合多个统计卡片，支持响应式布局
class DashboardGrid extends StatelessWidget {
  final List<DashboardItem> items;
  final bool animated;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const DashboardGrid({
    Key? key,
    required this.items,
    this.animated = true,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        final crossAxisCount = layout.isLandscape ? 4 : 2;
        final childAspectRatio = layout.isLandscape ? 1.5 : 1.3;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: crossAxisSpacing ?? 12,
            mainAxisSpacing: mainAxisSpacing ?? 12,
          ),
          itemCount: items.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildCard(context, item, index);
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, DashboardItem item, int index) {
    switch (item.type) {
      case DashboardItemType.speed:
        return SpeedCard(
          speed: item.value ?? 0,
          unit: item.unit ?? 'km/h',
          animated: animated,
          onTap: item.onTap,
        );

      case DashboardItemType.battery:
        return BatteryCard(
          level: item.value?.toInt() ?? 0,
          charging: item.charging ?? false,
          onTap: item.onTap,
        );

      case DashboardItemType.power:
        return PowerCard(
          power: item.value ?? 0,
          onTap: item.onTap,
        );

      case DashboardItemType.temperature:
        return TemperatureCard(
          temperature: item.value ?? 0,
          onTap: item.onTap,
        );

      case DashboardItemType.connection:
        return ConnectionCard(
          connected: item.connected ?? false,
          connecting: item.connecting ?? false,
          deviceName: item.label,
          onTap: item.onTap,
        );

      default:
        return StatCard(
          title: item.label ?? '数据',
          value: item.value?.toString() ?? '0',
          unit: item.unit ?? '',
          icon: item.icon ?? Icons.show_chart,
          color: item.color ?? AppColors.primary,
          animated: animated,
          index: index,
          onTap: item.onTap,
        );
    }
  }
}

/// 仪表盘项目类型
enum DashboardItemType {
  speed,
  battery,
  power,
  temperature,
  connection,
  custom,
}

/// 仪表盘项目数据
class DashboardItem {
  final DashboardItemType type;
  final String? label;
  final double? value;
  final String? unit;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  // 特殊字段
  final bool? charging;
  final bool? connected;
  final bool? connecting;

  const DashboardItem({
    required this.type,
    this.label,
    this.value,
    this.unit,
    this.icon,
    this.color,
    this.onTap,
    this.charging,
    this.connected,
    this.connecting,
  });

  // 工厂构造函数
  factory DashboardItem.speed({
    required double speed,
    String unit = 'km/h',
    VoidCallback? onTap,
  }) {
    return DashboardItem(
      type: DashboardItemType.speed,
      value: speed,
      unit: unit,
      onTap: onTap,
    );
  }

  factory DashboardItem.battery({
    required int level,
    bool charging = false,
    VoidCallback? onTap,
  }) {
    return DashboardItem(
      type: DashboardItemType.battery,
      value: level.toDouble(),
      charging: charging,
      onTap: onTap,
    );
  }

  factory DashboardItem.power({
    required double power,
    VoidCallback? onTap,
  }) {
    return DashboardItem(
      type: DashboardItemType.power,
      value: power,
      unit: 'kW',
      onTap: onTap,
    );
  }

  factory DashboardItem.temperature({
    required double temperature,
    VoidCallback? onTap,
  }) {
    return DashboardItem(
      type: DashboardItemType.temperature,
      value: temperature,
      unit: '°C',
      onTap: onTap,
    );
  }

  factory DashboardItem.connection({
    required bool connected,
    bool connecting = false,
    String? deviceName,
    VoidCallback? onTap,
  }) {
    return DashboardItem(
      type: DashboardItemType.connection,
      connected: connected,
      connecting: connecting,
      label: deviceName,
      onTap: onTap,
    );
  }

  factory DashboardItem.custom({
    required String label,
    required double value,
    required String unit,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return DashboardItem(
      type: DashboardItemType.custom,
      label: label,
      value: value,
      unit: unit,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}

/// 仪表盘分组组件
class DashboardGroup extends StatelessWidget {
  final String title;
  final List<DashboardItem> items;
  final IconData? icon;
  final bool animated;

  const DashboardGroup({
    Key? key,
    required this.title,
    required this.items,
    this.icon,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 组标题
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 网格内容
        DashboardGrid(
          items: items,
          animated: animated,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 仪表盘视图（完整页面布局）
class DashboardView extends StatelessWidget {
  final List<DashboardGroup> groups;
  final Widget? header;
  final Widget? footer;
  final ScrollController? controller;

  const DashboardView({
    Key? key,
    required this.groups,
    this.header,
    this.footer,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 16),
          ],
          ...groups.expand((group) => [group, const SizedBox(height: 8)]).toList(),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}