import 'dart:async';
import 'package:logging/logging.dart';
import '../entities/fault_entity.dart';
import '../../data/models/device_data_model.dart';
import '../../core/utils/logger_helper.dart';

/// 故障检测服务
class FaultDetectionService {
  final StreamController<List<FaultInfo>> _faultStreamController = 
      StreamController<List<FaultInfo>>.broadcast();
  
  final Logger _logger = LoggerHelper.getCoreLogger('fault_detection_service');
  
  // 活跃故障列表
  final List<FaultInfo> _activeFaults = [];
  
  // 故障规则
  final Map<String, FaultRule> _rules = {
    // BMS规则
    'BMS001': FaultRule(
      id: 'BMS001',
      type: FaultType.bms,
      level: FaultLevel.emergency,
      description: '单电芯电压过高',
      check: (deviceData, deviceId) {
        final bmsData = deviceData.bms;
        return bmsData.cellInfo.cellVoltages.any((voltage) => voltage > 4.25);
      },
    ),
    'BMS002': FaultRule(
      id: 'BMS002',
      type: FaultType.bms,
      level: FaultLevel.emergency,
      description: '单电芯电压过低',
      check: (deviceData, deviceId) {
        final bmsData = deviceData.bms;
        return bmsData.cellInfo.cellVoltages.any((voltage) => voltage < 2.8);
      },
    ),
    'BMS003': FaultRule(
      id: 'BMS003',
      type: FaultType.bms,
      level: FaultLevel.warning,
      description: '电芯压差过大',
      check: (deviceData, deviceId) {
        final bmsData = deviceData.bms;
        return bmsData.cellInfo.voltageDiff > 0.3;
      },
    ),
    'BMS004': FaultRule(
      id: 'BMS004',
      type: FaultType.bms,
      level: FaultLevel.emergency,
      description: '温度过高',
      check: (deviceData, deviceId) {
        final bmsData = deviceData.bms;
        return bmsData.temperatureInfo.maxTemperature > 60;
      },
    ),
    'BMS005': FaultRule(
      id: 'BMS005',
      type: FaultType.bms,
      level: FaultLevel.warning,
      description: '剩余容量过低',
      check: (deviceData, deviceId) {
        final bmsData = deviceData.bms;
        return bmsData.capacityInfo.stateOfCharge < 10;
      },
    ),
    'BMS006': FaultRule(
      id: 'BMS006',
      type: FaultType.bms,
      level: FaultLevel.emergency,
      description: '电流过大',
      check: (deviceData, deviceId) {
        final bmsData = deviceData.bms;
        return bmsData.electricalInfo.current.abs() > 50; // 假设额定电流50A
      },
    ),
    
    // 控制器规则
    'CTRL001': FaultRule(
      id: 'CTRL001',
      type: FaultType.controller,
      level: FaultLevel.emergency,
      description: 'MOS温度过高',
      check: (deviceData, deviceId) {
        final controllerData = deviceData.controller;
        return controllerData.temperatureInfo.mosTemperature > 85;
      },
    ),
    'CTRL002': FaultRule(
      id: 'CTRL002',
      type: FaultType.controller,
      level: FaultLevel.emergency,
      description: '电机温度过高',
      check: (deviceData, deviceId) {
        final controllerData = deviceData.controller;
        return controllerData.motorInfo.motorTemperature > 120;
      },
    ),
    'CTRL003': FaultRule(
      id: 'CTRL003',
      type: FaultType.controller,
      level: FaultLevel.warning,
      description: '电流过大',
      check: (deviceData, deviceId) {
        final controllerData = deviceData.controller;
        return controllerData.powerInfo.current.abs() > 80; // 假设额定电流80A
      },
    ),
    'CTRL004': FaultRule(
      id: 'CTRL004',
      type: FaultType.controller,
      level: FaultLevel.warning,
      description: '系统状态异常',
      check: (deviceData, deviceId) {
        final controllerData = deviceData.controller;
        return controllerData.systemInfo.systemStatus != 0;
      },
    ),
    'CTRL005': FaultRule(
      id: 'CTRL005',
      type: FaultType.controller,
      level: FaultLevel.emergency,
      description: '电压过高',
      check: (deviceData, deviceId) {
        final controllerData = deviceData.controller;
        return controllerData.powerInfo.voltage > 90;
      },
    ),
    
    // TPMS规则
    'TPMS001': FaultRule(
      id: 'TPMS001',
      type: FaultType.tpms,
      level: FaultLevel.warning,
      description: '轮胎压力过低',
      check: (deviceData, deviceId) {
        final tpmsData = deviceData.tpms;
        return tpmsData.wheels.any((wheel) => wheel.isLowPressure || wheel.pressure < 1.8);
      },
    ),
    'TPMS002': FaultRule(
      id: 'TPMS002',
      type: FaultType.tpms,
      level: FaultLevel.warning,
      description: '轮胎压力过高',
      check: (deviceData, deviceId) {
        final tpmsData = deviceData.tpms;
        return tpmsData.wheels.any((wheel) => wheel.pressure > 3.5);
      },
    ),
    'TPMS003': FaultRule(
      id: 'TPMS003',
      type: FaultType.tpms,
      level: FaultLevel.warning,
      description: '轮胎温度过高',
      check: (deviceData, deviceId) {
        final tpmsData = deviceData.tpms;
        return tpmsData.wheels.any((wheel) => wheel.isHighTemperature || wheel.temperature > 70);
      },
    ),
  };
  
  Stream<List<FaultInfo>> get faultStream => _faultStreamController.stream;
  List<FaultInfo> get activeFaults => List.unmodifiable(_activeFaults);
  
  /// 检测设备数据故障
  void detectFaults(DeviceData deviceData, String deviceId) {
    _logger.fine('开始检测设备故障，设备ID: $deviceId');
    
    final detectedFaults = <FaultInfo>[];
    
    // 遍历所有规则，检查是否触发故障
    _rules.forEach((ruleId, rule) {
      final isFault = rule.check(deviceData, deviceId);
      
      if (isFault) {
        // 生成故障ID
        final faultId = '${rule.id}-${DateTime.now().millisecondsSinceEpoch}';
        
        // 创建故障信息
        final fault = FaultInfo(
          id: faultId,
          type: rule.type,
          level: rule.level,
          description: rule.description,
          deviceId: deviceId,
          ruleId: rule.id,
          data: {
            'deviceType': rule.type.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        
        detectedFaults.add(fault);
      }
    });
    
    // 更新活跃故障列表
    _updateActiveFaults(detectedFaults);
    
    // 发送故障列表更新
    _faultStreamController.add(_activeFaults);
    
    _logger.fine('故障检测完成，检测到 ${detectedFaults.length} 个故障，活跃故障 ${_activeFaults.length} 个');
  }
  
  /// 更新活跃故障列表
  void _updateActiveFaults(List<FaultInfo> detectedFaults) {
    // 清除已解决的故障
    final ruleIds = detectedFaults.map((fault) => fault.ruleId).toSet();
    _activeFaults.removeWhere((fault) => !ruleIds.contains(fault.ruleId));
    
    // 添加新检测到的故障
    for (final newFault in detectedFaults) {
      // 检查是否已存在相同规则的活跃故障
      final existingFaultIndex = _activeFaults.indexWhere((fault) => fault.ruleId == newFault.ruleId);
      
      if (existingFaultIndex == -1) {
        // 不存在，添加新故障
        _activeFaults.add(newFault);
      }
    }
  }
  
  /// 清除所有故障
  void clearAllFaults() {
    _activeFaults.clear();
    _faultStreamController.add(_activeFaults);
    _logger.info('已清除所有活跃故障');
  }
  
  /// 清除特定类型的故障
  void clearFaultsByType(FaultType type) {
    _activeFaults.removeWhere((fault) => fault.type == type);
    _faultStreamController.add(_activeFaults);
    _logger.info('已清除${type.toString()}类型的所有活跃故障');
  }
  
  /// 清除特定设备的故障
  void clearFaultsByDevice(String deviceId) {
    _activeFaults.removeWhere((fault) => fault.deviceId == deviceId);
    _faultStreamController.add(_activeFaults);
    _logger.info('已清除设备$deviceId的所有活跃故障');
  }
  
  /// 关闭资源
  void dispose() {
    _faultStreamController.close();
    _logger.info('故障检测服务已关闭');
  }
}

/// 故障规则
class FaultRule {
  final String id;
  final FaultType type;
  final FaultLevel level;
  final String description;
  final bool Function(DeviceData deviceData, String deviceId) check;
  
  FaultRule({
    required this.id,
    required this.type,
    required this.level,
    required this.description,
    required this.check,
  });
}
