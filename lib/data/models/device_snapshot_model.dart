import 'package:hive/hive.dart';

part 'device_snapshot_model.g.dart';

/// 设备数据快照（用于行程记录）
@HiveType(typeId: 3)
class DeviceSnapshot extends HiveObject {
  @HiveField(0)
  String tripId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String deviceType; // 'BMS' | 'Controller' | 'TPMS'

  @HiveField(3)
  String deviceId;

  @HiveField(4)
  Map<String, dynamic> data; // 设备原始数据

  DeviceSnapshot({
    required this.tripId,
    required this.timestamp,
    required this.deviceType,
    required this.deviceId,
    required this.data,
  });
}

/// BMS数据快照
class BmsDataSnapshot {
  final DateTime timestamp;
  final double? voltage; // 总电压 V
  final double? current; // 电流 A
  final double? power; // 功率 W
  final double? soc; // 剩余电量百分比
  final double? mosTemperature; // MOS温度 ℃
  final List<double> cellVoltages; // 电芯电压 V
  final List<double> temperatures; // 探头温度 ℃

  BmsDataSnapshot({
    required this.timestamp,
    this.voltage,
    this.current,
    this.power,
    this.soc,
    this.mosTemperature,
    this.cellVoltages = const [],
    this.temperatures = const [],
  });

  factory BmsDataSnapshot.fromMap(DateTime timestamp, Map<String, dynamic> data) {
    return BmsDataSnapshot(
      timestamp: timestamp,
      voltage: data['totalVoltage']?.toDouble(),
      current: data['current']?.toDouble(),
      power: data['power']?.toDouble(),
      soc: data['soc']?.toDouble(),
      mosTemperature: data['mosTemperature']?.toDouble(),
      cellVoltages: (data['cellVoltages'] as List?)?.cast<double>() ?? [],
      temperatures: (data['temperatures'] as List?)?.cast<double>() ?? [],
    );
  }
}

/// 控制器数据快照
class ControllerDataSnapshot {
  final DateTime timestamp;
  final double? power; // 功率 W
  final double? rpm; // 转速 R
  final double? mosTemperature; // MOS管温度 ℃
  final double? motorTemperature; // 电机温度 ℃
  final double? voltage; // 线电压 V
  final double? current; // 当前电流 A

  ControllerDataSnapshot({
    required this.timestamp,
    this.power,
    this.rpm,
    this.mosTemperature,
    this.motorTemperature,
    this.voltage,
    this.current,
  });

  factory ControllerDataSnapshot.fromMap(DateTime timestamp, Map<String, dynamic> data) {
    return ControllerDataSnapshot(
      timestamp: timestamp,
      power: data['power']?.toDouble(),
      rpm: data['rpm']?.toDouble(),
      mosTemperature: data['mosTemperature']?.toDouble(),
      motorTemperature: data['motorTemperature']?.toDouble(),
      voltage: data['voltage']?.toDouble(),
      current: data['current']?.toDouble(),
    );
  }
}
