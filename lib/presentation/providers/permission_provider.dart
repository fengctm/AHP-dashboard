import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/permission_service.dart';
import '../../core/constants/permission_constants.dart';

/// 权限状态管理器
class PermissionNotifier extends StateNotifier<AsyncValue<Map<PermissionType, PermissionStatus>>> {
  final PermissionService _permissionService;

  PermissionNotifier(this._permissionService) : super(const AsyncValue.loading()) {
    loadPermissions();
  }

  /// 加载当前权限状态
  Future<void> loadPermissions() async {
    try {
      state = const AsyncValue.loading();
      final permissions = await _permissionService.checkAllRequiredPermissions();
      state = AsyncValue.data(permissions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 请求单个权限
  Future<bool> requestPermission(PermissionType type) async {
    try {
      final status = await _permissionService.requestPermission(type);
      
      // 更新状态
      if (state.value != null) {
        final updatedPermissions = Map<PermissionType, PermissionStatus>.from(state.value!);
        updatedPermissions[type] = status;
        state = AsyncValue.data(updatedPermissions);
      }
      
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// 请求所有必要权限
  Future<bool> requestAllRequiredPermissions() async {
    try {
      final results = await _permissionService.requestAllRequiredPermissions();
      
      // 更新状态
      state = AsyncValue.data(results);
      
      // 检查是否所有权限都已授予
      return results.values.every((status) => status == PermissionStatus.granted);
    } catch (e) {
      return false;
    }
  }

  /// 检查是否所有必要权限都已授予
  Future<bool> hasAllRequiredPermissions() async {
    if (state.value == null) return false;
    return state.value!.values.every((status) => status == PermissionStatus.granted);
  }

  /// 获取缺失的权限列表
  List<PermissionType> getMissingPermissions() {
    if (state.value == null) return [];
    
    return state.value!.entries
        .where((entry) => entry.value != PermissionStatus.granted)
        .map((entry) => entry.key)
        .toList();
  }

  /// 检查是否有权限被永久拒绝
  bool hasPermanentlyDenied() {
    if (state.value == null) return false;
    
    return state.value!.values.any(
      (status) => status == PermissionStatus.permanentlyDenied
    );
  }

  /// 打开设置页面
  Future<bool> openSettings() async {
    return await _permissionService.openAppSettings();
  }

  /// 刷新权限状态
  Future<void> refresh() async {
    await loadPermissions();
  }

  /// 检查定位服务状态
  Future<bool> checkLocationService() async {
    return await _permissionService.isLocationServiceEnabled();
  }

  /// 请求开启定位服务
  Future<bool> requestLocationService() async {
    return await _permissionService.requestLocationService();
  }

  /// 检查蓝牙状态
  Future<bool> checkBluetoothState() async {
    return await _permissionService.isBluetoothEnabled();
  }

  /// 获取权限状态的描述
  String getPermissionStatusDescription(PermissionType type) {
    if (state.value == null) return '未知';
    
    final status = state.value![type] ?? PermissionStatus.unknown;
    return _permissionService.getStatusDescription(status);
  }

  /// 获取权限解释
  String getPermissionExplanation(PermissionType type) {
    return _permissionService.getPermissionExplanation(type);
  }

  /// 检查是否可以请求权限
  Future<bool> canRequest(PermissionType type) async {
    return await _permissionService.canRequestPermission(type);
  }
}

/// 权限状态提供者
final permissionProvider = StateNotifierProvider<PermissionNotifier, AsyncValue<Map<PermissionType, PermissionStatus>>>((ref) {
  return PermissionNotifier(PermissionService());
});

/// 权限工具提供者
final permissionUtilsProvider = Provider<PermissionUtils>((ref) {
  return PermissionUtils(ref);
});

/// 权限工具类
class PermissionUtils {
  final Ref _ref;

  PermissionUtils(this._ref);

  /// 检查是否所有必要权限都已授予
  Future<bool> get hasAllRequiredPermissions async {
    final notifier = _ref.read(permissionProvider.notifier);
    return await notifier.hasAllRequiredPermissions();
  }

  /// 获取缺失的权限
  List<PermissionType> get missingPermissions {
    final notifier = _ref.read(permissionProvider.notifier);
    return notifier.getMissingPermissions();
  }

  /// 检查是否有永久拒绝的权限
  bool get hasPermanentlyDenied {
    final notifier = _ref.read(permissionProvider.notifier);
    return notifier.hasPermanentlyDenied();
  }

  /// 检查是否所有权限都已授予（包括可选）
  bool get hasAllPermissions {
    final state = _ref.watch(permissionProvider);
    if (state.value == null) return false;
    
    return state.value!.values.every(
      (status) => status == PermissionStatus.granted
    );
  }

  /// 获取权限数量
  int get totalPermissions {
    final state = _ref.watch(permissionProvider);
    return state.value?.length ?? 0;
  }

  /// 获取已授予的权限数量
  int get grantedPermissionsCount {
    final state = _ref.watch(permissionProvider);
    if (state.value == null) return 0;
    
    return state.value!.values.where(
      (status) => status == PermissionStatus.granted
    ).length;
  }

  /// 获取进度百分比
  double get progressPercentage {
    final total = totalPermissions;
    if (total == 0) return 0.0;
    return grantedPermissionsCount / total;
  }

  /// 检查是否需要显示权限页面
  Future<bool> shouldShowPermissionPage() async {
    return !(await hasAllRequiredPermissions);
  }

  /// 获取权限状态文本
  String getStatusText(PermissionType type) {
    final state = _ref.watch(permissionProvider);
    if (state.value == null) return '未知';
    
    final status = state.value![type] ?? PermissionStatus.unknown;
    switch (status) {
      case PermissionStatus.granted:
        return '✓ 已授予';
      case PermissionStatus.denied:
        return '✗ 已拒绝';
      case PermissionStatus.permanentlyDenied:
        return '⛔ 永久拒绝';
      case PermissionStatus.restricted:
        return '⚠ 受限';
      case PermissionStatus.limited:
        return '⚠ 有限';
      case PermissionStatus.unknown:
        return '? 未知';
    }
  }

  /// 检查是否显示警告图标
  bool shouldShowWarning(PermissionType type) {
    final state = _ref.watch(permissionProvider);
    if (state.value == null) return false;
    
    final status = state.value![type];
    return status != PermissionStatus.granted;
  }

  /// 获取状态颜色
  Color getStatusColor(PermissionType type) {
    final state = _ref.watch(permissionProvider);
    if (state.value == null) return Colors.grey;

    final status = state.value![type];
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.red;
      case PermissionStatus.limited:
        return Colors.orange;
      case PermissionStatus.unknown:
        return Colors.grey;
      case null:
        return Colors.grey;
    }
  }
}