import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import '../../../config/app_config.dart';
import '../../models/trip_record_model.dart';
import '../../models/location_point_model.dart';
import '../../models/bluetooth_device_model.dart';
import '../../models/device_snapshot_model.dart';
import '../../../../../core/utils/logger_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<AppConfig> _appConfigBox;
  late Box<TripRecord> _tripRecordBox;
  late Box<LocationPoint> _locationPointBox;
  late Box<AppBluetoothDevice> _bluetoothDeviceBox;
  late Box<DeviceSnapshot> _deviceSnapshotBox;

  bool _isInitialized = false;
  bool _isAdapterRegistered = false;

  final Logger _logger = LoggerHelper.getCoreLogger('database_service');

  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.fine('数据库服务已初始化，忽略重复请求');
      return;
    }

    _logger.info('开始初始化数据库服务');
    await Hive.initFlutter();

    // Register adapters only once
    if (!_isAdapterRegistered) {
      _logger.fine('注册数据库适配器...');
      try {
        Hive.registerAdapter(AppConfigAdapter());
        Hive.registerAdapter(TripRecordAdapter());
        Hive.registerAdapter(LocationPointAdapter());
        Hive.registerAdapter(AppBluetoothDeviceAdapter());
        Hive.registerAdapter(DeviceSnapshotAdapter());
        _isAdapterRegistered = true;
      } catch (e) {
        _logger.warning('适配器注册失败，可能已被注册: $e');
      }
    }

    // Open boxes
    _logger.fine('打开数据库盒子...');
    _appConfigBox = await Hive.openBox<AppConfig>('appConfig');
    _tripRecordBox = await Hive.openBox<TripRecord>('tripRecords');
    _locationPointBox = await Hive.openBox<LocationPoint>('locationPoints');
    _bluetoothDeviceBox = await Hive.openBox<AppBluetoothDevice>('bluetoothDevices');
    _deviceSnapshotBox = await Hive.openBox<DeviceSnapshot>('deviceSnapshots');

    _isInitialized = true;
    _logger.info('数据库服务初始化完成');

    // Create default config if not exists
    if (_appConfigBox.isEmpty) {
      _logger.fine('创建默认应用配置');
      await _appConfigBox.put('default', AppConfig());
    }
  }

  // App Config Methods
  Future<AppConfig> getAppConfig() async {
    await initialize();
    _logger.fine('获取应用配置');
    return _appConfigBox.get('default') ?? AppConfig();
  }

  Future<void> saveAppConfig(AppConfig config) async {
    await initialize();
    _logger.fine('保存应用配置');
    await _appConfigBox.put('default', config);
  }

  // Trip Record Methods
  Future<TripRecord> createTripRecord() async {
    await initialize();
    _logger.info('创建新的行程记录');
    final trip = TripRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    await _tripRecordBox.put(trip.id, trip);
    _logger.fine('行程记录创建成功，ID：${trip.id}');
    return trip;
  }

  Future<void> updateTripRecord(TripRecord trip) async {
    await initialize();
    _logger.fine('更新行程记录，ID：${trip.id}');
    await _tripRecordBox.put(trip.id, trip);
  }

  Future<TripRecord?> getTripRecord(String id) async {
    await initialize();
    _logger.fine('获取行程记录，ID：$id');
    return _tripRecordBox.get(id);
  }

  Future<List<TripRecord>> getAllTripRecords() async {
    await initialize();
    _logger.fine('获取所有行程记录');
    final records = _tripRecordBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    _logger.finer('共获取到 ${records.length} 条行程记录');
    return records;
  }

  Future<void> deleteTripRecord(String id) async {
    await initialize();
    _logger.info('删除行程记录，ID：$id');
    await _tripRecordBox.delete(id);
    // Delete associated location points
    final locationPoints =
        _locationPointBox.values.where((point) => point.tripId == id).toList();
    if (locationPoints.isNotEmpty) {
      _logger.fine('删除关联的 ${locationPoints.length} 个位置点');
      await _locationPointBox.deleteAll(locationPoints.map((p) => p.key));
    }
  }

  // Location Point Methods
  Future<void> saveLocationPoint(LocationPoint point) async {
    await initialize();
    _logger.finer('保存单个位置点，行程ID：${point.tripId}');
    await _locationPointBox.add(point);
  }

  Future<void> saveLocationPoints(List<LocationPoint> points) async {
    await initialize();
    if (points.isEmpty) {
      _logger.fine('位置点列表为空，跳过保存');
      return;
    }
    _logger.fine('保存 ${points.length} 个位置点，行程ID：${points.first.tripId}');
    await _locationPointBox.addAll(points);
  }

  Future<List<LocationPoint>> getLocationPoints(String tripId) async {
    await initialize();
    _logger.fine('获取行程 $tripId 的位置点');
    final points = _locationPointBox.values
        .where((point) => point.tripId == tripId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _logger.finer('共获取到 ${points.length} 个位置点');
    return points;
  }

  // Bluetooth Device Methods
  Future<void> saveBluetoothDevice(AppBluetoothDevice device) async {
    await initialize();
    _logger.fine('保存蓝牙设备，ID：${device.deviceId}');
    await _bluetoothDeviceBox.put(device.deviceId, device);
  }

  Future<void> updateBluetoothDevice(AppBluetoothDevice device) async {
    await initialize();
    _logger.fine('更新蓝牙设备，ID：${device.deviceId}');
    await _bluetoothDeviceBox.put(device.deviceId, device);
  }

  Future<AppBluetoothDevice?> getBluetoothDevice(String deviceId) async {
    await initialize();
    _logger.fine('获取蓝牙设备，ID：$deviceId');
    return _bluetoothDeviceBox.get(deviceId);
  }

  Future<List<AppBluetoothDevice>> getAllBluetoothDevices() async {
    await initialize();
    _logger.fine('获取所有蓝牙设备');
    final devices = _bluetoothDeviceBox.values.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    _logger.finer('共获取到 ${devices.length} 个蓝牙设备');
    return devices;
  }

  Future<List<AppBluetoothDevice>> getBluetoothDevicesByType(String deviceType) async {
    await initialize();
    _logger.fine('获取设备类型为 $deviceType 的蓝牙设备');
    final devices = _bluetoothDeviceBox.values
        .where((device) => device.deviceType == deviceType)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    _logger.finer('共获取到 ${devices.length} 个设备类型为 $deviceType 的蓝牙设备');
    return devices;
  }

  Future<void> deleteBluetoothDevice(String deviceId) async {
    await initialize();
    _logger.info('删除蓝牙设备，ID：$deviceId');
    await _bluetoothDeviceBox.delete(deviceId);
  }

  // Device Snapshot Methods
  Future<void> saveDeviceSnapshot(DeviceSnapshot snapshot) async {
    await initialize();
    _logger.finer('保存设备快照，行程ID：${snapshot.tripId}, 设备类型：${snapshot.deviceType}');
    await _deviceSnapshotBox.add(snapshot);
  }

  Future<void> saveDeviceSnapshots(List<DeviceSnapshot> snapshots) async {
    await initialize();
    if (snapshots.isEmpty) {
      _logger.fine('设备快照列表为空，跳过保存');
      return;
    }
    _logger.fine('保存 ${snapshots.length} 个设备快照');
    await _deviceSnapshotBox.addAll(snapshots);
  }

  Future<List<DeviceSnapshot>> getDeviceSnapshots(String tripId) async {
    await initialize();
    _logger.fine('获取行程 $tripId 的设备快照');
    final snapshots = _deviceSnapshotBox.values
        .where((snapshot) => snapshot.tripId == tripId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _logger.finer('共获取到 ${snapshots.length} 个设备快照');
    return snapshots;
  }

  Future<List<DeviceSnapshot>> getDeviceSnapshotsByType(
      String tripId, String deviceType) async {
    await initialize();
    _logger.fine('获取行程 $tripId 的 $deviceType 设备快照');
    final snapshots = _deviceSnapshotBox.values
        .where((snapshot) =>
            snapshot.tripId == tripId && snapshot.deviceType == deviceType)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _logger.finer('共获取到 ${snapshots.length} 个 $deviceType 设备快照');
    return snapshots;
  }

  Future<void> clearAllData() async {
    await initialize();
    _logger.severe('清除所有数据库数据');
    await _appConfigBox.clear();
    await _tripRecordBox.clear();
    await _locationPointBox.clear();
    await _bluetoothDeviceBox.clear();
    await _deviceSnapshotBox.clear();
    // Recreate default config
    await _appConfigBox.put('default', AppConfig());
    _logger.info('所有数据已清除，已重新创建默认配置');
  }
}
