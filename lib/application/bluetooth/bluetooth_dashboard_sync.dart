import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bluetooth_state.dart';
import '../dashboard/dashboard_provider.dart';
import '../../domain/models/ble_packet.dart';

/// 蓝牙数据同步观察者
///
/// 作为 ProviderScope 的 observer，自动监听蓝牙数据并同步到仪表盘
class BluetoothSyncObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // 监听蓝牙状态变化
    if (provider is StateNotifier<BluetoothState>) {
      final state = newValue as BluetoothState;

      // 如果有新的数据，同步到仪表盘
      if (state.latestData != null &&
          (previousValue as BluetoothState?)?.latestData?.timestamp !=
              state.latestData?.timestamp) {
        _syncToDashboard(container, state.latestData!);
      }
    }
  }

  /// 同步数据到仪表盘状态
  void _syncToDashboard(
      ProviderContainer container, YuanquDeviceData data) {
    final controller = data.controller;
    final bms = data.bms;
    final trip = data.trip;

    // 更新仪表盘状态
    container.read(dashboardStateProvider.notifier).updateFromYuanquData(
      rpm: controller.rpm,
      gear: controller.gear,
      voltage: controller.voltage,
      current: controller.current,
      power: controller.power,
      modulation: controller.modulation,
      direction: controller.direction,
      faults: controller.faults,
      phaseA: controller.phaseA,
      phaseC: controller.phaseC,
      motorTemp: controller.motorTemp,
      mosTemp: controller.mosTemp,
      soc: bms?.soc,
      totalDistance: trip?.totalDistance,
      modelName: data.modelName,
      serialNumber: data.serialNumber,
    );
  }
}
