import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;

import '../../core/services/bluetooth_service.dart';
import '../../domain/models/ble_packet.dart';

/// 蓝牙状态
class BluetoothState {
  final BleConnectionState connectionState;
  final ble.BluetoothDevice? connectedDevice;
  final List<ble.ScanResult> scanResults;
  final YuanquDeviceData? latestData;
  final String? errorMessage;
  final bool isScanning;
  final bool isConnected;

  const BluetoothState({
    required this.connectionState,
    this.connectedDevice,
    this.scanResults = const [],
    this.latestData,
    this.errorMessage,
    this.isScanning = false,
    this.isConnected = false,
  });

  /// 初始状态
  factory BluetoothState.initial() {
    return const BluetoothState(
      connectionState: BleConnectionState.disconnected,
      scanResults: [],
    );
  }

  BluetoothState copyWith({
    BleConnectionState? connectionState,
    ble.BluetoothDevice? connectedDevice,
    List<ble.ScanResult>? scanResults,
    YuanquDeviceData? latestData,
    String? errorMessage,
    bool? isScanning,
    bool? isConnected,
    bool clearError = false,
    bool clearScanResults = false,
  }) {
    return BluetoothState(
      connectionState: connectionState ?? this.connectionState,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      scanResults: clearScanResults
          ? []
          : (scanResults ?? this.scanResults),
      latestData: latestData ?? this.latestData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BluetoothState &&
        other.connectionState == connectionState &&
        other.connectedDevice == connectedDevice &&
        listEquals(other.scanResults, scanResults) &&
        other.latestData == latestData &&
        other.errorMessage == errorMessage &&
        other.isScanning == isScanning &&
        other.isConnected == isConnected;
  }

  @override
  int get hashCode {
    return connectionState.hashCode ^
        connectedDevice.hashCode ^
        scanResults.hashCode ^
        latestData.hashCode ^
        errorMessage.hashCode ^
        isScanning.hashCode ^
        isConnected.hashCode;
  }

  @override
  String toString() {
    return 'BluetoothState(connectionState: $connectionState, '
        'isConnected: $isConnected, isScanning: $isScanning, '
        'device: ${connectedDevice?.platformName})';
  }
}
