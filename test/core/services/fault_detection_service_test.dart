import 'package:flutter_test/flutter_test.dart';
import 'package:ahp_dashboard/domain/usecases/detect_faults_usecase.dart';
import 'package:ahp_dashboard/data/models/device_data_model.dart';
import 'package:ahp_dashboard/domain/entities/fault_entity.dart';

void main() {
  group('FaultDetectionService', () {
    late FaultDetectionService faultService;

    setUp(() {
      faultService = FaultDetectionService();
    });

    test('should initialize with no active faults', () {
      expect(faultService.activeFaults, isEmpty);
    });

    test('should detect BMS overvoltage fault', () {
      // Create a device data with BMS cell voltage > 4.25V
      final deviceData = DeviceData(
        bms: BMSData(
          isConnected: true,
          status: '正常',
          basicInfo: BMSBasicInfo(),
          capacityInfo: BMSCapacityInfo(),
          electricalInfo: BMSElectricalInfo(),
          cellInfo: BMSCellInfo.withCalculations(
            cellCount: 1,
            cellVoltages: [4.3], // This should trigger BMS001 fault
          ),
          temperatureInfo: BMSTemperatureInfo(),
          protectionStatus: BMSProtectionStatus(),
          runningInfo: BMSRunningInfo(),
          batteryInfo: BMSBatteryInfo(),
          errors: [],
        ),
        controller: ControllerData(
          isConnected: true,
          status: '正常',
          controlInfo: ControllerControlInfo(),
          motorInfo: ControllerMotorInfo(),
          powerInfo: ControllerPowerInfo(),
          temperatureInfo: ControllerTemperatureInfo(),
          batteryInfo: ControllerBatteryInfo(),
          systemInfo: ControllerSystemInfo(),
          protectionStatus: ControllerProtectionStatus(),
          firmwareInfo: ControllerFirmwareInfo(),
          errors: [],
        ),
        tpms: TPMSData(
          isConnected: true,
          status: '正常',
          wheels: [],
          maxPressure: 0.0,
          minPressure: 0.0,
          maxTemperature: 0.0,
          minTemperature: 0.0,
          sensorStatus: '未知',
          errors: [],
        ),
      );

      // Detect faults
      faultService.detectFaults(deviceData, 'test-device');

      // Verify that BMS001 fault is detected
      final faults = faultService.activeFaults;
      expect(faults.isNotEmpty, true);
      final bmsFault = faults.firstWhere((fault) => fault.ruleId == 'BMS001', orElse: () => throw AssertionError('BMS001 fault not detected'));
      expect(bmsFault.type, equals(FaultType.bms));
      expect(bmsFault.level, equals(FaultLevel.emergency));
      expect(bmsFault.description, equals('单电芯电压过高'));
    });

    test('should detect controller overheating fault', () {
      // Create a device data with controller MOS temperature > 85°C
      final deviceData = DeviceData(
        bms: BMSData(
          isConnected: true,
          status: '正常',
          basicInfo: BMSBasicInfo(),
          capacityInfo: BMSCapacityInfo(),
          electricalInfo: BMSElectricalInfo(),
          cellInfo: BMSCellInfo(),
          temperatureInfo: BMSTemperatureInfo(),
          protectionStatus: BMSProtectionStatus(),
          runningInfo: BMSRunningInfo(),
          batteryInfo: BMSBatteryInfo(),
          errors: [],
        ),
        controller: ControllerData(
          isConnected: true,
          status: '正常',
          controlInfo: ControllerControlInfo(),
          motorInfo: ControllerMotorInfo(),
          powerInfo: ControllerPowerInfo(),
          temperatureInfo: ControllerTemperatureInfo(
            mosTemperature: 90.0, // This should trigger CTRL001 fault
          ),
          batteryInfo: ControllerBatteryInfo(),
          systemInfo: ControllerSystemInfo(),
          protectionStatus: ControllerProtectionStatus(),
          firmwareInfo: ControllerFirmwareInfo(),
          errors: [],
        ),
        tpms: TPMSData(
          isConnected: true,
          status: '正常',
          wheels: [],
          maxPressure: 0.0,
          minPressure: 0.0,
          maxTemperature: 0.0,
          minTemperature: 0.0,
          sensorStatus: '未知',
          errors: [],
        ),
      );

      // Detect faults
      faultService.detectFaults(deviceData, 'test-device');

      // Verify that CTRL001 fault is detected
      final faults = faultService.activeFaults;
      final controllerFault = faults.firstWhere((fault) => fault.ruleId == 'CTRL001', orElse: () => throw AssertionError('CTRL001 fault not detected'));
      expect(controllerFault.type, equals(FaultType.controller));
      expect(controllerFault.level, equals(FaultLevel.emergency));
      expect(controllerFault.description, equals('MOS温度过高'));
    });

    test('should clear all faults', () {
      // First, detect some faults
      final deviceData = DeviceData(
        bms: BMSData(
          isConnected: true,
          status: '正常',
          basicInfo: BMSBasicInfo(),
          capacityInfo: BMSCapacityInfo(),
          electricalInfo: BMSElectricalInfo(),
          cellInfo: BMSCellInfo.withCalculations(
            cellCount: 1,
            cellVoltages: [4.3],
          ),
          temperatureInfo: BMSTemperatureInfo(),
          protectionStatus: BMSProtectionStatus(),
          runningInfo: BMSRunningInfo(),
          batteryInfo: BMSBatteryInfo(),
          errors: [],
        ),
        controller: ControllerData(
          isConnected: true,
          status: '正常',
          controlInfo: ControllerControlInfo(),
          motorInfo: ControllerMotorInfo(),
          powerInfo: ControllerPowerInfo(),
          temperatureInfo: ControllerTemperatureInfo(),
          batteryInfo: ControllerBatteryInfo(),
          systemInfo: ControllerSystemInfo(),
          protectionStatus: ControllerProtectionStatus(),
          firmwareInfo: ControllerFirmwareInfo(),
          errors: [],
        ),
        tpms: TPMSData(
          isConnected: true,
          status: '正常',
          wheels: [],
          maxPressure: 0.0,
          minPressure: 0.0,
          maxTemperature: 0.0,
          minTemperature: 0.0,
          sensorStatus: '未知',
          errors: [],
        ),
      );

      faultService.detectFaults(deviceData, 'test-device');
      expect(faultService.activeFaults, isNotEmpty);

      // Clear all faults
      faultService.clearAllFaults();
      expect(faultService.activeFaults, isEmpty);
    });
  });
}
