import 'package:hive/hive.dart';

/// 蓝牙设备模型
@HiveType(typeId: 4)
class AppBluetoothDevice extends HiveObject {
  /// 设备ID
  @HiveField(0)
  String deviceId;

  /// 设备名称
  @HiveField(1)
  String name;

  /// 设备类型 (bms, controller, tpms)
  @HiveField(2)
  String deviceType;

  /// 上次连接时间
  @HiveField(3)
  DateTime lastConnectedAt;

  /// 是否自动连接
  @HiveField(4)
  bool autoConnect;

  /// 连接优先级 (0-100, 越高优先级越高)
  @HiveField(5)
  int priority;

  /// 服务UUIDs
  @HiveField(6)
  List<String>? serviceUuids;

  /// 制造商数据
  @HiveField(7)
  Map<int, List<int>>? manufacturerData;

  AppBluetoothDevice({
    required this.deviceId,
    required this.name,
    required this.deviceType,
    DateTime? lastConnectedAt,
    this.autoConnect = true,
    this.priority = 50,
    this.serviceUuids,
    this.manufacturerData,
  }) : lastConnectedAt = lastConnectedAt ?? DateTime.now();
}

/// 蓝牙设备适配器
class AppBluetoothDeviceAdapter extends TypeAdapter<AppBluetoothDevice> {
  @override
  final int typeId = 4;

  @override
  AppBluetoothDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    // 处理 serviceUuids 的类型转换
    List<String>? serviceUuids;
    if (fields[6] != null) {
      try {
        serviceUuids = (fields[6] as List<dynamic>).cast<String>();
      } catch (e) {
        serviceUuids = null;
      }
    }
    
    // 处理 manufacturerData 的类型转换
    Map<int, List<int>>? manufacturerData;
    if (fields[7] != null) {
      try {
        final dynamic data = fields[7];
        if (data is Map<int, List<int>>) {
          manufacturerData = data;
        } else if (data is Map<dynamic, dynamic>) {
          manufacturerData = data.map<int, List<int>>((key, value) {
            return MapEntry(
              key as int,
              (value as List<dynamic>).cast<int>(),
            );
          });
        }
      } catch (e) {
        manufacturerData = null;
      }
    }
    
    return AppBluetoothDevice(
      deviceId: fields[0] as String,
      name: fields[1] as String,
      deviceType: fields[2] as String,
      lastConnectedAt: fields[3] as DateTime,
      autoConnect: fields[4] as bool,
      priority: fields[5] as int,
      serviceUuids: serviceUuids, 
      manufacturerData: manufacturerData,
    );
  }

  @override
  void write(BinaryWriter writer, AppBluetoothDevice obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.deviceType)
      ..writeByte(3)
      ..write(obj.lastConnectedAt)
      ..writeByte(4)
      ..write(obj.autoConnect)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.serviceUuids)
      ..writeByte(7)
      ..write(obj.manufacturerData);
  }
}
