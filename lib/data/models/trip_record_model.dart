import 'package:hive/hive.dart';

part 'trip_record_model.g.dart';

@HiveType(typeId: 1)
class TripRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  double totalDistance;

  @HiveField(4)
  double maxSpeed;

  @HiveField(5)
  double averageSpeed;

  @HiveField(6)
  int drivingTimeMs;

  @HiveField(7)
  double? startLatitude; // 起点纬度

  @HiveField(8)
  double? startLongitude; // 起点经度

  @HiveField(9)
  double? endLatitude; // 终点纬度

  @HiveField(10)
  double? endLongitude; // 终点经度

  @HiveField(11)
  String? startLocationName; // 起点名称（预留地图功能）

  @HiveField(12)
  String? endLocationName; // 终点名称（预留地图功能）

  @HiveField(13)
  bool hasDeviceData; // 是否包含蓝牙设备数据

  @HiveField(14)
  List<String> connectedDeviceIds; // 连接的设备ID列表

  TripRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
    this.maxSpeed = 0.0,
    this.averageSpeed = 0.0,
    Duration drivingTime = Duration.zero,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.startLocationName,
    this.endLocationName,
    this.hasDeviceData = false,
    this.connectedDeviceIds = const [],
  }) : drivingTimeMs = drivingTime.inMilliseconds;

  // Getter for Duration type
  Duration get drivingTime => Duration(milliseconds: drivingTimeMs);

  // Setter for Duration type
  set drivingTime(Duration duration) {
    drivingTimeMs = duration.inMilliseconds;
  }

  // 是否正在进行中
  bool get isOngoing => endTime == null;

  // 获取格式化的行程时间
  String get formattedDuration {
    final duration = drivingTime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    } else if (minutes > 0) {
      return '$minutes分钟$seconds秒';
    } else {
      return '$seconds秒';
    }
  }

  // 获取行程日期显示
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startDate = DateTime(startTime.year, startTime.month, startTime.day);

    if (startDate == today) {
      return '今天 ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    } else if (startDate == yesterday) {
      return '昨天 ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${startTime.month}月${startTime.day}日 ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
