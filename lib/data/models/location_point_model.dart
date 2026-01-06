import 'package:hive/hive.dart';

part 'location_point_model.g.dart';

@HiveType(typeId: 2)
class LocationPoint extends HiveObject {
  @HiveField(0)
  String tripId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  double speed;

  @HiveField(5)
  double bearing;

  LocationPoint({
    required this.tripId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.bearing,
  });
}
