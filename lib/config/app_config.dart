import 'package:hive/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 0)
class AppConfig extends HiveObject {
  @HiveField(0)
  String themeMode;

  @HiveField(1)
  String distanceUnit;

  @HiveField(2)
  List<String> defaultBluetoothDevices;

  @HiveField(3)
  String dashboardStyle;

  AppConfig({
    this.themeMode = 'system',
    this.distanceUnit = 'kmh',
    this.defaultBluetoothDevices = const [],
    this.dashboardStyle = 'default',
  });
}
