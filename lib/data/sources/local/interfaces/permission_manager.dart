import 'dart:async';
import 'package:flutter/widgets.dart';

enum PermissionType {
  location,
  bluetooth,
  storage,
  backgroundLocation,
  notification,
}

enum PermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied,
}

class PermissionState {
  final PermissionType type;
  final PermissionStatus status;
  final bool serviceEnabled;

  const PermissionState({
    required this.type,
    required this.status,
    required this.serviceEnabled,
  });
}

class PermissionResult {
  final PermissionStatus status;
  final bool success;

  const PermissionResult({
    required this.status,
    required this.success,
  });
}

abstract class IPermissionManager {
  Stream<PermissionState> get permissionStateStream;

  Future<PermissionResult> ensureLocation(bool requireBackground);

  Future<bool> ensureBluetoothOn();

  Future<PermissionResult> ensureStorage();

  Future<PermissionResult> ensureNotification();

  Future<void> openNotificationAccessSettings();

  Widget permissionRequestWidget({required PermissionType type});

  Future<void> openAppSettings();
}
