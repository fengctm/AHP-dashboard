/// 故障信息模型

/// 故障级别
enum FaultLevel {
  emergency, // 紧急
  warning, // 警告
  info, // 信息
}

/// 故障类型
enum FaultType {
  bms, // BMS故障
  controller, // 控制器故障
  tpms, // TPMS故障
  system, // 系统故障
}

/// 故障信息
class FaultInfo {
  final String id;
  final FaultType type;
  final FaultLevel level;
  final String description;
  final String deviceId;
  final String ruleId;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isActive;

  FaultInfo({
    required this.id,
    required this.type,
    required this.level,
    required this.description,
    required this.deviceId,
    required this.ruleId,
    DateTime? timestamp,
    this.data = const {},
    this.isActive = true,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'FaultInfo(type: $type, level: $level, description: $description)';
  }
}
