// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripRecordAdapter extends TypeAdapter<TripRecord> {
  @override
  final int typeId = 1;

  @override
  TripRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripRecord(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      totalDistance: fields[3] as double,
      maxSpeed: fields[4] as double,
      averageSpeed: fields[5] as double,
      startLatitude: fields[7] as double?,
      startLongitude: fields[8] as double?,
      endLatitude: fields[9] as double?,
      endLongitude: fields[10] as double?,
      startLocationName: fields[11] as String?,
      endLocationName: fields[12] as String?,
      hasDeviceData: fields[13] as bool,
      connectedDeviceIds: (fields[14] as List).cast<String>(),
    )..drivingTimeMs = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, TripRecord obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.totalDistance)
      ..writeByte(4)
      ..write(obj.maxSpeed)
      ..writeByte(5)
      ..write(obj.averageSpeed)
      ..writeByte(6)
      ..write(obj.drivingTimeMs)
      ..writeByte(7)
      ..write(obj.startLatitude)
      ..writeByte(8)
      ..write(obj.startLongitude)
      ..writeByte(9)
      ..write(obj.endLatitude)
      ..writeByte(10)
      ..write(obj.endLongitude)
      ..writeByte(11)
      ..write(obj.startLocationName)
      ..writeByte(12)
      ..write(obj.endLocationName)
      ..writeByte(13)
      ..write(obj.hasDeviceData)
      ..writeByte(14)
      ..write(obj.connectedDeviceIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
