import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'interfaces/location_engine.dart';
import '../../../models/location_point_model.dart';
import '../../../models/trip_record_model.dart';
import '../../../../../core/utils/logger_helper.dart';
import '../../local/database_source.dart';

// Trip recording states
enum TripState {
  initial, // 初始状态
  detecting, // 检测中状态
  recording, // 记录中状态
  ending, // 结束状态
}

class LocationEngine implements ILocationEngine {
  final StreamController<LocationUpdate> _locationController = 
      StreamController<LocationUpdate>.broadcast();

  final Logger _logger = LoggerHelper.getCoreLogger('location_engine');

  StreamSubscription<Position>? _positionSubscription;

  bool _isRunning = false;
  bool _backgroundMode = false;

  Position? _lastPosition;

  // Trip recording variables
  String? _currentTripId;
  Timer? _tripSaveTimer;
  Timer? _idleTimer; // Timer to detect when speed is low for a long time
  Timer? _detectionTimer; // Timer for trip start detection
  final List<LocationPoint> _pendingLocationPoints = [];
  double _tripMaxSpeed = 0.0;
  double _tripTotalDistance = 0.0;
  DateTime? _tripStartTime;
  int _tripPointCount = 0;

  // Trip state variables
  TripState _tripState = TripState.initial;
  final List<bool> _speedBuffer = [];

  // Auto trip recording settings (matching technical documentation)
  static const double _tripStartSpeedThreshold = 3.0 / 3.6; // 3 km/h converted to m/s
  static const Duration _detectionDuration = Duration(seconds: 5); // 5 seconds to confirm start
  static const Duration _idleTimeout = Duration(seconds: 30); // 30 seconds of idle to end trip
  static const double _sampleInterval = 0.5; // 0.5 seconds sample interval
  static final int _requiredSamples = (_detectionDuration.inSeconds / _sampleInterval).round(); // 10 samples required
  static const double _idleThreshold = 0.5 / 3.6; // 0.5 km/h converted to m/s

  // Retry mechanism settings
  int _retryCount = 0;
  static const int _maxRetryCount = 5;
  static const Duration _initialRetryDelay = Duration(seconds: 5);
  static const Duration _maxRetryDelay = Duration(seconds: 60);

  LocationEngine();

  @override
  Stream<LocationUpdate> get onLocation => _locationController.stream;

  @override
  Future<void> start({bool background = false}) async {
    if (_isRunning) {
      _logger.fine('位置引擎已在运行中');
      return;
    }

    _logger.info('启动位置引擎，后台模式: $background');
    _backgroundMode = background;

    try {
      // Check if location services are enabled
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        // Location services are not enabled, send error notification
        _locationController.add(LocationUpdate(
          latitude: 0.0,
          longitude: 0.0,
          accuracy: 0.0,
          timestamp: DateTime.now(),
          rawSpeed: 0.0,
          filteredSpeed: 0.0,
          bearing: 0.0,
          error: const LocationError(
            code: LocationErrorCode.serviceDisabled,
            message: '系统定位未开启，请在设置中启用定位服务',
          ),
        ));
        _isRunning = true;
        return;
      }

      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Permission not granted, send error notification
        _locationController.add(LocationUpdate(
          latitude: 0.0,
          longitude: 0.0,
          accuracy: 0.0,
          timestamp: DateTime.now(),
          rawSpeed: 0.0,
          filteredSpeed: 0.0,
          bearing: 0.0,
          error: LocationError(
            code: LocationErrorCode.permissionDenied,
            message: '位置权限未授予，请在设置中授予位置权限',
          ),
        ));
        _isRunning = true;
        return;
      } else if (permission == LocationPermission.whileInUse && background) {
        // Need background permission for background mode
        _locationController.add(LocationUpdate(
          latitude: 0.0,
          longitude: 0.0,
          accuracy: 0.0,
          timestamp: DateTime.now(),
          rawSpeed: 0.0,
          filteredSpeed: 0.0,
          bearing: 0.0,
          error: LocationError(
            code: LocationErrorCode.permissionDenied,
            message: '后台定位需要更高的位置权限，请授予后台定位权限',
          ),
        ));
        _isRunning = true;
        return;
      }

      // Background notification service is temporarily disabled due to build issues

      // Configure location settings based on mode
      // 注意：不要设置 timeLimit，让系统持续获取位置
      late LocationSettings locationSettings;
      
      if (background) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 5, // 每5米更新一次
          forceLocationManager: true, // 强制使用 LocationManager
          intervalDuration: const Duration(seconds: 2),
        );
      } else {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0, // 任何位置变化都更新
          forceLocationManager: true, // 强制使用 LocationManager，更可靠
          intervalDuration: const Duration(milliseconds: 500), // 每500ms尝试获取
        );
      }
      
      _logger.info('开始监听位置流，设置: accuracy=${background ? "medium" : "high"}, forceLocationManager=true');
      
      // 先尝试获取一次当前位置，确保定位服务正常
      try {
        final currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
        );
        _logger.info('首次定位成功: 纬度=${currentPosition.latitude}, 经度=${currentPosition.longitude}, 精度=${currentPosition.accuracy}m');
        // 立即处理这个位置
        _processPositionUpdate(currentPosition);
      } catch (e) {
        _logger.warning('首次定位失败: $e，继续启动位置流...');
      }

      // Use position stream instead of periodic updates
      // This will keep location permission in use state
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((position) {
        // Process position update
        _processPositionUpdate(position);
      }, onError: (error) {
        // If there's an error, log it
        _logger.severe('获取位置流时出错: $error');

        LocationErrorCode errorCode = LocationErrorCode.unknown;
        String errorMessage = '获取位置失败：$error';

        // Try to determine error type
        if (error.toString().contains('PERMISSION_DENIED')) {
          errorCode = LocationErrorCode.permissionDenied;
          errorMessage = '位置权限被拒绝，请检查应用权限设置';
        } else if (error.toString().contains('SERVICE_DISABLED')) {
          errorCode = LocationErrorCode.serviceDisabled;
          errorMessage = '系统定位未开启，请在设置中启用定位服务';
        } else if (error.toString().contains('TimeoutException')) {
          errorCode = LocationErrorCode.unknown;
          errorMessage = '定位超时，请确保：\n1. GPS 已开启\n2. 移动到窗边或户外\n3. 定位模式为"高精确度"';
          _logger.warning('定位超时，请检查 GPS 信号和定位设置');
        }

        _locationController.add(LocationUpdate(
          latitude: 0.0,
          longitude: 0.0,
          accuracy: 0.0,
          timestamp: DateTime.now(),
          rawSpeed: 0.0,
          filteredSpeed: 0.0,
          bearing: 0.0,
          error: LocationError(
            code: errorCode,
            message: errorMessage,
          ),
        ));

        // Schedule a retry after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (_isRunning) {
            _logger.fine('尝试重新获取位置服务状态');
            _checkLocationServiceStatus();
          }
        });
      });

      _isRunning = true;
      _logger.info('位置引擎启动成功');
    } catch (e) {
      _logger.severe('启动位置引擎失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (!_isRunning) {
      _logger.fine('位置引擎未在运行中');
      return;
    }

    _logger.info('停止位置引擎');

    try {
      // Cancel position subscription
      await _positionSubscription?.cancel();
      _positionSubscription = null;

      // Stop trip recording if active
      if (_currentTripId != null) {
        await _endTripRecording();
      }

      // Cancel all timers
      _tripSaveTimer?.cancel();
      _idleTimer?.cancel();
      _detectionTimer?.cancel();

      // Background notification service is temporarily disabled due to build issues

      _isRunning = false;
      _logger.info('位置引擎停止成功');
    } catch (e) {
      _logger.severe('停止位置引擎失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> setUpdateInterval(int ms) async {
    // Update interval is no longer used as we're using continuous position stream
    _logger.fine('更新位置更新间隔: $ms ms');

    // Restart position stream with new settings if running
    if (_isRunning) {
      // Cancel existing subscription
      await _positionSubscription?.cancel();

      // Create new subscription with updated settings
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
          intervalDuration: Duration(milliseconds: ms),
        ),
      ).listen((position) {
        _processPositionUpdate(position);
      }, onError: (error) {
        _logger.severe('获取位置流时出错: $error');

        _locationController.add(LocationUpdate(
          latitude: 0.0,
          longitude: 0.0,
          accuracy: 0.0,
          timestamp: DateTime.now(),
          rawSpeed: 0.0,
          filteredSpeed: 0.0,
          bearing: 0.0,
          error: LocationError(
            code: LocationErrorCode.unknown,
            message: '获取位置失败：$error',
          ),
        ));
      });
    }
  }

  @override
  Future<void> setFilterParams(Map<String, dynamic> params) async {
    _logger.fine('更新速度滤波参数: $params');
    // No Kalman filter implementation
  }

  @override
  Future<void> setDistanceUnit(DistanceUnit unit) async {
    _logger.fine('设置距离单位: $unit');
    // Distance unit is handled by the caller, not by the engine itself
  }

  @override
  bool get isRunning => _isRunning;

  @override
  double convertSpeed(double speed, DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.kmh:
        return speed * 3.6; // Convert m/s to km/h
      case DistanceUnit.mph:
        return speed * 2.23694; // Convert m/s to mph
      default:
        return speed;
    }
  }

  void _checkLocationServiceStatus() async {
    try {
      // Check if location services are now enabled
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (isServiceEnabled) {
        // Check if permission is now granted
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // Both service and permission are now available, restart location engine
          _logger.info('位置服务和权限已恢复，重新启动位置引擎');
          await stop();
          await start();
          // Reset retry count after successful restart
          _retryCount = 0;
          return;
        }
      }

      // If services are still not available, schedule a retry with exponential backoff
      _retryCount++;
      if (_retryCount <= _maxRetryCount) {
        // Calculate exponential backoff delay
        final delaySeconds = _initialRetryDelay.inSeconds * (1 << (_retryCount - 1));
        final retryDelay = Duration(
          seconds: delaySeconds > _maxRetryDelay.inSeconds
              ? _maxRetryDelay.inSeconds
              : delaySeconds,
        );

        _logger.info(
            '位置服务或权限仍不可用，${_retryCount}/$_maxRetryCount 次重试，${retryDelay.inSeconds}秒后重试');

        // Schedule next retry
        Future.delayed(retryDelay, () {
          if (_isRunning) {
            _checkLocationServiceStatus();
          }
        });
      } else {
        _logger.warning('已达到最大重试次数 ($_maxRetryCount)，停止自动重试');
        // Reset retry count to allow manual restart
        _retryCount = 0;
      }
    } catch (e) {
      _logger.severe('检查位置服务状态时出错: $e');
      
      // If an error occurs during check, also schedule a retry
      _retryCount++;
      if (_retryCount <= _maxRetryCount) {
        final delay = Duration(
          seconds: _initialRetryDelay.inSeconds * (_retryCount),
        );
        _logger.info(
            '检查位置服务状态出错，${_retryCount}/$_maxRetryCount 次重试，${delay.inSeconds}秒后重试');
        Future.delayed(delay, () {
          if (_isRunning) {
            _checkLocationServiceStatus();
          }
        });
      }
    }
  }

  void _processPositionUpdate(Position position) {
    double rawSpeed = position.speed;

    _logger.fine(
        '获取到位置更新: 纬度=${position.latitude}, 经度=${position.longitude}, 原始速度=$rawSpeed m/s, 速度精度=${position.speedAccuracy}, 定位精度=${position.accuracy}');

    // Calculate speed from position if rawSpeed is very low
    if (rawSpeed < 0.1 && _lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      final timeDiff = position.timestamp
          .difference(_lastPosition!.timestamp)
          .inMilliseconds;
      if (timeDiff > 0) {
        // Convert distance to meters and time to seconds
        rawSpeed = distance / (timeDiff / 1000); // m/s
        _logger.finer(
            '通过位置变化计算速度: 距离=$distance米, 时间差=$timeDiff毫秒, 计算速度=$rawSpeed m/s');
      }
    }

    // Determine signal strength based on accuracy
    LocationSignalStrength signalStrength;
    if (position.accuracy < 10) {
      signalStrength = LocationSignalStrength.strong;
    } else if (position.accuracy < 30) {
      signalStrength = LocationSignalStrength.moderate;
    } else if (position.accuracy < 50) {
      signalStrength = LocationSignalStrength.weak;
    } else {
      signalStrength = LocationSignalStrength.none;
    }

    // Send location update to listeners
    _locationController.add(LocationUpdate(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      rawSpeed: rawSpeed,
      filteredSpeed: rawSpeed, // No Kalman filter, use raw speed
      bearing: position.heading,
      error: null,
      signalStrength: signalStrength,
    ));

    // No Kalman filter, use raw speed directly
    final currentSpeedKmh = rawSpeed * 3.6; // Convert to km/h

    // Update trip max speed if needed
    if (_currentTripId != null && currentSpeedKmh > _tripMaxSpeed) {
      _tripMaxSpeed = currentSpeedKmh;
    }

    // Only create location point if we're recording a trip
    if (_currentTripId != null) {
      final locationPoint = LocationPoint(
        tripId: _currentTripId!,
        timestamp: position.timestamp,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: currentSpeedKmh,
        bearing: position.heading,
      );

      // Add to pending list
      _pendingLocationPoints.add(locationPoint);
      _tripPointCount++;
    }

    // Update last position for next calculation
    _lastPosition = position;

    // Handle auto trip recording
    _handleAutoTripRecording(rawSpeed);
  }

  void _handleAutoTripRecording(double rawSpeed) {
    switch (_tripState) {
      case TripState.initial:
        // 初始状态：检查是否应该开始检测
        if (rawSpeed > _tripStartSpeedThreshold) {
          _startDetection();
        }
        break;
        
      case TripState.detecting:
        // 检测中状态：持续检测速度
        _speedBuffer.add(rawSpeed > _tripStartSpeedThreshold);
        
        // 保持缓冲区大小
        if (_speedBuffer.length > _requiredSamples) {
          _speedBuffer.removeAt(0);
        }
        
        // 检查是否满足开始条件
        if (_speedBuffer.every((isAboveThreshold) => isAboveThreshold)) {
          _startTripRecording();
        } else if (_speedBuffer.every((isAboveThreshold) => !isAboveThreshold)) {
          // 速度回到阈值以下，取消检测
          _cancelDetection();
        }
        break;
        
      case TripState.recording:
        // 记录中状态：检查是否应该结束
        if (rawSpeed <= _idleThreshold) {
          // 速度低于怠速阈值，开始怠速计时器
          _startIdleTimer();
        } else {
          // 速度恢复，取消怠速计时器
          _cancelIdleTimer();
        }
        break;
        
      case TripState.ending:
        // 结束状态：等待处理完成
        break;
    }
  }

  void _startDetection() {
    _logger.fine('进入检测中状态，开始检测行程开始条件');
    _tripState = TripState.detecting;
    _speedBuffer.clear();
    
    // 设置检测定时器，定期检查速度
    _detectionTimer = Timer.periodic(
      Duration(milliseconds: (_sampleInterval * 1000).round()),
      (timer) {
        // 检测逻辑已在 _handleAutoTripRecording 中实现
      },
    );
  }

  void _cancelDetection() {
    _logger.fine('取消行程检测，返回初始状态');
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _speedBuffer.clear();
    _tripState = TripState.initial;
  }

  void _startTripRecording() {
    _logger.info('开始行程记录，进入记录中状态');
    
    // 取消检测定时器
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _speedBuffer.clear();
    
    // 更新状态
    _tripState = TripState.recording;
    
    // Create new trip record
    final trip = TripRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}-${_randomString(6)}',
      startTime: DateTime.now(),
    );
    _currentTripId = trip.id;
    _tripStartTime = trip.startTime;
    _tripMaxSpeed = 0.0;
    _tripTotalDistance = 0.0;
    _tripPointCount = 0;
    _pendingLocationPoints.clear();

    // Start periodic trip save timer
    _tripSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _savePendingLocationPoints();
    });
  }

  Future<void> _endTripRecording() async {
    _logger.info('结束行程记录，进入结束状态');
    
    // 更新状态
    _tripState = TripState.ending;

    // Cancel all timers
    _tripSaveTimer?.cancel();
    _idleTimer?.cancel();
    _detectionTimer?.cancel();

    // Save any pending location points
    await _savePendingLocationPoints();

    // Calculate trip duration
    final duration = _tripStartTime != null
        ? DateTime.now().difference(_tripStartTime!)
        : Duration.zero;

    // Calculate average speed
    final averageSpeed = duration.inHours > 0
        ? _tripTotalDistance / duration.inHours
        : 0.0;

    // Create trip record
    final tripRecord = TripRecord(
      id: _currentTripId!,
      startTime: _tripStartTime!,
      endTime: DateTime.now(),
      totalDistance: _tripTotalDistance,
      maxSpeed: _tripMaxSpeed,
      averageSpeed: averageSpeed,
      drivingTime: duration,
    );

    // Save trip record to database
    await DatabaseService().updateTripRecord(tripRecord);
    _logger.fine('保存行程记录: $tripRecord');

    // Reset trip variables
    _currentTripId = null;
    _tripStartTime = null;
    _tripMaxSpeed = 0.0;
    _tripTotalDistance = 0.0;
    _tripPointCount = 0;
    _pendingLocationPoints.clear();
    _speedBuffer.clear();
    
    // 返回初始状态
    _tripState = TripState.initial;
  }

  Future<void> _savePendingLocationPoints() async {
    if (_pendingLocationPoints.isEmpty) {
      return;
    }

    _logger.fine('保存 ${_pendingLocationPoints.length} 个位置点，行程ID：${_pendingLocationPoints.first.tripId}');
    await DatabaseService().saveLocationPoints(_pendingLocationPoints);
    _pendingLocationPoints.clear();
  }

  void _startIdleTimer() {
    if (_idleTimer != null && _idleTimer!.isActive) {
      return;
    }

    _logger.fine('启动怠速检测计时器');
    _idleTimer = Timer(_idleTimeout, () async {
      _logger.info('检测到长时间怠速，结束行程');
      await _endTripRecording();
    });
  }

  void _cancelIdleTimer() {
    if (_idleTimer != null) {
      _logger.fine('取消怠速检测计时器');
      _idleTimer!.cancel();
      _idleTimer = null;
    }
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length]).join();
  }
}