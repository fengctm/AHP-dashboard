import 'dart:async';

class DeviceAdvertisement {
  final String deviceId;
  final String name;
  final int rssi;
  final Map<int, List<int>>? manufacturerData;
  final List<String>? serviceUuids;

  const DeviceAdvertisement({
    required this.deviceId,
    required this.name,
    required this.rssi,
    this.manufacturerData,
    this.serviceUuids,
  });
}

class DeviceConnection {
  final String deviceId;
  final bool connected;
  final DateTime? connectedAt;
  final DateTime? disconnectedAt;

  const DeviceConnection({
    required this.deviceId,
    required this.connected,
    this.connectedAt,
    this.disconnectedAt,
  });
}

enum MessageSource {
  notification,
  advertisement,
  read,
}

class DeviceMessage {
  final String deviceId;
  final DateTime timestamp;
  final List<int> payload;
  final MessageSource source;

  const DeviceMessage({
    required this.deviceId,
    required this.timestamp,
    required this.payload,
    required this.source,
  });
}

class DeviceState {
  final String deviceId;
  final String deviceType;
  final DateTime timestamp;
  final double? batteryVoltage;
  final double? temperature;
  final double? rpm;
  final Map<String, dynamic>? extra;

  const DeviceState({
    required this.deviceId,
    required this.deviceType,
    required this.timestamp,
    this.batteryVoltage,
    this.temperature,
    this.rpm,
    this.extra,
  });
}

abstract class IDeviceAdapter {
  bool matches(DeviceAdvertisement ad);

  DeviceState parse(DeviceMessage msg);

  Future<void> sendCommand(String deviceId, List<int> payload);
}

abstract class IBluetoothManager {
  Stream<DeviceAdvertisement> get onDeviceDiscovered;

  Stream<DeviceConnection> get onDeviceConnectionChanged;

  Stream<DeviceMessage> get onDeviceMessage;

  Stream<DeviceState> get onDeviceState;

  Future<void> startScan({Duration? timeout});

  Future<void> stopScan();

  Future<DeviceConnection> connect(String deviceId);

  Future<void> disconnect(String deviceId);

  Future<List<DeviceAdvertisement>> getPairedDevices();

  void registerAdapter(IDeviceAdapter adapter);

  void unregisterAdapter(IDeviceAdapter adapter);
}
