import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../data/sources/remote/bluetooth/adapters/bms_adapter.dart';
import '../../../../data/sources/remote/bluetooth/adapters/controller_adapter.dart';
import '../../../../data/sources/remote/bluetooth/adapters/tpms_adapter.dart';
import '../../../../data/sources/remote/location/interfaces/location_engine.dart';
import '../../../../data/sources/remote/media/interfaces/media_controller.dart';
import '../../../../data/sources/local/interfaces/permission_manager.dart';
import '../../../../data/sources/remote/bluetooth/bluetooth_source.dart';
import '../../../../data/sources/remote/location/location_source.dart';
import '../../../../data/sources/remote/media/media_source.dart';
import '../../../../data/sources/local/permission_source.dart';
import '../../../theme/theme_provider.dart';
import '../../../../../core/utils/logger_helper.dart';
import '../../../../data/models/device_data_model.dart';
import 'trip_records_page.dart';
import 'device_detail_page.dart';
import '../widgets/device_status_card.dart';
import '../widgets/trip_stats.dart';
import '../widgets/map_preview.dart';
import '../widgets/media_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final Logger _logger = LoggerHelper.getModuleLogger('dashboard');

  late PermissionManager _permissionManager;
  late LocationEngine _locationEngine;
  late BluetoothManager _bluetoothManager;
  late MediaController _mediaController;

  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _avgSpeed = 0.0;
  double _tripDistance = 0.0; // 改为 double 类型，存储实际距离（km）

  // 记录上一次位置，用于计算里程
  LocationUpdate? _lastLocationUpdate;
  
  // 定位信号强度（默认为 none，表示未获取到位置）
  LocationSignalStrength _signalStrength = LocationSignalStrength.none;

  // Permission and location error states
  bool _locationPermissionGranted = false;
  bool _notificationPermissionGranted = false;
  String _locationError = '';
  bool _showPermissionRequest = false;

  // Media state
  MediaState? _currentMediaState;

  // 设备连接状态管理
  bool _isBmsConnected = false;
  String? _bmsBluetoothName;

  bool _isControllerConnected = false;
  String? _controllerBluetoothName;

  bool _isTpmsConnected = false;
  String? _tpmsBluetoothName;

  @override
  void initState() {
    super.initState();

    // Initialize services
    _permissionManager = PermissionManager();
    _locationEngine = LocationEngine();
    _bluetoothManager = BluetoothManager();
    _mediaController = MediaController();

    // Register device adapters
    _bluetoothManager.registerAdapter(AntProtectAdapter());
    _bluetoothManager.registerAdapter(NanJingYuanQuAdapter());
    _bluetoothManager.registerAdapter(TPMSAdapter());

    // Initialize services
    _initializeServices();

    // Listen for permission state changes
    _permissionManager.permissionStateStream.listen((permissionState) {
      if (permissionState.type == PermissionType.location) {
        setState(() {
          _locationPermissionGranted =
              permissionState.status == PermissionStatus.granted;
          _showPermissionRequest = !_locationPermissionGranted;
          if (!_locationPermissionGranted) {
            _locationError = '位置权限未授予，请授予位置权限以获取真实速度';
          } else {
            _locationError = '';
            // If permission is now granted, restart location engine to get fresh data
            _restartLocationEngine();
          }
        });
      } else if (permissionState.type == PermissionType.notification) {
        setState(() {
          _notificationPermissionGranted =
              permissionState.status == PermissionStatus.granted;
        });
      }
    });

    // Listen for location updates
    _locationEngine.onLocation.listen((location) {
      setState(() {
        if (location.error != null) {
          // Handle location error
          _locationPermissionGranted = false;
          _showPermissionRequest = true;
          _locationError = location.error!.message;
          _currentSpeed = 0.0;
          _signalStrength = LocationSignalStrength.none;
        } else {
          // Update speed and stats
          _locationPermissionGranted = true;
          _showPermissionRequest = false;
          _locationError = '';

          _currentSpeed = _locationEngine.convertSpeed(
            location.filteredSpeed,
            DistanceUnit.kmh,
          );

          // Update max speed
          if (_currentSpeed > _maxSpeed) {
            _maxSpeed = _currentSpeed;
          }

          // Update average speed (simplified)
          _avgSpeed = (_avgSpeed + _currentSpeed) / 2;

          // Update trip distance based on actual distance change
          if (_lastLocationUpdate != null) {
            // Calculate distance between last location and current location
            final distance = Geolocator.distanceBetween(
              _lastLocationUpdate!.latitude,
              _lastLocationUpdate!.longitude,
              location.latitude,
              location.longitude,
            );

            // Convert distance from meters to kilometers
            final distanceKm = distance / 1000.0;

            // Update distance regardless of distance, but log only significant changes
            _tripDistance += distanceKm;
            if (distance > 0.1) {
              _logger.fine(
                  '更新里程: 距离=$distance米, 里程增加=$distanceKm km, 总里程=$_tripDistance km');
            }
          }

          // Update signal strength
          _signalStrength = location.signalStrength;

          // Save current location for next update
          _lastLocationUpdate = location;
        }
      });
    });

    // Start Bluetooth scanning
    _bluetoothManager.startScan(timeout: const Duration(seconds: 30));
  }

  Future<void> _initializeServices() async {
    // Check and request permissions
    _logger.info('初始化服务：开始检查权限');
    final locationResult = await _permissionManager.ensureLocation(false);
    _logger.fine('位置权限检查结果：${locationResult.success}');

    final bluetoothResult = await _permissionManager.ensureBluetoothOn();
    _logger.fine('蓝牙权限检查结果：$bluetoothResult');

    final notificationResult = await _permissionManager.ensureNotification();
    _logger.fine('通知权限检查结果：${notificationResult.success}');

    setState(() {
      _notificationPermissionGranted = notificationResult.success;
    });

    // Start location engine only if location permission is granted
    if (locationResult.success) {
      _logger.info('位置权限已授予，启动位置引擎');
      await _locationEngine.start();
    }

    // Initialize media controller
    await _mediaController.initialize();
    _logger.info('媒体控制器初始化完成');

    // Listen for media state changes
    _mediaController.mediaStateStream.listen((mediaState) {
      setState(() {
        _currentMediaState = mediaState;
      });
    });
    _logger.info('媒体状态监听器已设置');
  }

  Future<void> _restartLocationEngine() async {
    try {
      _logger.info('重新启动位置引擎');
      await _locationEngine.stop();
      await _locationEngine.start();
    } catch (e) {
      _logger.severe('重新启动位置引擎失败: $e');
    }
  }

  @override
  void dispose() {
    _locationEngine.stop();
    _bluetoothManager.stopScan();
    _mediaController.dispose();
    super.dispose();
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AHP Dashboard'),
        actions: [
          // Theme toggle button
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
                tooltip: '切换主题',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // 上：时速卡片（固定）
        _buildSpeedGauge(),

        // 中：行程卡片（固定，控制高度）
        SizedBox(
          height: 150, // 控制行程卡片高度
          child: _buildQuickStats(),
        ),

        // 下：可滑动的设备状态卡片区域
        Expanded(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Device Cards
                  _buildDeviceCards(),

                  // Media Control
                  _buildMediaControl(),

                  // Map Preview
                  _buildMapPreview(),
                ],
              ),

              // Page Indicator
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildPageIndicator(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // 左侧：速度卡片，占满整个可用空间
        Expanded(
          flex: 1,
          child: _buildSpeedGauge(),
        ),

        // 中间：行程卡片，宽度缩小
        SizedBox(
          width: 180, // 限制行程卡片宽度
          child: _buildQuickStats(),
        ),

        // 右侧：设备状态卡片（可滑动）
        Expanded(
          flex: 2, // 为设备状态卡片预留更多空间
          child: Stack(
            children: [
              PageView(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Device Cards
                  _buildDeviceCards(),

                  // Media Control
                  _buildMediaControl(),

                  // Map Preview
                  _buildMapPreview(),
                ],
              ),

              // Page Indicator
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildPageIndicator(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: _currentPage == index ? 16 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFaultIndicators() {
    // 故障灯系统：只在有故障时显示
    // 收集所有活跃的故障
    final List<Widget> faultIndicators = [];
    
    // GPS 故障检测
    switch (_signalStrength) {
      case LocationSignalStrength.strong:
        // 信号强，无故障，不显示
        break;
      case LocationSignalStrength.moderate:
      case LocationSignalStrength.weak:
        // GPS 信号弱故障灯
        faultIndicators.add(_buildFaultLight(
          icon: Icons.gps_not_fixed,
          color: Colors.orange,
          tooltip: 'GPS信号弱',
        ));
        break;
      case LocationSignalStrength.none:
        // 无 GPS 信号故障灯
        faultIndicators.add(_buildFaultLight(
          icon: Icons.gps_off,
          color: Colors.red,
          tooltip: '无GPS信号',
        ));
        break;
    }
    
    // TODO: 将来可以添加更多故障检测
    // 例如：BMS 故障、控制器故障、TPMS 故障等
    
    // 如果没有故障，返回空容器
    if (faultIndicators.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 显示所有故障灯
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: faultIndicators,
    );
  }
  
  /// 构建单个故障灯
  Widget _buildFaultLight({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSpeedGauge() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: _showPermissionRequest || _locationError.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '无法获取位置信息',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _locationError.isNotEmpty
                          ? _locationError
                          : '位置权限未授予，请授予位置权限以获取真实速度',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      // Determine the appropriate action based on error message
                      if (_locationError.contains('系统定位未开启')) {
                        // Open location settings if system location is disabled
                        _logger.info('打开系统定位设置');
                        await AppSettings.openAppSettings(type: AppSettingsType.location);
                        // After returning from settings, recheck location service status
                        _logger.info('从系统定位设置返回，重新检查位置服务状态');
                        _restartLocationEngine();
                      } else {
                        // Request location permission if permission is denied
                        _logger.info('请求位置权限');
                        final result = await _permissionManager.ensureLocation(false);
                        if (!result.success) {
                          // If permission is still denied, open app settings
                          _logger.info('权限请求失败，打开应用设置');
                          await _permissionManager.openAppSettings();
                          // After returning from settings, recheck location permission
                          _logger.info('从应用设置返回，重新检查位置权限');
                          _restartLocationEngine();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Text(
                      _locationError.contains('系统定位未开启')
                          ? '开启系统定位'
                          : '授予位置权限',
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 故障灯区域
                  _buildFaultIndicators(),
                  const SizedBox(height: 8),
                  Text(
                    '当前速度',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentSpeed.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color ??
                          Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'km/h',
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return TripStats(
      maxSpeed: _maxSpeed,
      avgSpeed: _avgSpeed,
      tripDistance: _tripDistance,
      onViewTrips: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TripRecordsPage(),
          ),
        );
      },
    );
  }

  Widget _buildDeviceCards() {
    // 创建设备数据对象
    final bmsData = BMSData(
      isConnected: _isBmsConnected,
      bluetoothName: _bmsBluetoothName,
      status: _isBmsConnected ? '正常' : '未连接',
      basicInfo: BMSBasicInfo(
        batteryStatus: '放电',
      ),
      capacityInfo: BMSCapacityInfo(
        stateOfCharge: 85.0,
      ),
      electricalInfo: BMSElectricalInfo(
        totalVoltage: 48.2,
        current: 12.5,
        power: 602.5,
      ),
      temperatureInfo: BMSTemperatureInfo(
        mosTemperature: 35.0,
        sensorTemperatures: [25.0],
        maxTemperature: 25.0,
        minTemperature: 25.0,
      ),
      cellInfo: BMSCellInfo(),
      protectionStatus: BMSProtectionStatus(),
      runningInfo: BMSRunningInfo(),
      batteryInfo: BMSBatteryInfo(),
      errors: [],
    );

    final controllerData = ControllerData(
      isConnected: _isControllerConnected,
      bluetoothName: _controllerBluetoothName,
      status: _isControllerConnected ? '正常' : '未连接',
      controlInfo: ControllerControlInfo(
        gear: 'D3',
      ),
      motorInfo: ControllerMotorInfo(
        rpm: 6000,
        motorTemperature: 50.0,
      ),
      powerInfo: ControllerPowerInfo(
        voltage: 48.2,
        current: 15.2,
        power: 733, // 48.2V * 15.2A = 732.64W，四舍五入为整数
      ),
      temperatureInfo: ControllerTemperatureInfo(
        mosTemperature: 45.0,
      ),
      systemInfo: ControllerSystemInfo(
        systemStatus: 0, // 0表示正常运行
      ),
      batteryInfo: ControllerBatteryInfo(),
      protectionStatus: ControllerProtectionStatus(),
      firmwareInfo: ControllerFirmwareInfo(),
      errors: [],
    );

    final tpmsData = TPMSData(
      isConnected: _isTpmsConnected,
      bluetoothName: _tpmsBluetoothName,
      status: _isTpmsConnected ? '正常' : '未连接',
      wheels: [
        TPMSWheelInfo(
          position: 'frontLeft',
          pressure: 2.5,
          temperature: 30.0,
          isActive: true,
        ),
        TPMSWheelInfo(
          position: 'frontRight',
          pressure: 2.5,
          temperature: 30.0,
          isActive: true,
        ),
        TPMSWheelInfo(
          position: 'rearLeft',
          pressure: 2.5,
          temperature: 30.0,
          isActive: true,
        ),
        TPMSWheelInfo(
          position: 'rearRight',
          pressure: 2.5,
          temperature: 30.0,
          isActive: true,
        ),
      ],
      maxPressure: 2.5,
      minPressure: 2.5,
      maxTemperature: 30.0,
      minTemperature: 30.0,
      sensorStatus: '正常',
      errors: [],
    );

    final deviceData = DeviceData(
      bms: bmsData,
      controller: controllerData,
      tpms: tpmsData,
    );

    return DeviceStatusCard(
      deviceData: deviceData,
      onTap: () {
        // 点击跳转到设备详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceDetailPage(
              deviceData: deviceData,
              bluetoothManager: _bluetoothManager,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaControl() {
    return MediaCard(
      isPermissionGranted: _notificationPermissionGranted,
      onPermissionChanged: (bool granted) {
        setState(() {
          _notificationPermissionGranted = granted;
        });
      },
    );
  }

  Widget _buildMapPreview() {
    return const MapPreview();
  }
}
