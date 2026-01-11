import 'package:flutter/foundation.dart';

/// 速度单位枚举
enum SpeedUnit {
  kmh,
  mph,
}

/// 故障级别枚举
enum FaultLevel {
  normal,    // 正常 - 绿色
  warning,   // 警告 - 黄色
  error,     // 错误 - 红色
}

/// GPS信号状态
enum GpsSignalStatus {
  excellent, // 优秀 - 信号满格
  good,      // 良好 - 信号良好
  poor,      // 较差 - 信号弱
  none,      // 无信号 - 无信号
}

/// 控制器状态
class ControllerStatus {
  final double temperature; // 温度 °C
  final double voltage;     // 电压 V
  final double current;     // 电流 A
  final int rpm;            // 转速 RPM
  final FaultLevel level;   // 故障级别

  ControllerStatus({
    required this.temperature,
    required this.voltage,
    required this.current,
    required this.rpm,
    required this.level,
  });

  ControllerStatus copyWith({
    double? temperature,
    double? voltage,
    double? current,
    int? rpm,
    FaultLevel? level,
  }) {
    return ControllerStatus(
      temperature: temperature ?? this.temperature,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      rpm: rpm ?? this.rpm,
      level: level ?? this.level,
    );
  }
}

/// BMS状态
class BmsStatus {
  final double batteryLevel;  // 电池百分比 0-100
  final double remainingRange; // 剩余续航 km
  final double cellTemp;      // 电芯温度 °C
  final double voltage;       // 总电压 V
  final FaultLevel level;     // 故障级别

  BmsStatus({
    required this.batteryLevel,
    required this.remainingRange,
    required this.cellTemp,
    required this.voltage,
    required this.level,
  });

  BmsStatus copyWith({
    double? batteryLevel,
    double? remainingRange,
    double? cellTemp,
    double? voltage,
    FaultLevel? level,
  }) {
    return BmsStatus(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      remainingRange: remainingRange ?? this.remainingRange,
      cellTemp: cellTemp ?? this.cellTemp,
      voltage: voltage ?? this.voltage,
      level: level ?? this.level,
    );
  }
}

/// 行程信息
class TripInfo {
  final double totalDistance;  // 总里程 km
  final double tripDistance;   // 当前行程 km
  final double avgSpeed;       // 平均速度 km/h
  final double maxSpeed;       // 最大速度 km/h
  final double energyUsed;     // 能耗 kWh/100km

  TripInfo({
    required this.totalDistance,
    required this.tripDistance,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.energyUsed,
  });

  TripInfo copyWith({
    double? totalDistance,
    double? tripDistance,
    double? avgSpeed,
    double? maxSpeed,
    double? energyUsed,
  }) {
    return TripInfo(
      totalDistance: totalDistance ?? this.totalDistance,
      tripDistance: tripDistance ?? this.tripDistance,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      energyUsed: energyUsed ?? this.energyUsed,
    );
  }
}

/// 拓展模块状态
class ExtensionModule {
  final String name;           // 模块名称
  final bool connected;        // 是否连接
  final String? additionalInfo; // 额外信息

  ExtensionModule({
    required this.name,
    required this.connected,
    this.additionalInfo,
  });

  ExtensionModule copyWith({
    String? name,
    bool? connected,
    String? additionalInfo,
  }) {
    return ExtensionModule(
      name: name ?? this.name,
      connected: connected ?? this.connected,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

/// 仪表盘状态
@immutable
class DashboardState {
  // 核心数据
  final double currentSpeed;        // 当前速度
  final SpeedUnit speedUnit;        // 速度单位
  final GpsSignalStatus gpsStatus;  // GPS信号状态
  final bool isBraking;             // 是否刹车

  // 子系统状态
  final ControllerStatus controller;
  final BmsStatus bms;
  final TripInfo trip;
  final List<ExtensionModule> extensions;

  // UI状态
  final bool isInfoSectionExpanded; // 信息区域是否展开
  final bool isHorizontal;          // 是否横屏模式

  const DashboardState({
    required this.currentSpeed,
    required this.speedUnit,
    required this.gpsStatus,
    required this.isBraking,
    required this.controller,
    required this.bms,
    required this.trip,
    required this.extensions,
    required this.isInfoSectionExpanded,
    required this.isHorizontal,
  });

  /// 默认状态（用于初始化）
  factory DashboardState.defaultState() {
    return DashboardState(
      currentSpeed: 0.0,
      speedUnit: SpeedUnit.kmh,
      gpsStatus: GpsSignalStatus.excellent,
      isBraking: false,
      controller: ControllerStatus(
        temperature: 35.0,
        voltage: 72.0,
        current: 5.0,
        rpm: 0,
        level: FaultLevel.normal,
      ),
      bms: BmsStatus(
        batteryLevel: 85.0,
        remainingRange: 120.0,
        cellTemp: 28.0,
        voltage: 72.0,
        level: FaultLevel.normal,
      ),
      trip: TripInfo(
        totalDistance: 1250.0,
        tripDistance: 25.5,
        avgSpeed: 28.0,
        maxSpeed: 45.0,
        energyUsed: 8.5,
      ),
      extensions: [
        ExtensionModule(name: "地图导航", connected: true, additionalInfo: "在线"),
        ExtensionModule(name: "媒体播放", connected: true, additionalInfo: "播放中"),
        ExtensionModule(name: "胎压监测", connected: false),
      ],
      isInfoSectionExpanded: true,
      isHorizontal: false,
    );
  }

  DashboardState copyWith({
    double? currentSpeed,
    SpeedUnit? speedUnit,
    GpsSignalStatus? gpsStatus,
    bool? isBraking,
    ControllerStatus? controller,
    BmsStatus? bms,
    TripInfo? trip,
    List<ExtensionModule>? extensions,
    bool? isInfoSectionExpanded,
    bool? isHorizontal,
  }) {
    return DashboardState(
      currentSpeed: currentSpeed ?? this.currentSpeed,
      speedUnit: speedUnit ?? this.speedUnit,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      isBraking: isBraking ?? this.isBraking,
      controller: controller ?? this.controller,
      bms: bms ?? this.bms,
      trip: trip ?? this.trip,
      extensions: extensions ?? this.extensions,
      isInfoSectionExpanded: isInfoSectionExpanded ?? this.isInfoSectionExpanded,
      isHorizontal: isHorizontal ?? this.isHorizontal,
    );
  }

  /// 获取故障灯级别（综合所有子系统）
  FaultLevel get overallFaultLevel {
    final levels = [
      controller.level,
      bms.level,
    ];
    
    if (levels.contains(FaultLevel.error)) return FaultLevel.error;
    if (levels.contains(FaultLevel.warning)) return FaultLevel.warning;
    return FaultLevel.normal;
  }

  /// 获取GPS故障级别
  FaultLevel get gpsFaultLevel {
    switch (gpsStatus) {
      case GpsSignalStatus.excellent:
      case GpsSignalStatus.good:
        return FaultLevel.normal;
      case GpsSignalStatus.poor:
        return FaultLevel.warning;
      case GpsSignalStatus.none:
        return FaultLevel.error;
    }
  }

  /// 速度转换
  double get displaySpeed {
    if (speedUnit == SpeedUnit.mph) {
      return currentSpeed * 0.621371;
    }
    return currentSpeed;
  }

  String get speedUnitLabel {
    return speedUnit == SpeedUnit.kmh ? 'km/h' : 'mph';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardState &&
        other.currentSpeed == currentSpeed &&
        other.speedUnit == speedUnit &&
        other.gpsStatus == gpsStatus &&
        other.isBraking == isBraking &&
        other.controller == controller &&
        other.bms == bms &&
        other.trip == trip &&
        listEquals(other.extensions, extensions) &&
        other.isInfoSectionExpanded == isInfoSectionExpanded &&
        other.isHorizontal == isHorizontal;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentSpeed,
      speedUnit,
      gpsStatus,
      isBraking,
      controller,
      bms,
      trip,
      Object.hashAll(extensions),
      isInfoSectionExpanded,
      isHorizontal,
    );
  }
}
