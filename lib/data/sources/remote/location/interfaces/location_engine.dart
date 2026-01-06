import 'dart:async';

class LocationError {
  final LocationErrorCode code;
  final String message;

  const LocationError({
    required this.code,
    required this.message,
  });
}

enum LocationErrorCode {
  permissionDenied,
  serviceDisabled,
  unknown,
}

enum LocationSignalStrength {
  strong,
  moderate,
  weak,
  none,
}

class LocationUpdate {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final double? rawSpeed; // m/s
  final double filteredSpeed; // m/s
  final double? bearing;
  final LocationError? error;
  final LocationSignalStrength signalStrength;

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.rawSpeed,
    required this.filteredSpeed,
    this.bearing,
    this.error,
    this.signalStrength = LocationSignalStrength.strong,
  });
}

enum DistanceUnit {
  kmh,
  mph,
}

abstract class ILocationEngine {
  Stream<LocationUpdate> get onLocation;

  Future<void> start({bool background = false});

  Future<void> stop();

  Future<void> setUpdateInterval(int ms);

  Future<void> setFilterParams(Map<String, dynamic> params);

  Future<void> setDistanceUnit(DistanceUnit unit);

  bool get isRunning;

  double convertSpeed(double speed, DistanceUnit unit);
}
