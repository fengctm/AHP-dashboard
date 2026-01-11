import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../../application/dashboard/dashboard_provider.dart';
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

          // 展开的内容
          if (isExpanded) ...[
            const SizedBox(height: 8),
            // 模块网格
            isHorizontal
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildControllerCard(context, dashboardState, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBmsCard(context, dashboardState, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTripCard(context, dashboardState, isDark)),
                    ],
                  )
                : Column(
                    children: [
                      _buildControllerCard(context, dashboardState, isDark),
                      const SizedBox(height: 8),
                      _buildBmsCard(context, dashboardState, isDark),
                      const SizedBox(height: 8),
                      _buildTripCard(context, dashboardState, isDark),
                    ],
                  ),

            const SizedBox(height: 8),

            // 拓展模块
            _buildExtensionsCard(context, dashboardState, isDark),
          ],
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
        onTap: () => ref.read(dashboardStateProvider.notifier).toggleInfoSection(),
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
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
  Widget _buildControllerCard(BuildContext context, DashboardState state, bool isDark) {
    final controller = state.controller;
    final color = _getLevelColor(controller.level, isDark);

    return _InfoCard(
      title: '控制器',
      icon: Icons.memory,
      iconColor: color,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: '温度', value: '${controller.temperature.toStringAsFixed(1)}°C', color: color),
          _InfoRow(label: '电压', value: '${controller.voltage.toStringAsFixed(1)}V', isDark: isDark),
          _InfoRow(label: '电流', value: '${controller.current.toStringAsFixed(1)}A', isDark: isDark),
          _InfoRow(label: '转速', value: '${controller.rpm} RPM', isDark: isDark),
        ],
      ),
    );
  }

  /// 构建BMS卡片
  Widget _buildBmsCard(BuildContext context, DashboardState state, bool isDark) {
    final bms = state.bms;
    final color = _getLevelColor(bms.level, isDark);

    return _InfoCard(
      title: '电池管理',
      icon: Icons.battery_std,
      iconColor: color,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: '电量', value: '${bms.batteryLevel.toStringAsFixed(0)}%', color: color),
          _InfoRow(label: '续航', value: '${bms.remainingRange.toStringAsFixed(0)}km', isDark: isDark),
          _InfoRow(label: '电芯温度', value: '${bms.cellTemp.toStringAsFixed(1)}°C', isDark: isDark),
          _InfoRow(label: '总电压', value: '${bms.voltage.toStringAsFixed(1)}V', isDark: isDark),
        ],
      ),
    );
  }

  /// 构建行程卡片
  Widget _buildTripCard(BuildContext context, DashboardState state, bool isDark) {
    final trip = state.trip;

    return _InfoCard(
      title: '行程信息',
      icon: Icons.route,
      iconColor: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: '总里程', value: '${trip.totalDistance.toStringAsFixed(1)}km', isDark: isDark),
          _InfoRow(label: '本次行程', value: '${trip.tripDistance.toStringAsFixed(1)}km', isDark: isDark),
          _InfoRow(label: '平均速度', value: '${trip.avgSpeed.toStringAsFixed(1)}km/h', isDark: isDark),
          _InfoRow(label: '最大速度', value: '${trip.maxSpeed.toStringAsFixed(1)}km/h', isDark: isDark),
          _InfoRow(label: '能耗', value: '${trip.energyUsed.toStringAsFixed(1)}kWh/100km', isDark: isDark),
        ],
      ),
    );
  }

  /// 构建拓展模块卡片
  Widget _buildExtensionsCard(BuildContext context, DashboardState state, bool isDark) {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
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
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 内容
          child,
        ],
      ),
    );
  }
}

/// 信息行组件
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool? isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    this.color,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? ((isDark ?? false) ? Colors.white70 : Colors.black54);
    final valueColor = color ?? ((isDark ?? false) ? Colors.white : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
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
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                connected ? Icons.check_circle : Icons.cancel,
                size: 12,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 11,
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
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
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
