import 'dart:typed_data';
import '../../core/parsers/yuanqu_ble_parser.dart';

/// BLE协议类型枚举
enum BleProtocolType {
  flashRead, // FlashRead协议
  legacy,    // Legacy协议
  unknown,   // 未知协议
}

/// BLE数据包原始数据
class BlePacket {
  final Uint8List data;
  final String hexString;
  final BleProtocolType protocolType;
  final int? cmd;      // Legacy协议的CMD
  final int? addr;     // FlashRead协议的地址
  final int? index;    // FlashRead协议的索引
  final DateTime timestamp;

  BlePacket({
    required this.data,
    required this.hexString,
    required this.protocolType,
    this.cmd,
    this.addr,
    this.index,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从原始字节数组创建BLE数据包
  factory BlePacket.fromBytes(Uint8List bytes) {
    final hexStr = bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    // 判定协议类型
    BleProtocolType protocolType;
    int? cmd;
    int? addr;
    int? index;

    if ((bytes[1] & 0xC0) == 0x80) {
      // FlashRead 协议
      protocolType = BleProtocolType.flashRead;
      index = bytes[1] & 0x7F;
      // 从解析器获取地址
      addr = YuanquBleParser.flashReadAddr[index!];
    } else {
      // Legacy 协议
      protocolType = BleProtocolType.legacy;
      cmd = bytes[1];
    }

    return BlePacket(
      data: bytes,
      hexString: hexStr,
      protocolType: protocolType,
      cmd: cmd,
      addr: addr,
      index: index,
    );
  }

  /// 从hex字符串创建BLE数据包
  factory BlePacket.fromHex(String hexStr) {
    final bytes = _hexToBytes(hexStr);
    return BlePacket.fromBytes(bytes);
  }

  /// 验证数据包是否有效
  bool get isValid {
    return data.length == 16 && data[0] == 0xAA;
  }

  @override
  String toString() {
    return 'BlePacket(protocol: $protocolType, hex: $hexString, '
        'cmd: $cmd, addr: $addr, index: $index)';
  }

  static Uint8List _hexToBytes(String hexStr) {
    final hex = hexStr.replaceAll(' ', '').toLowerCase();
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}

/// 控制器状态数据
class ControllerData {
  final int? rpm;              // 转速
  final int? gear;             // 挡位 0-3
  final double? voltage;       // 电压 V
  final double? current;       // 电流 A
  final double? power;         // 功率 W
  final double? modulation;    // 调制比 0.0-2.0
  final int? direction;        // 方向 1=前进, -1=后退, 0=静止
  final bool? isStop;          // 停机标志
  final List<String>? faults;  // 故障列表
  final double? phaseA;        // A相电流 A
  final double? phaseC;        // C相电流 A
  final int? motorTemp;        // 电机温度 ℃
  final int? mosTemp;          // MOS温度 ℃
  final double? throttleV;     // 油门电压 V
  final int? throttleDepth;    // 油门深度ADC
  final bool? weakField;       // 弱磁模式
  final bool? motorOn;         // 电机开启
  final bool? autolearn;       // 自学习中
  final DateTime timestamp;    // 数据时间戳

  ControllerData({
    this.rpm,
    this.gear,
    this.voltage,
    this.current,
    this.power,
    this.modulation,
    this.direction,
    this.isStop,
    this.faults,
    this.phaseA,
    this.phaseC,
    this.motorTemp,
    this.mosTemp,
    this.throttleV,
    this.throttleDepth,
    this.weakField,
    this.motorOn,
    this.autolearn,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从解析结果创建控制器数据
  factory ControllerData.fromParsedData(Map<String, dynamic> data) {
    return ControllerData(
      rpm: data['rpm'] as int?,
      gear: data['gear'] as int?,
      voltage: (data['voltage'] as num?)?.toDouble(),
      current: (data['current'] as num?)?.toDouble(),
      power: (data['power'] as num?)?.toDouble(),
      modulation: (data['modulation'] as num?)?.toDouble(),
      direction: data['direction'] as int?,
      isStop: data['stop'] as bool?,
      faults: data['faults'] as List<String>?,
      phaseA: (data['phase_a'] as num?)?.toDouble(),
      phaseC: (data['phase_c'] as num?)?.toDouble(),
      motorTemp: data['motor_temp'] as int?,
      mosTemp: data['mos_temp'] as int?,
      throttleV: (data['throttle_v'] as num?)?.toDouble(),
      throttleDepth: data['throttle_depth'] as int?,
      weakField: data['weak_field'] as bool?,
      motorOn: data['motor_on'] as bool?,
      autolearn: data['autolearn'] as bool?,
    );
  }

  /// 合并新数据
  ControllerData merge(ControllerData other) {
    return ControllerData(
      rpm: other.rpm ?? rpm,
      gear: other.gear ?? gear,
      voltage: other.voltage ?? voltage,
      current: other.current ?? current,
      power: other.power ?? power,
      modulation: other.modulation ?? modulation,
      direction: other.direction ?? direction,
      isStop: other.isStop ?? isStop,
      faults: other.faults ?? faults,
      phaseA: other.phaseA ?? phaseA,
      phaseC: other.phaseC ?? phaseC,
      motorTemp: other.motorTemp ?? motorTemp,
      mosTemp: other.mosTemp ?? mosTemp,
      throttleV: other.throttleV ?? throttleV,
      throttleDepth: other.throttleDepth ?? throttleDepth,
      weakField: other.weakField ?? weakField,
      motorOn: other.motorOn ?? motorOn,
      autolearn: other.autolearn ?? autolearn,
      timestamp: other.timestamp,
    );
  }

  /// 是否有故障
  bool get hasFault {
    return faults != null && faults!.isNotEmpty && !(faults!.length == 1 && faults![0] == '系统正常');
  }

  /// 获取温度（优先使用电机温度，否则使用MOS温度）
  int? get temperature => motorTemp ?? mosTemp;

  @override
  String toString() {
    return 'ControllerData(rpm: $rpm, gear: $gear, voltage: $voltage V, '
        'current: $current A, power: $power W, temp: $temperature°C)';
  }
}

/// BMS电池数据
class BmsData {
  final int? soc;              // 电量百分比 0-100
  final double? remainingRange; // 剩余续航 km
  final int? cellTemp;         // 电芯温度 ℃
  final double? voltage;       // 总电压 V
  final List<CellData>? cells; // 电芯数据
  final int? seriesCount;      // 串联数
  final DateTime timestamp;

  BmsData({
    this.soc,
    this.remainingRange,
    this.cellTemp,
    this.voltage,
    this.cells,
    this.seriesCount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从解析结果创建BMS数据
  factory BmsData.fromParsedData(Map<String, dynamic> data) {
    final cells = <CellData>[];

    // 解析电芯数据（如果有的话）
    for (int i = 0; i < 24; i++) {
      final mvKey = 'cell_${i}_mv';
      final capKey = 'cell_${i}_cap';
      if (data.containsKey(mvKey)) {
        cells.add(CellData(
          index: i,
          voltageMv: data[mvKey] as int?,
          capacity: data[capKey] as int?,
        ));
      }
    }

    return BmsData(
      soc: data['soc'] as int?,
      voltage: (data['voltage'] as num?)?.toDouble(),
      seriesCount: data['series_count'] as int?,
      cells: cells.isNotEmpty ? cells : null,
    );
  }

  /// 合并新数据
  BmsData merge(BmsData other) {
    return BmsData(
      soc: other.soc ?? soc,
      remainingRange: other.remainingRange ?? remainingRange,
      cellTemp: other.cellTemp ?? cellTemp,
      voltage: other.voltage ?? voltage,
      seriesCount: other.seriesCount ?? seriesCount,
      cells: other.cells ?? cells,
      timestamp: other.timestamp,
    );
  }

  @override
  String toString() {
    return 'BmsData(soc: $soc%, voltage: $voltage V, cells: ${cells?.length ?? 0})';
  }
}

/// 电芯数据
class CellData {
  final int index;
  final int? voltageMv;  // 电压 mV
  final int? capacity;   // 容量 0-127

  CellData({
    required this.index,
    this.voltageMv,
    this.capacity,
  });

  /// 获取电压（V）
  double? get voltage => voltageMv != null ? voltageMv! / 1000.0 : null;

  @override
  String toString() {
    return 'CellData($index: ${voltage?.toStringAsFixed(3)}V, cap: $capacity)';
  }
}

/// 行程数据
class TripData {
  final double? totalDistance;  // 总里程 km
  final double? tripDistance;   // 当前行程 km
  final int? totalTimeSeconds;  // 总工作时长 秒
  final double? avgPowerWh;     // 平均能耗 Wh/Km
  final int? turns;             // 圈数
  final DateTime timestamp;

  TripData({
    this.totalDistance,
    this.tripDistance,
    this.totalTimeSeconds,
    this.avgPowerWh,
    this.turns,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从解析结果创建行程数据
  factory TripData.fromParsedData(Map<String, dynamic> data) {
    double? totalDistance;
    if (data.containsKey('distance_low')) {
      final low = data['distance_low'] as int;
      final high = data['distance_high'] as int? ?? 0;
      totalDistance = ((high << 16) + low) / 10.0;
    }

    return TripData(
      totalDistance: totalDistance,
      totalTimeSeconds: data['total_time_s'] as int?,
      avgPowerWh: (data['avg_power_wh'] as num?)?.toDouble(),
      turns: data['turns'] as int?,
    );
  }

  /// 获取工作时长（小时）
  double? get workHours =>
      totalTimeSeconds != null ? totalTimeSeconds! / 3600.0 : null;

  @override
  String toString() {
    return 'TripData(distance: ${totalDistance?.toStringAsFixed(1)}km, '
        'time: ${workHours?.toStringAsFixed(1)}h)';
  }
}

/// 完整的远驱控制器数据
class YuanquDeviceData {
  final ControllerData controller;
  final BmsData? bms;
  final TripData? trip;
  final String? rawHex;
  final BleProtocolType? protocolType;
  final DateTime timestamp;

  YuanquDeviceData({
    required this.controller,
    this.bms,
    this.trip,
    this.rawHex,
    this.protocolType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从解析结果创建完整设备数据
  factory YuanquDeviceData.fromParsedData(Map<String, dynamic> data) {
    return YuanquDeviceData(
      controller: ControllerData.fromParsedData(data),
      bms: BmsData.fromParsedData(data),
      trip: TripData.fromParsedData(data),
      rawHex: data['raw'] as String?,
      protocolType: _parseProtocolType(data['protocol'] as String?),
    );
  }

  /// 合并新数据
  YuanquDeviceData merge(YuanquDeviceData other) {
    return YuanquDeviceData(
      controller: controller.merge(other.controller),
      bms: bms?.merge(other.bms ?? BmsData()) ?? other.bms,
      trip: trip ?? other.trip,
      rawHex: other.rawHex ?? rawHex,
      protocolType: other.protocolType ?? protocolType,
      timestamp: other.timestamp,
    );
  }

  /// 是否有任何数据
  bool get hasAnyData =>
      controller.rpm != null ||
      controller.voltage != null ||
      controller.current != null ||
      (bms?.soc != null);

  static BleProtocolType? _parseProtocolType(String? protocol) {
    if (protocol == null) return null;
    switch (protocol) {
      case 'FlashRead':
        return BleProtocolType.flashRead;
      case 'Legacy':
        return BleProtocolType.legacy;
      default:
        return BleProtocolType.unknown;
    }
  }

  @override
  String toString() {
    return 'YuanquDeviceData(controller: $controller, '
        'bms: $bms, trip: $trip)';
  }
}
