// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_snapshot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceSnapshotAdapter extends TypeAdapter<DeviceSnapshot> {
  @override
  final int typeId = 3;

  @override
  DeviceSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceSnapshot(
      tripId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      deviceType: fields[2] as String,
      deviceId: fields[3] as String,
      data: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DeviceSnapshot obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tripId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.deviceType)
      ..writeByte(3)
      ..write(obj.deviceId)
      ..writeByte(4)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
