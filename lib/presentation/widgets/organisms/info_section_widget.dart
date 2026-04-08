import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/dashboard/dashboard_provider.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../../core/theme/app_colors.dart';
import '../atoms/adaptive_card.dart';

/// 信息区域组件 - Material Design 3 版本
/// 可折叠的多模块信息展示
class InfoSectionWidget extends ConsumerWidget {
  const InfoSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHorizontal = dashboardState.isHorizontal;
    final isExpanded = dashboardState.isInfoSectionExpanded;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 折叠栏头
          _buildHeader(context, ref, theme, isExpanded),

          // 展开的内容
          if (isExpanded)
            Flexible(
              fit: FlexFit.loose,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 模块网格
                            isHorizontal
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: _buildControllerCard(
                                              context, dashboardState)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: _buildBmsCard(
                                              context, dashboardState)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: _buildTripCard(
                                              context, dashboardState)),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildControllerCard(
                                          context, dashboardState),
                                      const SizedBox(height: 12),
                                      _buildBmsCard(context, dashboardState),
                                      const SizedBox(height: 12),
                                      _buildTripCard(context, dashboardState),
                                    ],
                                  ),

                            const SizedBox(height: 12),

                            // 拓展模块
                            _buildExtensionsCard(context, dashboardState),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    bool isExpanded,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            ref.read(dashboardStateProvider.notifier).toggleInfoSection(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '详细信息',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  key: ValueKey(isExpanded),
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建控制器卡片（Material Design 3 风格）
  Widget _buildControllerCard(
    BuildContext context,
    DashboardState state,
  ) {
    final controller = state.controller;
    final theme = Theme.of(context);
    final isHorizontal = state.isHorizontal;

    return TitledAdaptiveCard(
      title: '控制器',
      icon: Icons.memory,
      iconColor: _getLevelColor(controller.level, theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 型号和产品编号
          if (state.modelName != null || state.serialNumber != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card.filled(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.modelName != null)
                        _InfoRow(
                          label: '型号',
                          value: state.modelName!,
                          theme: theme,
                        ),
                      if (state.serialNumber != null) ...[
                        if (state.modelName != null) const SizedBox(height: 4),
                        _InfoRow(
                          label: '编号',
                          value: state.serialNumber!,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],

          // 其他控制器数据
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: isHorizontal ? 1.6 : 1.3,
            children: [
              _InfoTile(
                icon: Icons.thermostat_outlined,
                label: '温度',
                value: controller.temperature.toStringAsFixed(1),
                unit: '°C',
                iconColor: AppColors.temperature,
                theme: theme,
                isHorizontal: isHorizontal,
              ),
              _InfoTile(
                icon: Icons.electrical_services_outlined,
                label: '电压',
                value: controller.voltage.toStringAsFixed(1),
                unit: 'V',
                iconColor: AppColors.power,
                theme: theme,
                isHorizontal: isHorizontal,
              ),
              _InfoTile(
                icon: Icons.bolt_outlined,
                label: '电流',
                value: controller.current.toStringAsFixed(1),
                unit: 'A',
                iconColor: AppColors.power,
                theme: theme,
                isHorizontal: isHorizontal,
              ),
              _InfoTile(
                icon: Icons.rotate_right_outlined,
                label: '转速',
                value: '${controller.rpm}',
                unit: 'RPM',
                iconColor: AppColors.speed,
                theme: theme,
                isHorizontal: isHorizontal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建BMS卡片（Material Design 3 风格）
  Widget _buildBmsCard(
    BuildContext context,
    DashboardState state,
  ) {
    final bms = state.bms;
    final theme = Theme.of(context);
    final isHorizontal = state.isHorizontal;

    return TitledAdaptiveCard(
      title: '电池管理',
      icon: Icons.battery_std_outlined,
      iconColor: _getLevelColor(bms.level, theme),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: isHorizontal ? 1.6 : 1.3,
        children: [
          _InfoTile(
            icon: Icons.battery_full_outlined,
            label: '电量',
            value: bms.batteryLevel.toStringAsFixed(0),
            unit: '%',
            iconColor: AppColors.battery,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.route_outlined,
            label: '续航',
            value: bms.remainingRange.toStringAsFixed(0),
            unit: 'km',
            iconColor: SemanticColors.success,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.device_thermostat_outlined,
            label: '电芯温',
            value: bms.cellTemp.toStringAsFixed(1),
            unit: '°C',
            iconColor: AppColors.temperature,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.power_outlined,
            label: '总电压',
            value: bms.voltage.toStringAsFixed(1),
            unit: 'V',
            iconColor: AppColors.power,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
        ],
      ),
    );
  }

  /// 构建行程卡片（Material Design 3 风格）
  Widget _buildTripCard(
    BuildContext context,
    DashboardState state,
  ) {
    final trip = state.trip;
    final theme = Theme.of(context);
    final isHorizontal = state.isHorizontal;

    return TitledAdaptiveCard(
      title: '行程信息',
      icon: Icons.route_outlined,
      iconColor: theme.colorScheme.primary,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: isHorizontal ? 1.6 : 1.3,
        children: [
          _InfoTile(
            icon: Icons.speed_outlined,
            label: '总里程',
            value: trip.totalDistance.toStringAsFixed(1),
            unit: 'km',
            iconColor: theme.colorScheme.primary,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.trip_origin_outlined,
            label: '本次行程',
            value: trip.tripDistance.toStringAsFixed(1),
            unit: 'km',
            iconColor: theme.colorScheme.tertiary,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.speed_outlined,
            label: '平均速度',
            value: trip.avgSpeed.toStringAsFixed(1),
            unit: 'km/h',
            iconColor: AppColors.speed,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.flash_on_outlined,
            label: '最大速度',
            value: trip.maxSpeed.toStringAsFixed(1),
            unit: 'km/h',
            iconColor: AppColors.power,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
          _InfoTile(
            icon: Icons.battery_charging_full_outlined,
            label: '能耗',
            value: trip.energyUsed.toStringAsFixed(1),
            unit: 'kWh/100km',
            iconColor: AppColors.battery,
            theme: theme,
            isHorizontal: isHorizontal,
          ),
        ],
      ),
    );
  }

  /// 构建拓展模块卡片（Material Design 3 风格）
  Widget _buildExtensionsCard(
    BuildContext context,
    DashboardState state,
  ) {
    final theme = Theme.of(context);

    if (state.extensions.isEmpty) return const SizedBox.shrink();

    return TitledAdaptiveCard(
      title: '拓展模块',
      icon: Icons.widgets_outlined,
      iconColor: theme.colorScheme.tertiary,
      child: Column(
        children: state.extensions.map((ext) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _ExtensionRow(
              name: ext.name,
              connected: ext.connected,
              info: ext.additionalInfo,
              theme: theme,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 获取级别对应颜色
  Color _getLevelColor(FaultLevel level, ThemeData theme) {
    switch (level) {
      case FaultLevel.normal:
        return theme.colorScheme.primary;
      case FaultLevel.warning:
        return SemanticColors.warning;
      case FaultLevel.error:
        return AppColors.error;
    }
  }
}

/// 信息行组件（Material Design 3 风格）
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 信息磁贴组件（Material Design 3 风格）
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color iconColor;
  final ThemeData theme;
  final bool isHorizontal;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    required this.iconColor,
    required this.theme,
    required this.isHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isHorizontal ? 18.0 : 20.0;
    final labelFontSize = isHorizontal ? 10.0 : 11.0;
    final valueFontSize = isHorizontal ? 15.0 : 17.0;
    final unitFontSize = isHorizontal ? 10.0 : 11.0;

    return Card.filled(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(isHorizontal ? 10.0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: labelFontSize,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(height: 2),
              Text(
                unit!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: unitFontSize,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 拓展模块行组件（Material Design 3 风格）
class _ExtensionRow extends StatelessWidget {
  final String name;
  final bool connected;
  final String? info;
  final ThemeData theme;

  const _ExtensionRow({
    required this.name,
    required this.connected,
    this.info,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = connected
        ? AppColors.connected
        : theme.colorScheme.error;
    final statusText = connected ? '已连接' : '未连接';

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        connected ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: statusColor,
      ),
      title: Text(
        name,
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (info != null) ...[
            Text(
              info!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            statusText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
