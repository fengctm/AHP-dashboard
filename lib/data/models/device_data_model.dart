/// 设备数据模型

// BMS子模型定义

/// BMS基础信息
class BMSBasicInfo {
  final String batteryStatus; // 电池状态：静止、放电、充电、异常
  final bool dischargeMos; // 放电MOS状态
  final bool chargeMos; // 充电MOS状态
  final bool balanceStatus; // 均衡状态

  const BMSBasicInfo({
    this.batteryStatus = '未知',
    this.dischargeMos = false,
    this.chargeMos = false,
    this.balanceStatus = false,
  });

  factory BMSBasicInfo.fromMap(Map<String, dynamic> map) {
    return BMSBasicInfo(
      batteryStatus: map['batteryStatus']?.toString() ?? '未知',
      dischargeMos: map['dischargeMos'] ?? false,
      chargeMos: map['chargeMos'] ?? false,
      balanceStatus: map['balanceStatus'] ?? false,
    );
  }
}

/// BMS容量信息
class BMSCapacityInfo {
  final double totalCapacity; // 总容量 (Ah)
  final double remainingCapacity; // 剩余容量 (Ah)
  final double cycleCapacity; // 循环容量 (Ah)
  final double stateOfCharge; // 充电状态 (%)
  final double stateOfHealth; // 健康状态 (%)

  const BMSCapacityInfo({
    this.totalCapacity = 0.0,
    this.remainingCapacity = 0.0,
    this.cycleCapacity = 0.0,
    this.stateOfCharge = 0.0,
    this.stateOfHealth = 100.0,
  });

  factory BMSCapacityInfo.fromMap(Map<String, dynamic> map) {
    return BMSCapacityInfo(
      totalCapacity: (map['totalCapacity'] as num?)?.toDouble() ?? 0.0,
      remainingCapacity: (map['remainingCapacity'] as num?)?.toDouble() ?? 0.0,
      cycleCapacity: (map['cycleCapacity'] as num?)?.toDouble() ?? 0.0,
      stateOfCharge: (map['stateOfCharge'] as num?)?.toDouble() ?? 0.0,
      stateOfHealth: (map['stateOfHealth'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

/// BMS电气信息
class BMSElectricalInfo {
  final double totalVoltage; // 总电压 (V)
  final double current; // 电流 (A)
  final double power; // 功率 (W)
  final double remainingEnergy; // 剩余能量 (Wh)

  const BMSElectricalInfo({
    this.totalVoltage = 0.0,
    this.current = 0.0,
    this.power = 0.0,
    this.remainingEnergy = 0.0,
  });

  factory BMSElectricalInfo.fromMap(Map<String, dynamic> map) {
    final voltage = (map['totalVoltage'] as num?)?.toDouble() ?? 0.0;
    final current = (map['current'] as num?)?.toDouble() ?? 0.0;
    final power = voltage * current;

    return BMSElectricalInfo(
      totalVoltage: voltage,
      current: current,
      power: (map['power'] as num?)?.toDouble() ?? power,
      remainingEnergy: (map['remainingEnergy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// BMS电芯信息
class BMSCellInfo {
  final int cellCount; // 电芯数量
  final double maxCellVoltage; // 最大电芯电压 (V)
  final double minCellVoltage; // 最小电芯电压 (V)
  final double avgCellVoltage; // 平均电芯电压 (V)
  final double voltageDiff; // 电芯压差 (V)
  final List<double> cellVoltages; // 各电芯电压列表 (V)

  // 默认常量构造函数
  const BMSCellInfo({
    this.cellCount = 0,
    this.maxCellVoltage = 0.0,
    this.minCellVoltage = 0.0,
    this.avgCellVoltage = 0.0,
    this.voltageDiff = 0.0,
    this.cellVoltages = const [],
  });
  
  // 工厂构造函数 - 用于自动计算值
  factory BMSCellInfo.withCalculations({
    int? cellCount,
    double? maxCellVoltage,
    double? minCellVoltage,
    double? avgCellVoltage,
    double? voltageDiff,
    List<double> cellVoltages = const [],
  }) {
    // 根据cellVoltages自动计算相关值
    final actualCellCount = cellCount ?? cellVoltages.length;
    
    double actualMaxVoltage = maxCellVoltage ?? 0.0;
    double actualMinVoltage = minCellVoltage ?? 0.0;
    double actualAvgVoltage = avgCellVoltage ?? 0.0;
    double actualVoltageDiff = voltageDiff ?? 0.0;
    
    if (cellVoltages.isNotEmpty) {
      actualMaxVoltage = maxCellVoltage ?? cellVoltages.reduce((a, b) => a > b ? a : b);
      actualMinVoltage = minCellVoltage ?? cellVoltages.reduce((a, b) => a < b ? a : b);
      actualAvgVoltage = avgCellVoltage ?? (cellVoltages.reduce((a, b) => a + b) / cellVoltages.length);
      actualVoltageDiff = voltageDiff ?? (actualMaxVoltage - actualMinVoltage);
    }
    
    return BMSCellInfo(
      cellCount: actualCellCount,
      maxCellVoltage: actualMaxVoltage,
      minCellVoltage: actualMinVoltage,
      avgCellVoltage: actualAvgVoltage,
      voltageDiff: actualVoltageDiff,
      cellVoltages: cellVoltages,
    );
  }

  factory BMSCellInfo.fromMap(Map<String, dynamic> map) {
    final voltages = List<double>.from(map['cellVoltages'] ?? []);
    double maxVoltage = 0.0;
    double minVoltage = 0.0;
    double avgVoltage = 0.0;
    double diff = 0.0;

    if (voltages.isNotEmpty) {
      maxVoltage = voltages.reduce((a, b) => a > b ? a : b);
      minVoltage = voltages.reduce((a, b) => a < b ? a : b);
      avgVoltage = voltages.reduce((a, b) => a + b) / voltages.length;
      diff = maxVoltage - minVoltage;
    }

    return BMSCellInfo(
      cellCount: (map['cellCount'] as num?)?.toInt() ?? voltages.length,
      maxCellVoltage: (map['maxCellVoltage'] as num?)?.toDouble() ?? maxVoltage,
      minCellVoltage: (map['minCellVoltage'] as num?)?.toDouble() ?? minVoltage,
      avgCellVoltage: (map['avgCellVoltage'] as num?)?.toDouble() ?? avgVoltage,
      voltageDiff: (map['voltageDiff'] as num?)?.toDouble() ?? diff,
      cellVoltages: voltages,
    );
  }
}

/// BMS温度信息
class BMSTemperatureInfo {
  final double mosTemperature; // MOS温度 (°C)
  final double balanceTemperature; // 均衡温度 (°C)
  final List<double> sensorTemperatures; // 传感器温度列表 (°C)
  final double maxTemperature; // 最高温度 (°C)
  final double minTemperature; // 最低温度 (°C)

  const BMSTemperatureInfo({
    this.mosTemperature = 0.0,
    this.balanceTemperature = 0.0,
    this.sensorTemperatures = const [],
    this.maxTemperature = 0.0,
    this.minTemperature = 0.0,
  });

  factory BMSTemperatureInfo.fromMap(Map<String, dynamic> map) {
    final temps = List<double>.from(map['sensorTemperatures'] ?? []);
    double maxTemp = 0.0;
    double minTemp = 0.0;

    if (temps.isNotEmpty) {
      maxTemp = temps.reduce((a, b) => a > b ? a : b);
      minTemp = temps.reduce((a, b) => a < b ? a : b);
    }

    return BMSTemperatureInfo(
      mosTemperature: (map['mosTemperature'] as num?)?.toDouble() ?? 0.0,
      balanceTemperature: (map['balanceTemperature'] as num?)?.toDouble() ?? 0.0,
      sensorTemperatures: temps,
      maxTemperature: (map['maxTemperature'] as num?)?.toDouble() ?? maxTemp,
      minTemperature: (map['minTemperature'] as num?)?.toDouble() ?? minTemp,
    );
  }
}

/// BMS保护状态
class BMSProtectionStatus {
  final bool overVoltage; // 过压保护
  final bool underVoltage; // 欠压保护
  final bool overCurrent; // 过流保护
  final bool overTemperature; // 过热保护
  final bool underTemperature; // 欠温保护
  final bool shortCircuit; // 短路保护

  const BMSProtectionStatus({
    this.overVoltage = false,
    this.underVoltage = false,
    this.overCurrent = false,
    this.overTemperature = false,
    this.underTemperature = false,
    this.shortCircuit = false,
  });

  factory BMSProtectionStatus.fromMap(Map<String, dynamic> map) {
    return BMSProtectionStatus(
      overVoltage: map['overVoltage'] ?? false,
      underVoltage: map['underVoltage'] ?? false,
      overCurrent: map['overCurrent'] ?? false,
      overTemperature: map['overTemperature'] ?? false,
      underTemperature: map['underTemperature'] ?? false,
      shortCircuit: map['shortCircuit'] ?? false,
    );
  }
}

/// BMS运行信息
class BMSRunningInfo {
  final Duration runningTime; // 运行时间
  final DateTime? lastChargeTime; // 最后充电时间
  final DateTime? lastDischargeTime; // 最后放电时间

  const BMSRunningInfo({
    this.runningTime = Duration.zero,
    this.lastChargeTime,
    this.lastDischargeTime,
  });

  factory BMSRunningInfo.fromMap(Map<String, dynamic> map) {
    return BMSRunningInfo(
      runningTime: Duration(milliseconds: (map['runningTimeMs'] as num?)?.toInt() ?? 0),
      lastChargeTime: map['lastChargeTime'] as DateTime?,
      lastDischargeTime: map['lastDischargeTime'] as DateTime?,
    );
  }
}

/// BMS电池信息
class BMSBatteryInfo {
  final String batteryType; // 电池类型
  final double nominalVoltage; // 标称电压 (V)
  final double ratedCapacity; // 额定容量 (Ah)
  final String? manufactureDate; // 生产日期
  final int cycleCount; // 循环次数

  const BMSBatteryInfo({
    this.batteryType = 'lithium_ion',
    this.nominalVoltage = 0.0,
    this.ratedCapacity = 0.0,
    this.manufactureDate,
    this.cycleCount = 0,
  });

  factory BMSBatteryInfo.fromMap(Map<String, dynamic> map) {
    return BMSBatteryInfo(
      batteryType: map['batteryType']?.toString() ?? 'lithium_ion',
      nominalVoltage: (map['nominalVoltage'] as num?)?.toDouble() ?? 0.0,
      ratedCapacity: (map['ratedCapacity'] as num?)?.toDouble() ?? 0.0,
      manufactureDate: map['manufactureDate']?.toString(),
      cycleCount: (map['cycleCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// BMS设备数据
class BMSData {
  final bool isConnected;
  final String? bluetoothName;
  final String status;
  final BMSBasicInfo basicInfo;
  final BMSCapacityInfo capacityInfo;
  final BMSElectricalInfo electricalInfo;
  final BMSCellInfo cellInfo;
  final BMSTemperatureInfo temperatureInfo;
  final BMSProtectionStatus protectionStatus;
  final BMSRunningInfo runningInfo;
  final BMSBatteryInfo batteryInfo;
  final List<String> errors;

  BMSData({
    required this.isConnected,
    this.bluetoothName,
    required this.status,
    this.basicInfo = const BMSBasicInfo(),
    this.capacityInfo = const BMSCapacityInfo(),
    this.electricalInfo = const BMSElectricalInfo(),
    this.cellInfo = const BMSCellInfo(),
    this.temperatureInfo = const BMSTemperatureInfo(),
    this.protectionStatus = const BMSProtectionStatus(),
    this.runningInfo = const BMSRunningInfo(),
    this.batteryInfo = const BMSBatteryInfo(),
    this.errors = const [],
  });

  factory BMSData.fromMap(Map<String, dynamic> map, bool isConnected, String? bluetoothName) {
    return BMSData(
      isConnected: isConnected,
      bluetoothName: bluetoothName,
      status: map['status']?.toString() ?? (isConnected ? '正常' : '未连接'),
      basicInfo: BMSBasicInfo.fromMap(map['basicInfo'] ?? {}),
      capacityInfo: BMSCapacityInfo.fromMap(map['capacityInfo'] ?? {}),
      electricalInfo: BMSElectricalInfo.fromMap(map['electricalInfo'] ?? {}),
      cellInfo: BMSCellInfo.fromMap(map['cellInfo'] ?? {}),
      temperatureInfo: BMSTemperatureInfo.fromMap(map['temperatureInfo'] ?? {}),
      protectionStatus: BMSProtectionStatus.fromMap(map['protectionStatus'] ?? {}),
      runningInfo: BMSRunningInfo.fromMap(map['runningInfo'] ?? {}),
      batteryInfo: BMSBatteryInfo.fromMap(map['batteryInfo'] ?? {}),
      errors: List<String>.from(map['errors'] ?? []),
    );
  }

  // 向后兼容的getter方法
  double get soc => capacityInfo.stateOfCharge;
  double get totalVoltage => electricalInfo.totalVoltage;
  double get voltage => electricalInfo.totalVoltage;
  double get current => electricalInfo.current;
  double get power => electricalInfo.power;
  double get maxCellVoltage => cellInfo.maxCellVoltage;
  double get minCellVoltage => cellInfo.minCellVoltage;
  double get maxTemperature => temperatureInfo.maxTemperature;
  double get temperature => temperatureInfo.maxTemperature;
  double get minTemperature => temperatureInfo.minTemperature;
  double get avgCellVoltage => cellInfo.avgCellVoltage;
  double get voltageDiff => cellInfo.voltageDiff;
  int get cellCount => cellInfo.cellCount;
  double get stateOfHealth => capacityInfo.stateOfHealth;
  double get mosTemperature => temperatureInfo.mosTemperature;
  double get t0Temperature => temperatureInfo.sensorTemperatures.isNotEmpty ? temperatureInfo.sensorTemperatures[0] : 0.0;
  String get batteryStatus => basicInfo.batteryStatus;
}

// Controller子模型定义

/// 控制器控制信息
class ControllerControlInfo {
  final String gear; // 挡位
  final bool brakeStatus; // 刹车状态
  final double throttlePercentage; // 油门百分比 (%)
  final double throttleVoltage; // 油门电压 (V)

  const ControllerControlInfo({
    this.gear = 'N',
    this.brakeStatus = false,
    this.throttlePercentage = 0.0,
    this.throttleVoltage = 0.0,
  });

  factory ControllerControlInfo.fromMap(Map<String, dynamic> map) {
    return ControllerControlInfo(
      gear: map['gear']?.toString() ?? 'N',
      brakeStatus: map['brakeStatus'] ?? false,
      throttlePercentage: (map['throttlePercentage'] as num?)?.toDouble() ?? 0.0,
      throttleVoltage: (map['throttleVoltage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 控制器电机信息
class ControllerMotorInfo {
  final int rpm; // 转速 (RPM)
  final double? phaseCurrentA; // A相电流 (A)
  final double? phaseCurrentB; // B相电流 (A)
  final double? phaseCurrentC; // C相电流 (A)
  final double motorTemperature; // 电机温度 (°C)

  const ControllerMotorInfo({
    this.rpm = 0,
    this.phaseCurrentA,
    this.phaseCurrentB,
    this.phaseCurrentC,
    this.motorTemperature = 0.0,
  });

  factory ControllerMotorInfo.fromMap(Map<String, dynamic> map) {
    return ControllerMotorInfo(
      rpm: (map['rpm'] as num?)?.toInt() ?? 0,
      phaseCurrentA: (map['phaseCurrentA'] as num?)?.toDouble(),
      phaseCurrentB: (map['phaseCurrentB'] as num?)?.toDouble(),
      phaseCurrentC: (map['phaseCurrentC'] as num?)?.toDouble(),
      motorTemperature: (map['motorTemperature'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 控制器功率信息
class ControllerPowerInfo {
  final int power; // 功率 (W)
  final double voltage; // 电压 (V)
  final double current; // 电流 (A)
  final double efficiency; // 效率 (%)

  const ControllerPowerInfo({
    this.power = 0,
    this.voltage = 0.0,
    this.current = 0.0,
    this.efficiency = 0.0,
  });

  factory ControllerPowerInfo.fromMap(Map<String, dynamic> map) {
    return ControllerPowerInfo(
      power: (map['power'] as num?)?.toInt() ?? 0,
      voltage: (map['voltage'] as num?)?.toDouble() ?? 0.0,
      current: (map['current'] as num?)?.toDouble() ?? 0.0,
      efficiency: (map['efficiency'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 控制器温度信息
class ControllerTemperatureInfo {
  final double mosTemperature; // MOS温度 (°C)
  final double controllerTemperature; // 控制器温度 (°C)
  final double ambientTemperature; // 环境温度 (°C)

  const ControllerTemperatureInfo({
    this.mosTemperature = 0.0,
    this.controllerTemperature = 0.0,
    this.ambientTemperature = 0.0,
  });

  factory ControllerTemperatureInfo.fromMap(Map<String, dynamic> map) {
    return ControllerTemperatureInfo(
      mosTemperature: (map['mosTemperature'] as num?)?.toDouble() ?? 0.0,
      controllerTemperature: (map['controllerTemperature'] as num?)?.toDouble() ?? 0.0,
      ambientTemperature: (map['ambientTemperature'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 控制器电池信息
class ControllerBatteryInfo {
  final double batteryPercent; // 电池百分比 (%)
  final double batteryVoltage; // 电池电压 (V)
  final double batteryCurrent; // 电池电流 (A)

  const ControllerBatteryInfo({
    this.batteryPercent = 0.0,
    this.batteryVoltage = 0.0,
    this.batteryCurrent = 0.0,
  });

  factory ControllerBatteryInfo.fromMap(Map<String, dynamic> map) {
    return ControllerBatteryInfo(
      batteryPercent: (map['batteryPercent'] as num?)?.toDouble() ?? 0.0,
      batteryVoltage: (map['batteryVoltage'] as num?)?.toDouble() ?? 0.0,
      batteryCurrent: (map['batteryCurrent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 控制器系统信息
class ControllerSystemInfo {
  final int systemStatus; // 系统状态码
  final String selfLearningStatus; // 自学习状态
  final String motorStatus; // 电机状态
  final bool weakMagneticStatus; // 弱磁状态
  final bool mtpaStatus; // MTPA状态

  const ControllerSystemInfo({
    this.systemStatus = 0,
    this.selfLearningStatus = '未开始',
    this.motorStatus = '未知',
    this.weakMagneticStatus = false,
    this.mtpaStatus = false,
  });

  factory ControllerSystemInfo.fromMap(Map<String, dynamic> map) {
    return ControllerSystemInfo(
      systemStatus: (map['systemStatus'] as num?)?.toInt() ?? 0,
      selfLearningStatus: map['selfLearningStatus']?.toString() ?? '未开始',
      motorStatus: map['motorStatus']?.toString() ?? '未知',
      weakMagneticStatus: map['weakMagneticStatus'] ?? false,
      mtpaStatus: map['mtpaStatus'] ?? false,
    );
  }
}

/// 控制器保护状态
class ControllerProtectionStatus {
  final bool overCurrent; // 过流保护
  final bool overTemperature; // 过热保护
  final bool underVoltage; // 欠压保护
  final bool overVoltage; // 过压保护
  final bool hallError; // 霍尔故障
  final bool phaseLoss; // 缺相保护

  const ControllerProtectionStatus({
    this.overCurrent = false,
    this.overTemperature = false,
    this.underVoltage = false,
    this.overVoltage = false,
    this.hallError = false,
    this.phaseLoss = false,
  });

  factory ControllerProtectionStatus.fromMap(Map<String, dynamic> map) {
    return ControllerProtectionStatus(
      overCurrent: map['overCurrent'] ?? false,
      overTemperature: map['overTemperature'] ?? false,
      underVoltage: map['underVoltage'] ?? false,
      overVoltage: map['overVoltage'] ?? false,
      hallError: map['hallError'] ?? false,
      phaseLoss: map['phaseLoss'] ?? false,
    );
  }
}

/// 控制器固件信息
class ControllerFirmwareInfo {
  final String version; // 固件版本
  final String hardwareVersion; // 硬件版本
  final String bootloaderVersion; // 引导程序版本

  const ControllerFirmwareInfo({
    this.version = '1.0.0',
    this.hardwareVersion = 'V1.0',
    this.bootloaderVersion = '1.0',
  });

  factory ControllerFirmwareInfo.fromMap(Map<String, dynamic> map) {
    return ControllerFirmwareInfo(
      version: map['version']?.toString() ?? '1.0.0',
      hardwareVersion: map['hardwareVersion']?.toString() ?? 'V1.0',
      bootloaderVersion: map['bootloaderVersion']?.toString() ?? '1.0',
    );
  }
}

/// 控制器设备数据
class ControllerData {
  final bool isConnected;
  final String? bluetoothName;
  final String status;
  final ControllerControlInfo controlInfo;
  final ControllerMotorInfo motorInfo;
  final ControllerPowerInfo powerInfo;
  final ControllerTemperatureInfo temperatureInfo;
  final ControllerBatteryInfo batteryInfo;
  final ControllerSystemInfo systemInfo;
  final ControllerProtectionStatus protectionStatus;
  final ControllerFirmwareInfo firmwareInfo;
  final List<String> errors;

  ControllerData({
    required this.isConnected,
    this.bluetoothName,
    required this.status,
    this.controlInfo = const ControllerControlInfo(),
    this.motorInfo = const ControllerMotorInfo(),
    this.powerInfo = const ControllerPowerInfo(),
    this.temperatureInfo = const ControllerTemperatureInfo(),
    this.batteryInfo = const ControllerBatteryInfo(),
    this.systemInfo = const ControllerSystemInfo(),
    this.protectionStatus = const ControllerProtectionStatus(),
    this.firmwareInfo = const ControllerFirmwareInfo(),
    this.errors = const [],
  });

  factory ControllerData.fromMap(Map<String, dynamic> map, bool isConnected, String? bluetoothName) {
    return ControllerData(
      isConnected: isConnected,
      bluetoothName: bluetoothName,
      status: map['status']?.toString() ?? (isConnected ? '正常' : '未连接'),
      controlInfo: ControllerControlInfo.fromMap(map['controlInfo'] ?? {}),
      motorInfo: ControllerMotorInfo.fromMap(map['motorInfo'] ?? {}),
      powerInfo: ControllerPowerInfo.fromMap(map['powerInfo'] ?? {}),
      temperatureInfo: ControllerTemperatureInfo.fromMap(map['temperatureInfo'] ?? {}),
      batteryInfo: ControllerBatteryInfo.fromMap(map['batteryInfo'] ?? {}),
      systemInfo: ControllerSystemInfo.fromMap(map['systemInfo'] ?? {}),
      protectionStatus: ControllerProtectionStatus.fromMap(map['protectionStatus'] ?? {}),
      firmwareInfo: ControllerFirmwareInfo.fromMap(map['firmwareInfo'] ?? {}),
      errors: List<String>.from(map['errors'] ?? []),
    );
  }

  // 向后兼容的getter方法
  int get power => powerInfo.power;
  double get voltage => powerInfo.voltage;
  double get current => powerInfo.current;
  double get mosTemperature => temperatureInfo.mosTemperature;
  double get temperature => temperatureInfo.mosTemperature;
  double get motorTemperature => motorInfo.motorTemperature;
  int get rpm => motorInfo.rpm;
  double get efficiency => powerInfo.efficiency;
  String get gear => controlInfo.gear;
  bool get brakeStatus => controlInfo.brakeStatus;
  double get throttlePercentage => controlInfo.throttlePercentage;
  String get systemStatus => systemInfo.systemStatus == 0 ? '正常运行' : '异常';
  double get speed => 0.0; // 临时实现，实际应该从GPS数据获取
}

// TPMS子模型定义

/// 单个轮胎的TPMS信息
class TPMSWheelInfo {
  final String position; // 轮胎位置：frontLeft, frontRight, rearLeft, rearRight
  final double pressure; // 压力 (bar)
  final double temperature; // 温度 (°C)
  final bool isActive; // 传感器是否激活
  final bool isLowPressure; // 是否低压力
  final bool isHighTemperature; // 是否高温
  final int batteryLevel; // 电池电量 (%)

  const TPMSWheelInfo({
    required this.position,
    this.pressure = 0.0,
    this.temperature = 0.0,
    this.isActive = false,
    this.isLowPressure = false,
    this.isHighTemperature = false,
    this.batteryLevel = 100,
  });

  factory TPMSWheelInfo.fromMap(Map<String, dynamic> map) {
    return TPMSWheelInfo(
      position: map['position']?.toString() ?? 'unknown',
      pressure: (map['pressure'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      isActive: map['isActive'] ?? false,
      isLowPressure: map['isLowPressure'] ?? false,
      isHighTemperature: map['isHighTemperature'] ?? false,
      batteryLevel: (map['batteryLevel'] as num?)?.toInt() ?? 100,
    );
  }
}

/// TPMS设备数据
class TPMSData {
  final bool isConnected;
  final String? bluetoothName;
  final String status;
  final List<TPMSWheelInfo> wheels;
  final double maxPressure;
  final double minPressure;
  final double maxTemperature;
  final double minTemperature;
  final String sensorStatus;
  final List<String> errors;

  TPMSData({
    required this.isConnected,
    this.bluetoothName,
    required this.status,
    this.wheels = const [],
    this.maxPressure = 0.0,
    this.minPressure = 0.0,
    this.maxTemperature = 0.0,
    this.minTemperature = 0.0,
    this.sensorStatus = '未知',
    this.errors = const [],
  });

  factory TPMSData.fromMap(Map<String, dynamic> map, bool isConnected, String? bluetoothName) {
    final wheels = List<Map<String, dynamic>>.from(map['wheels'] ?? [])
        .map((wheelMap) => TPMSWheelInfo.fromMap(wheelMap))
        .toList();

    double maxPressure = 0.0;
    double minPressure = double.infinity;
    double maxTemperature = 0.0;
    double minTemperature = double.infinity;

    for (final wheel in wheels) {
      if (wheel.pressure > maxPressure) maxPressure = wheel.pressure;
      if (wheel.pressure < minPressure) minPressure = wheel.pressure;
      if (wheel.temperature > maxTemperature) maxTemperature = wheel.temperature;
      if (wheel.temperature < minTemperature) minTemperature = wheel.temperature;
    }

    // 处理默认值
    if (wheels.isEmpty) {
      minPressure = 0.0;
      minTemperature = 0.0;
    }

    return TPMSData(
      isConnected: isConnected,
      bluetoothName: bluetoothName,
      status: map['status']?.toString() ?? (isConnected ? '正常' : '未连接'),
      wheels: wheels,
      maxPressure: (map['maxPressure'] as num?)?.toDouble() ?? maxPressure,
      minPressure: (map['minPressure'] as num?)?.toDouble() ?? minPressure,
      maxTemperature: (map['maxTemperature'] as num?)?.toDouble() ?? maxTemperature,
      minTemperature: (map['minTemperature'] as num?)?.toDouble() ?? minTemperature,
      sensorStatus: map['sensorStatus']?.toString() ?? '未知',
      errors: List<String>.from(map['errors'] ?? []),
    );
  }

  // 向后兼容的getter方法
  List<double> get tirePressures => wheels.map((w) => w.pressure).toList();
  List<double> get tireTemperatures => wheels.map((w) => w.temperature).toList();
  double get avgPressure => wheels.isNotEmpty ? wheels.map((w) => w.pressure).reduce((a, b) => a + b) / wheels.length : 0.0;
  double get avgTemperature => wheels.isNotEmpty ? wheels.map((w) => w.temperature).reduce((a, b) => a + b) / wheels.length : 0.0;
  double get pressure => avgPressure;
  double get temperature => avgTemperature;
}

/// 完整设备数据
class DeviceData {
  final BMSData bms;
  final ControllerData controller;
  final TPMSData tpms;

  DeviceData({
    required this.bms,
    required this.controller,
    required this.tpms,
  });
}
