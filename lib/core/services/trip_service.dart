import 'dart:async';
import 'package:logging/logging.dart';
import '../../data/models/trip_record_model.dart';
import '../../data/models/location_point_model.dart';
import '../../data/models/device_snapshot_model.dart';
import '../../data/sources/local/database_source.dart';
import '../../data/sources/remote/location/interfaces/location_engine.dart';
import '../utils/logger_helper.dart';

/// 行程记录服务
/// 负责管理行程的开始、结束、数据记录等
class TripService {
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final Logger _logger = LoggerHelper.getCoreLogger('trip_service');
  final DatabaseService _db = DatabaseService();

  // 当前行程
  TripRecord? _currentTrip;
  Timer? _saveTimer;
  Timer? _deviceDataTimer;

  // 位置点缓存
  final List<LocationPoint> _pendingLocationPoints = [];
  
  // 设备数据缓存
  final List<DeviceSnapshot> _pendingDeviceSnapshots = [];

  // 统计数据
  double _totalDistance = 0.0;
  double _maxSpeed = 0.0;
  int _speedSampleCount = 0;
  double _speedSum = 0.0;

  // 控制器
  final StreamController<TripRecord?> _tripStateController =
      StreamController<TripRecord?>.broadcast();

  Stream<TripRecord?> get onTripStateChanged => _tripStateController.stream;
  TripRecord? get currentTrip => _currentTrip;
  bool get isRecording => _currentTrip != null && _currentTrip!.isOngoing;

  /// 开始新行程
  Future<TripRecord> startTrip({
    required double latitude,
    required double longitude,
    List<String> connectedDeviceIds = const [],
  }) async {
    if (isRecording) {
      _logger.warning('已有行程正在进行中，无法开始新行程');
      throw Exception('已有行程正在进行中');
    }

    _logger.info('开始新行程');

    // 创建行程记录
    final trip = TripRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      startLatitude: latitude,
      startLongitude: longitude,
      hasDeviceData: connectedDeviceIds.isNotEmpty,
      connectedDeviceIds: connectedDeviceIds,
    );

    // 保存到数据库
    await _db.updateTripRecord(trip);

    // 更新当前行程
    _currentTrip = trip;
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _speedSampleCount = 0;
    _speedSum = 0.0;
    _pendingLocationPoints.clear();
    _pendingDeviceSnapshots.clear();

    // 启动定时保存
    _startAutoSave();

    // 通知状态变化
    _tripStateController.add(_currentTrip);

    _logger.info('行程开始成功，ID: ${trip.id}');
    return trip;
  }

  /// 结束当前行程
  Future<TripRecord?> endTrip({
    required double latitude,
    required double longitude,
  }) async {
    if (!isRecording) {
      _logger.warning('没有正在进行的行程');
      return null;
    }

    _logger.info('结束行程，ID: ${_currentTrip!.id}');

    // 停止定时器
    _saveTimer?.cancel();
    _deviceDataTimer?.cancel();

    // 保存待处理的数据
    await _savePendingData();

    // 更新行程记录
    final trip = _currentTrip!;
    trip.endTime = DateTime.now();
    trip.endLatitude = latitude;
    trip.endLongitude = longitude;
    trip.totalDistance = _totalDistance;
    trip.maxSpeed = _maxSpeed;
    trip.averageSpeed = _speedSampleCount > 0 ? _speedSum / _speedSampleCount : 0.0;
    trip.drivingTime = trip.endTime!.difference(trip.startTime);

    // 保存到数据库
    await _db.updateTripRecord(trip);

    _logger.info('行程结束，总里程: ${trip.totalDistance.toStringAsFixed(2)} km, '
        '最高时速: ${trip.maxSpeed.toStringAsFixed(0)} km/h, '
        '平均时速: ${trip.averageSpeed.toStringAsFixed(0)} km/h');

    // 清空当前行程
    final completedTrip = _currentTrip;
    _currentTrip = null;

    // 通知状态变化
    _tripStateController.add(null);

    return completedTrip;
  }

  /// 添加位置点
  void addLocationPoint(LocationPoint point) {
    if (!isRecording) return;

    _pendingLocationPoints.add(point);

    // 更新统计数据
    _maxSpeed = point.speed > _maxSpeed ? point.speed : _maxSpeed;
    _speedSum += point.speed;
    _speedSampleCount++;
  }

  /// 更新行程距离
  void updateDistance(double distanceKm) {
    if (!isRecording) return;
    _totalDistance += distanceKm;
  }

  /// 添加设备数据快照
  void addDeviceSnapshot(DeviceSnapshot snapshot) {
    if (!isRecording) return;
    _pendingDeviceSnapshots.add(snapshot);
  }

  /// 获取当前行程统计
  Map<String, dynamic> getCurrentStats() {
    return {
      'distance': _totalDistance,
      'maxSpeed': _maxSpeed,
      'avgSpeed': _speedSampleCount > 0 ? _speedSum / _speedSampleCount : 0.0,
      'duration': _currentTrip?.drivingTime ?? Duration.zero,
    };
  }

  /// 启动自动保存
  void _startAutoSave() {
    // 每30秒保存一次位置点和设备数据
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _savePendingData();
    });
  }

  /// 保存待处理的数据
  Future<void> _savePendingData() async {
    if (_pendingLocationPoints.isNotEmpty) {
      _logger.fine('保存 ${_pendingLocationPoints.length} 个位置点');
      await _db.saveLocationPoints(List.from(_pendingLocationPoints));
      _pendingLocationPoints.clear();
    }

    if (_pendingDeviceSnapshots.isNotEmpty) {
      _logger.fine('保存 ${_pendingDeviceSnapshots.length} 个设备快照');
      await _db.saveDeviceSnapshots(List.from(_pendingDeviceSnapshots));
      _pendingDeviceSnapshots.clear();
    }

    // 更新行程记录的实时数据
    if (_currentTrip != null) {
      _currentTrip!.totalDistance = _totalDistance;
      _currentTrip!.maxSpeed = _maxSpeed;
      _currentTrip!.averageSpeed = _speedSampleCount > 0 ? _speedSum / _speedSampleCount : 0.0;
      _currentTrip!.drivingTime = DateTime.now().difference(_currentTrip!.startTime);
      await _db.updateTripRecord(_currentTrip!);
    }
  }

  /// 获取所有行程记录
  Future<List<TripRecord>> getAllTrips() async {
    return await _db.getAllTripRecords();
  }

  /// 获取行程的位置点
  Future<List<LocationPoint>> getTripLocationPoints(String tripId) async {
    return await _db.getLocationPoints(tripId);
  }

  /// 删除行程
  Future<void> deleteTrip(String tripId) async {
    _logger.info('删除行程，ID: $tripId');
    await _db.deleteTripRecord(tripId);
  }

  /// 释放资源
  void dispose() {
    _saveTimer?.cancel();
    _deviceDataTimer?.cancel();
    _tripStateController.close();
  }
}
