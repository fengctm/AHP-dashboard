import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/dashboard/dashboard_provider.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../../core/theme/app_colors.dart';
import '../atoms/adaptive_card.dart';

/// 信息区域组件 - 可折叠的多模块信息展示
class InfoSectionWidget extends ConsumerWidget {
  const InfoSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHorizontal = dashboardState.isHorizontal;
    final isExpanded = dashboardState.isInfoSectionExpanded;

    return AdaptiveCard(
      padding: EdgeInsets.zero,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: isDark ? 8 : 4,
      child: Column(
        children: [
          // 折叠栏头
          _buildHeader(context, ref, isDark, isExpanded, isHorizontal),

          // 展开的内容 - 使用 Expanded 包装以适应父容器
          if (isExpanded)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 模块网格
                          isHorizontal
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: _buildControllerCard(
                                              context, dashboardState, isDark)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: _buildBmsCard(
                                              context, dashboardState, isDark)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: _buildTripCard(
                                              context, dashboardState, isDark)),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildControllerCard(
                                          context, dashboardState, isDark),
                                      const SizedBox(height: 8),
                                      _buildBmsCard(
                                          context, dashboardState, isDark),
                                      const SizedBox(height: 8),
                                      _buildTripCard(
                                          context, dashboardState, isDark),
                                    ],
                                  ),
                                ),

                          const SizedBox(height: 8),

                          // 拓展模块
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildExtensionsCard(
                                context, dashboardState, isDark),
                          ),
                        ],
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
    bool isDark,
    bool isExpanded,
    bool isHorizontal,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            ref.read(dashboardStateProvider.notifier).toggleInfoSection(),
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(12),
          bottom: isExpanded ? Radius.zero : const Radius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: isExpanded
                  ? BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '详细信息',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isHorizontal)
                    Text(
                      '横屏模式',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      key: ValueKey(isExpanded),
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建控制器卡片
  Widget _buildControllerCard(
      BuildContext context, DashboardState state, bool isDark) {
    final controller = state.controller;
    final color = _getLevelColor(controller.level, isDark);

    return _InfoCard(
      title: '控制器',
      icon: Icons.memory,
      iconColor: color,
      isDark: isDark,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: state.isHorizontal ? 1.5 : 1.4,
        children: [
          _InfoTile(
            icon: Icons.thermostat,
            label: '温度',
            value: controller.temperature.toStringAsFixed(1),
            unit: '°C',
            iconColor: AppColors.temperature,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.electrical_services,
            label: '电压',
            value: controller.voltage.toStringAsFixed(1),
            unit: 'V',
            iconColor: AppColors.power,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.bolt,
            label: '电流',
            value: controller.current.toStringAsFixed(1),
            unit: 'A',
            iconColor: AppColors.power,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.rotate_right,
            label: '转速',
            value: '${controller.rpm}',
            unit: 'RPM',
            iconColor: AppColors.speed,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
        ],
      ),
    );
  }

  /// 构建BMS卡片
  Widget _buildBmsCard(
      BuildContext context, DashboardState state, bool isDark) {
    final bms = state.bms;
    final color = _getLevelColor(bms.level, isDark);

    return _InfoCard(
      title: '电池管理',
      icon: Icons.battery_std,
      iconColor: color,
      isDark: isDark,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: state.isHorizontal ? 1.5 : 1.4,
        children: [
          _InfoTile(
            icon: Icons.battery_full,
            label: '电量',
            value: bms.batteryLevel.toStringAsFixed(0),
            unit: '%',
            iconColor: AppColors.battery,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.route,
            label: '续航',
            value: bms.remainingRange.toStringAsFixed(0),
            unit: 'km',
            iconColor: AppColors.success,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.device_thermostat,
            label: '电芯温',
            value: bms.cellTemp.toStringAsFixed(1),
            unit: '°C',
            iconColor: AppColors.temperature,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.power,
            label: '总电压',
            value: bms.voltage.toStringAsFixed(1),
            unit: 'V',
            iconColor: AppColors.power,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
        ],
      ),
    );
  }

  /// 构建行程卡片
  Widget _buildTripCard(
      BuildContext context, DashboardState state, bool isDark) {
    final trip = state.trip;
    // 横竖屏统一使用2列布局,与控制器、电池卡片保持一致
    final crossAxisCount = 2;

    return _InfoCard(
      title: '行程信息',
      icon: Icons.route,
      iconColor: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
      isDark: isDark,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        // 横屏使用1.5与控制器、电池卡片统一,竖屏保持1.4
        childAspectRatio: state.isHorizontal ? 1.5 : 1.4,
        children: [
          _InfoTile(
            icon: Icons.speed,
            label: '总里程',
            value: trip.totalDistance.toStringAsFixed(1),
            unit: 'km',
            iconColor: AppColors.primary,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.trip_origin,
            label: '本次行程',
            value: trip.tripDistance.toStringAsFixed(1),
            unit: 'km',
            iconColor: isDark ? AppColors.cyanNeon : AppColors.speed,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.speed,
            label: '平均速度',
            value: trip.avgSpeed.toStringAsFixed(1),
            unit: 'km/h',
            iconColor: AppColors.speed,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.flash_on,
            label: '最大速度',
            value: trip.maxSpeed.toStringAsFixed(1),
            unit: 'km/h',
            iconColor: AppColors.accent,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
          _InfoTile(
            icon: Icons.battery_charging_full,
            label: '能耗',
            value: trip.energyUsed.toStringAsFixed(1),
            unit: 'kWh/100km',
            iconColor: AppColors.secondary,
            isDark: isDark,
            isHorizontal: state.isHorizontal,
          ),
        ],
      ),
    );
  }

  /// 构建拓展模块卡片
  Widget _buildExtensionsCard(
      BuildContext context, DashboardState state, bool isDark) {
    return _InfoCard(
      title: '拓展模块',
      icon: Icons.widgets,
      iconColor: isDark ? AppColors.purpleNeon : AppColors.purple,
      isDark: isDark,
      child: Column(
        children: state.extensions.map((ext) {
          return _ExtensionRow(
            name: ext.name,
            connected: ext.connected,
            info: ext.additionalInfo,
            isDark: isDark,
          );
        }).toList(),
      ),
    );
  }

  /// 获取级别对应颜色
  Color _getLevelColor(FaultLevel level, bool isDark) {
    switch (level) {
      case FaultLevel.normal:
        return isDark ? AppColors.successNeon : AppColors.success;
      case FaultLevel.warning:
        return isDark ? AppColors.warningNeon : AppColors.warning;
      case FaultLevel.error:
        return isDark ? AppColors.errorNeon : AppColors.error;
    }
  }
}

/// 信息卡片组件
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 内容
          child,
        ],
      ),
    );
  }
}

/// 信息磁贴组件
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color iconColor;
  final bool isDark;
  final bool isHorizontal;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    required this.iconColor,
    required this.isDark,
    required this.isHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isHorizontal ? 18.0 : 20.0;
    final labelFontSize = isHorizontal ? 8.0 : 9.0;
    final valueFontSize = isHorizontal ? 14.0 : 16.0;
    final unitFontSize = isHorizontal ? 9.0 : 10.0;
    final padding = isHorizontal ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          if (unit != null) ...[
            const SizedBox(height: 2),
            Text(
              unit!,
              style: TextStyle(
                fontSize: unitFontSize,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 拓展模块行组件
class _ExtensionRow extends StatelessWidget {
  final String name;
  final bool connected;
  final String? info;
  final bool isDark;

  const _ExtensionRow({
    required this.name,
    required this.connected,
    this.info,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = connected
        ? (isDark ? AppColors.successNeon : AppColors.success)
        : (isDark ? AppColors.errorNeon : AppColors.error);
    final statusText = connected ? '已连接' : '未连接';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                connected ? Icons.check_circle : Icons.cancel,
                size: 10,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                name,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (info != null) ...[
                Text(
                  info!,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
