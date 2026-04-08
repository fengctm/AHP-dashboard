import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_state.dart';

/// 仪表盘状态提供者
final dashboardStateProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// 仪表盘状态管理器
class DashboardNotifier extends StateNotifier<DashboardState> {
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

  /// 从远驱控制器数据更新状态
  void updateFromYuanquData({
    int? rpm,
    int? gear,
    double? voltage,
    double? current,
    double? power,
    double? modulation,
    int? direction,
    List<String>? faults,
    double? phaseA,
    double? phaseC,
    int? motorTemp,
    int? mosTemp,
    int? soc,
    double? totalDistance,
  }) {
    // 更新控制器状态
    final newController = state.controller.copyWithYuanquData(
      rpm: rpm,
      gear: gear,
      voltage: voltage,
      current: current,
      power: power,
      modulation: modulation,
      direction: direction,
      faults: faults,
      phaseA: phaseA,
      phaseC: phaseC,
      motorTemp: motorTemp,
      mosTemp: mosTemp,
    );

    // 更新BMS状态
    final newBms = state.bms.copyWithYuanquData(
      soc: soc,
      voltage: voltage,
    );

    // 更新行程数据
    TripInfo? newTrip = state.trip;
    if (totalDistance != null) {
      newTrip = state.trip.copyWith(totalDistance: totalDistance);
    }

    state = state.copyWith(
      controller: newController,
      bms: newBms,
      trip: newTrip,
    );
  }
}
