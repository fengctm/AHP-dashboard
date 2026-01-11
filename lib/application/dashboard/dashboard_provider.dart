import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_state.dart';
import 'dart:async';

/// 仪表盘状态提供者
final dashboardStateProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// 仪表盘状态管理器
class DashboardNotifier extends StateNotifier<DashboardState> {
  Timer? _simulationTimer;
  bool _isSimulating = false;

  DashboardNotifier() : super(DashboardState.defaultState());

  /// 切换速度单位
  void toggleSpeedUnit() {
    state = state.copyWith(
      speedUnit: state.speedUnit == SpeedUnit.kmh ? SpeedUnit.mph : SpeedUnit.kmh,
    );
  }

  /// 切换信息区域展开状态
  void toggleInfoSection() {
    state = state.copyWith(
      isInfoSectionExpanded: !state.isInfoSectionExpanded,
    );
  }

  /// 更新横屏状态
  void updateOrientation(bool isHorizontal) {
    state = state.copyWith(isHorizontal: isHorizontal);
  }

  /// 更新GPS状态
  void updateGpsStatus(GpsSignalStatus status) {
    state = state.copyWith(gpsStatus: status);
  }

  /// 更新速度
  void updateSpeed(double speed) {
    state = state.copyWith(currentSpeed: speed);
  }

  /// 更新刹车状态
  void updateBraking(bool isBraking) {
    state = state.copyWith(isBraking: isBraking);
  }

  /// 更新控制器状态
  void updateController(ControllerStatus controller) {
    state = state.copyWith(controller: controller);
  }

  /// 更新BMS状态
  void updateBms(BmsStatus bms) {
    state = state.copyWith(bms: bms);
  }

  /// 更新行程信息
  void updateTrip(TripInfo trip) {
    state = state.copyWith(trip: trip);
  }

  /// 更新拓展模块
  void updateExtensions(List<ExtensionModule> extensions) {
    state = state.copyWith(extensions: extensions);
  }

  /// 完整更新状态
  void updateState(DashboardState newState) {
    state = newState;
  }

  /// 重置为默认状态
  void reset() {
    state = DashboardState.defaultState();
  }

  /// 启动模拟数据（用于测试/演示）
  void startSimulation() {
    if (_isSimulating) return;
    
    _isSimulating = true;
    double speed = 0.0;
    double direction = 1.0;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // 速度模拟：加速到40，减速到0，循环
      speed += direction * 0.5;
      if (speed >= 40.0) direction = -1.0;
      if (speed <= 0.0) direction = 1.0;

      // 随机更新其他状态
      final controller = ControllerStatus(
        temperature: 30.0 + (speed / 2) + (DateTime.now().millisecond % 5),
        voltage: 72.0 - (speed / 10),
        current: speed / 4,
        rpm: (speed * 40).toInt(),
        level: speed > 35 ? FaultLevel.warning : FaultLevel.normal,
      );

      final bms = BmsStatus(
        batteryLevel: 85.0 - (speed / 50),
        remainingRange: 120.0 - (speed / 2),
        cellTemp: 28.0 + (speed / 10),
        voltage: 72.0 - (speed / 10),
        level: speed > 38 ? FaultLevel.warning : FaultLevel.normal,
      );

      final trip = TripInfo(
        totalDistance: state.trip.totalDistance + (speed / 3600), // km per second
        tripDistance: state.trip.tripDistance + (speed / 3600),
        avgSpeed: (state.trip.avgSpeed + speed) / 2,
        maxSpeed: speed > state.trip.maxSpeed ? speed : state.trip.maxSpeed,
        energyUsed: 8.5 + (speed / 100),
      );

      // 随机GPS状态
      GpsSignalStatus gpsStatus = state.gpsStatus;
      if (DateTime.now().millisecond % 100 == 0) {
        final rand = DateTime.now().millisecond % 4;
        gpsStatus = GpsSignalStatus.values[rand];
      }

      // 随机拓展模块连接状态
      List<ExtensionModule> extensions = state.extensions;
      if (DateTime.now().millisecond % 50 == 0) {
        extensions = [
          ExtensionModule(name: "地图导航", connected: true, additionalInfo: "在线"),
          ExtensionModule(name: "媒体播放", connected: DateTime.now().millisecond % 2 == 0, additionalInfo: DateTime.now().millisecond % 2 == 0 ? "播放中" : null),
          ExtensionModule(name: "胎压监测", connected: DateTime.now().millisecond % 3 == 0),
        ];
      }

      state = state.copyWith(
        currentSpeed: speed,
        gpsStatus: gpsStatus,
        controller: controller,
        bms: bms,
        trip: trip,
        extensions: extensions,
      );
    });
  }

  /// 停止模拟
  void stopSimulation() {
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

/// 模拟数据提供者（用于测试）
final simulationProvider = Provider<bool>((ref) {
  return false; // 可以通过修改这个值来启用/禁用模拟
});

/// 速度单位转换辅助提供者
final speedDisplayProvider = Provider.family<double, double>((ref, speed) {
  final dashboardState = ref.watch(dashboardStateProvider);
  if (dashboardState.speedUnit == SpeedUnit.mph) {
    return speed * 0.621371;
  }
  return speed;
});
