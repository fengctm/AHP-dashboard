import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permission_constants.dart';
import '../../../core/theme/app_colors.dart';
// 删除未使用的flutter_animate导入
// import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/permission_provider.dart';
import '../atoms/adaptive_card.dart';

/// 权限请求卡片组件
class PermissionRequestCard extends ConsumerWidget {
  final PermissionType permissionType;
  final VoidCallback? onRequest;
  final bool showStatus;

  const PermissionRequestCard({
    Key? key,
    required this.permissionType,
    this.onRequest,
    this.showStatus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionUtils = ref.watch(permissionUtilsProvider);
    final permissionNotifier = ref.watch(permissionProvider.notifier);
    // 删除未使用的state变量
    // final state = ref.watch(permissionProvider);

    // 获取权限信息
    final key = permissionType.toString().split('.').last;
    final info = PermissionConstants.permissionInfo[key];

    // 如果找不到权限信息，返回空容器
    if (info == null) {
      return Container();
    }

    final title = info['title'] as String;
    final description = info['description'] as String;
    final icon = info['icon'] as IconData;
    final color = info['color'] as Color;
    final required = info['required'] as bool;

    // 获取当前状态
    final statusText = permissionUtils.getStatusText(permissionType);
    final statusColor = permissionUtils.getStatusColor(permissionType);
    final showWarning = permissionUtils.shouldShowWarning(permissionType);

    return AdaptiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              // 图标
              Container(
                padding: const EdgeInsets.all(8), // 添加const
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12), // 添加const
              // 标题和状态
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (required) ...[
                          const SizedBox(width: 4), // 添加const
                          const Text(
                            // 添加const
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (showStatus) ...[
                      const SizedBox(height: 2), // 添加const
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 状态图标
              if (showWarning)
                Icon(
                  Icons.warning_amber,
                  color: statusColor,
                  size: 20,
                )
              else if (showStatus)
                Icon(
                  Icons.check_circle,
                  color: statusColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 添加const
          // 描述
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const SizedBox(height: 12),
          // 添加const
          // 操作按钮
          _buildActionButton(
              context, ref, permissionNotifier, showWarning, color),
          // 传递color参数
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    PermissionNotifier notifier,
    bool showWarning,
    Color color, // 添加color参数
  ) {
    final isGranted = !showWarning;

    if (isGranted) {
      return const Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          SizedBox(width: 6),
          Text(
            '已授予',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    // 检查是否永久拒绝
    final state = ref.watch(permissionProvider);
    final isPermanentlyDenied =
        state.value?[permissionType] == PermissionStatus.permanentlyDenied;

    if (isPermanentlyDenied) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await notifier.openSettings();
                if (result) {
                  // 等待用户返回并刷新
                  await Future.delayed(const Duration(seconds: 1));
                  await notifier.refresh();
                }
                onRequest?.call();
              },
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('打开设置'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
        ],
      );
    }

    // 普通请求按钮
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              // 检查特殊权限（定位服务）
              if (permissionType == PermissionType.location ||
                  permissionType == PermissionType.locationAlways) {
                final locationEnabled = await notifier.checkLocationService();
                if (!locationEnabled) {
                  final serviceEnabled =
                      await notifier.requestLocationService();
                  if (!serviceEnabled) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('需要开启定位服务才能继续'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    return;
                  }
                }
              }

              // 检查蓝牙状态
              if (permissionType == PermissionType.bluetooth ||
                  permissionType == PermissionType.bluetoothScan ||
                  permissionType == PermissionType.bluetoothConnect) {
                final bluetoothEnabled = await notifier.checkBluetoothState();
                if (!bluetoothEnabled) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('请在系统设置中开启蓝牙'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  // 尝试引导用户开启蓝牙
                  await notifier.requestPermission(permissionType);
                  await Future.delayed(const Duration(milliseconds: 500));
                  await notifier.refresh();
                  onRequest?.call();
                  return;
                }
              }

              // 请求权限
              final result = await notifier.requestPermission(permissionType);

              if (result) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('权限授予成功'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Text('权限请求被拒绝'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }

              onRequest?.call();
            },
            icon: const Icon(Icons.key, size: 16),
            label: const Text('授予权限'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// 权限请求列表组件
class PermissionRequestList extends ConsumerWidget {
  final List<PermissionType> permissions;
  final VoidCallback? onAllGranted;

  const PermissionRequestList({
    Key? key,
    required this.permissions,
    this.onAllGranted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionUtils = ref.watch(permissionUtilsProvider);

    return Column(
      children: permissions.map((permission) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PermissionRequestCard(
            permissionType: permission,
            onRequest: () {
              // 检查是否所有权限都已授予
              permissionUtils.hasAllRequiredPermissions.then((hasAll) {
                if (hasAll) {
                  onAllGranted?.call();
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

/// 权限总结卡片
class PermissionSummaryCard extends ConsumerWidget {
  const PermissionSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionUtils = ref.watch(permissionUtilsProvider);
    final state = ref.watch(permissionProvider);

    if (state.value == null) {
      return Container();
    }

    final total = permissionUtils.totalPermissions;
    final granted = permissionUtils.grantedPermissionsCount;
    final percentage = permissionUtils.progressPercentage;
    final missing = permissionUtils.missingPermissions;

    return AdaptiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度条
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage == 1.0 ? Colors.green : AppColors.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$granted/$total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          percentage == 1.0 ? Colors.green : AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 状态文本
          if (percentage == 1.0)
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 6),
                Text(
                  PermissionConstants.allPermissionsGranted,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else ...[
            const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Text(
                  PermissionConstants.missingPermissions,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: missing.map((permission) {
                final key = permission.toString().split('.').last;
                final info = PermissionConstants.permissionInfo[key];

                // 如果找不到权限信息，返回空容器
                if (info == null) {
                  return const SizedBox.shrink();
                }

                return Chip(
                  label: Text(info['title'] as String),
                  backgroundColor: info['color'] as Color,
                  labelStyle: const TextStyle(color: Colors.white),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
