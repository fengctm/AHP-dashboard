import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'interfaces/permission_manager.dart';
import '../../../../../core/utils/logger_helper.dart';

final _logger = LoggerHelper.getCoreLogger('permission_manager');

class PermissionManager implements IPermissionManager {
  final StreamController<PermissionState> _permissionStateController =
      StreamController<PermissionState>.broadcast();

  @override
  Stream<PermissionState> get permissionStateStream =>
      _permissionStateController.stream;

  @override
  Future<PermissionResult> ensureLocation(bool requireBackground) async {
    _logger.info('请求位置权限，需要后台定位: $requireBackground');

    // For web platform, always return granted
    if (kIsWeb) {
      _logger.info('Web平台，位置权限默认授予');
      _permissionStateController.add(const PermissionState(
        type: PermissionType.location,
        status: PermissionStatus.granted,
        serviceEnabled: true,
      ));

      return const PermissionResult(
        status: PermissionStatus.granted,
        success: true,
      );
    }

    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _logger.info('位置服务状态: $serviceEnabled');

      // Check current location permission
      final currentPermission = await Geolocator.checkPermission();
      _logger.info('当前位置权限: $currentPermission');

      // If we already have the required permission, return success
      if ((requireBackground && currentPermission == LocationPermission.always) ||
          (!requireBackground && 
           (currentPermission == LocationPermission.whileInUse || 
            currentPermission == LocationPermission.always))) {
        _logger.info('已拥有所需位置权限，无需请求');
        _permissionStateController.add(PermissionState(
          type: PermissionType.location,
          status: PermissionStatus.granted,
          serviceEnabled: serviceEnabled,
        ));
        return const PermissionResult(
          status: PermissionStatus.granted,
          success: true,
        );
      }

      // Request location permission
      ph.Permission permission = requireBackground
          ? ph.Permission.locationAlways
          : ph.Permission.locationWhenInUse;
      _logger.info('请求位置权限类型: $permission');

      final permissionStatus = await permission.request();
      _logger.info('位置权限请求结果: $permissionStatus');

      PermissionStatus status;
      switch (permissionStatus) {
        case ph.PermissionStatus.granted:
          status = PermissionStatus.granted;
          break;
        case ph.PermissionStatus.denied:
          status = PermissionStatus.denied;
          break;
        case ph.PermissionStatus.permanentlyDenied:
          status = PermissionStatus.permanentlyDenied;
          break;
        default:
          status = PermissionStatus.denied;
          break;
      }

      _logger.info('位置权限最终状态: $status');

      _permissionStateController.add(PermissionState(
        type: PermissionType.location,
        status: status,
        serviceEnabled: serviceEnabled,
      ));

      return PermissionResult(
        status: status,
        success: status == PermissionStatus.granted,
      );
    } catch (e) {
      // If any error occurs, return denied as fallback
      _logger.severe('请求位置权限时出错: $e');
      _permissionStateController.add(const PermissionState(
        type: PermissionType.location,
        status: PermissionStatus.denied,
        serviceEnabled: false,
      ));

      return const PermissionResult(
        status: PermissionStatus.denied,
        success: false,
      );
    }
  }

  @override
  Future<bool> ensureBluetoothOn() async {
    _logger.info('请求蓝牙权限');

    // For web platform, always return true
    if (kIsWeb) {
      _logger.info('Web平台，蓝牙权限默认授予');
      _permissionStateController.add(const PermissionState(
        type: PermissionType.bluetooth,
        status: PermissionStatus.granted,
        serviceEnabled: true,
      ));

      return true;
    }

    try {
      // Request bluetooth permissions
      _logger.info('请求蓝牙扫描权限');
      final bluetoothScanStatus = await ph.Permission.bluetoothScan.request();
      _logger.info('蓝牙扫描权限请求结果: $bluetoothScanStatus');

      _logger.info('请求蓝牙连接权限');
      final bluetoothConnectStatus =
          await ph.Permission.bluetoothConnect.request();
      _logger.info('蓝牙连接权限请求结果: $bluetoothConnectStatus');

      PermissionStatus status;
      if (bluetoothScanStatus == ph.PermissionStatus.granted &&
          bluetoothConnectStatus == ph.PermissionStatus.granted) {
        status = PermissionStatus.granted;
      } else if (bluetoothScanStatus == ph.PermissionStatus.permanentlyDenied ||
          bluetoothConnectStatus == ph.PermissionStatus.permanentlyDenied) {
        status = PermissionStatus.permanentlyDenied;
      } else {
        status = PermissionStatus.denied;
      }

      _logger.info('蓝牙权限最终状态: $status');

      _permissionStateController.add(PermissionState(
        type: PermissionType.bluetooth,
        status: status,
        serviceEnabled: true,
      ));

      return status == PermissionStatus.granted;
    } catch (e) {
      // If any error occurs, return false as fallback
      _logger.severe('请求蓝牙权限时出错: $e');
      _permissionStateController.add(const PermissionState(
        type: PermissionType.bluetooth,
        status: PermissionStatus.denied,
        serviceEnabled: false,
      ));

      return false;
    }
  }

  @override
  Future<PermissionResult> ensureStorage() async {
    // For web platform, always return granted
    if (kIsWeb) {
      _permissionStateController.add(const PermissionState(
        type: PermissionType.storage,
        status: PermissionStatus.granted,
        serviceEnabled: true,
      ));

      return const PermissionResult(
        status: PermissionStatus.granted,
        success: true,
      );
    }

    // For mobile platforms, return granted as fallback
    _permissionStateController.add(const PermissionState(
      type: PermissionType.storage,
      status: PermissionStatus.granted,
      serviceEnabled: true,
    ));

    return const PermissionResult(
      status: PermissionStatus.granted,
      success: true,
    );
  }

  @override
  Future<PermissionResult> ensureNotification() async {
    _logger.info('请求通知访问权限');

    // For web platform, always return granted
    if (kIsWeb) {
      _logger.info('Web平台，通知权限默认授予');
      _permissionStateController.add(const PermissionState(
        type: PermissionType.notification,
        status: PermissionStatus.granted,
        serviceEnabled: true,
      ));

      return const PermissionResult(
        status: PermissionStatus.granted,
        success: true,
      );
    }

    try {
      // 检查通知监听器权限（使用原生方法）
      const platform = MethodChannel('com.example.ahp_dashboard/media_control');
      final hasListenerPermission = await platform.invokeMethod<bool>('checkPermission') ?? false;
      
      _logger.info('通知监听器权限状态: $hasListenerPermission');

      if (hasListenerPermission) {
        // 已授予通知监听器权限
        _permissionStateController.add(const PermissionState(
          type: PermissionType.notification,
          status: PermissionStatus.granted,
          serviceEnabled: true,
        ));

        return const PermissionResult(
          status: PermissionStatus.granted,
          success: true,
        );
      }

      // 未授予通知监听器权限，返回 denied
      _logger.warning('通知监听器权限未授予，需要用户手动开启');
      
      _permissionStateController.add(const PermissionState(
        type: PermissionType.notification,
        status: PermissionStatus.denied,
        serviceEnabled: false,
      ));

      return const PermissionResult(
        status: PermissionStatus.denied,
        success: false,
      );
    } catch (e) {
      // If any error occurs, return denied as fallback
      _logger.severe('请求通知权限时出错: $e');
      _permissionStateController.add(const PermissionState(
        type: PermissionType.notification,
        status: PermissionStatus.denied,
        serviceEnabled: false,
      ));

      return const PermissionResult(
        status: PermissionStatus.denied,
        success: false,
      );
    }
  }

  @override
  Future<void> openNotificationAccessSettings() async {
    _logger.info('打开通知监听器设置');

    if (kIsWeb) {
      return;
    }

    try {
      // 直接打开通知监听器设置页面
      const platform = MethodChannel('com.example.ahp_dashboard/media_control');
      await platform.invokeMethod('openNotificationListenerSettings');
    } catch (e) {
      _logger.severe('打开通知监听器设置时出错: $e');
      // Fallback to general app settings
      await openAppSettings();
    }
  }

  @override
  Widget permissionRequestWidget({required PermissionType type}) {
    return PermissionRequestView(type: type);
  }

  @override
  Future<void> openAppSettings() {
    // For web platform, do nothing
    if (kIsWeb) {
      return Future<void>.value();
    }

    // For mobile platforms, open app settings
    return ph.openAppSettings();
  }

  void dispose() {
    _permissionStateController.close();
  }
}

class PermissionRequestView extends StatelessWidget {
  final PermissionType type;

  const PermissionRequestView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    String buttonText;

    switch (type) {
      case PermissionType.location:
        title = '需要位置权限';
        description = 'AHP仪表盘需要访问您的位置以显示速度和轨迹';
        buttonText = '授予权限';
        break;
      case PermissionType.bluetooth:
        title = '需要蓝牙权限';
        description = 'AHP仪表盘需要蓝牙权限以连接到您的设备';
        buttonText = '打开蓝牙';
        break;
      case PermissionType.backgroundLocation:
        title = '需要后台定位权限';
        description = 'AHP仪表盘需要后台定位权限以在后台记录轨迹';
        buttonText = '授予权限';
        break;
      case PermissionType.storage:
        title = '需要存储权限';
        description = 'AHP仪表盘需要存储权限以保存轨迹数据';
        buttonText = '授予权限';
        break;
      case PermissionType.notification:
        title = '需要通知权限';
        description = 'AHP仪表盘需要通知权限以向您发送重要信息';
        buttonText = '授予权限';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // This will be handled by the parent widget
                // using the PermissionManager instance
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(buttonText),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Open app settings
              },
              child: const Text('打开设置'),
            ),
          ],
        ),
      ),
    );
  }
}
