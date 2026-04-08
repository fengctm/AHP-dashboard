import 'dart:typed_data';
import 'dart:math' as math;

/// 远驱控制器BLE协议解析器
///
/// 支持两种协议：
/// 1. FlashRead协议: (data[1] & 0xC0) == 0x80
/// 2. Legacy协议: 其他情况
///
/// 字节序说明：
/// - FlashRead协议: 小端序（低字节在低偏移）
/// - Legacy协议: 大端序（高字节在低偏移）
class YuanquBleParser {
  // FlashRead协议地址映射表（55项）
  static const List<int> flashReadAddr = [
    226, 232, 238,   0,   6,  12,  18, 226, 232, 238,  // index  0- 9
     24,  30,  36,  42, 226, 232, 238,  48,  93,  99,  // index 10-19
    105, 226, 232, 238, 124, 130, 136, 142, 226, 232,  // index 20-29
    238, 148, 154, 160, 166, 226, 232, 238, 172, 178,  // index 30-39
    184, 190, 226, 232, 238, 196, 202, 208, 226, 232,  // index 40-49
    238, 214, 220, 244, 250                           // index 50-54
  ];

  // 有解析逻辑的addr集合（FlashRead）
  static const Set<int> _knownAddrs = {
    226, 232, 238, 214, 250, 244, 130, 208, 18, 105, 124, 154
  };

  // 有解析逻辑的CMD集合（Legacy）
  static const Set<int> _knownCmds = {
    0, 1, 2, 3, 4, 8, 10, 13, 15, 18, 32, 33, 34, 35, 36, 37, 38, 39
  };

  /// 将0~65535的无符号值转为-32768~32767的有符号值
  static int _toSignedInt16(int v) {
    return v > 32767 ? v - 65536 : v;
  }

  /// 解析故障代码
  ///
  /// [byteLow] - 故障低字节
  /// [byteHigh] - 故障高字节（只用bit0~6，bit7是停机标志）
  /// [gs1] - Global_state1（用于区分代码11/17）
  /// [gs2] - Global_state2（用于区分代码05/18）
  /// [mss] - motor_stop_state（用于代码16）
  static List<String> parseFaults(
    int byteLow,
    int byteHigh,
    int gs1,
    int gs2,
    int mss,
  ) {
    if (byteLow == 0 && (byteHigh & 0x7F) == 0) {
      return ['系统正常'];
    }

    final faults = <String>[];

    if (byteLow & 0x01 != 0) faults.add('01.电机霍尔故障');
    if (byteLow & 0x02 != 0) faults.add('02.油门踏板故障');
    if (byteLow & 0x04 != 0) faults.add('03.电流保护重启');
    if (byteLow & 0x08 != 0) faults.add('04.相电流突变');
    if (byteLow & 0x10 != 0) {
      faults.add((gs2 & 0x8000) != 0 ? '05.过压故障' : '18.欠压故障');
    }
    if (byteLow & 0x20 != 0) faults.add('06.防盗报警');
    if (byteLow & 0x40 != 0) faults.add('07.电机过温');
    if (byteLow & 0x80 != 0) faults.add('08.控制器过温');
    if (byteHigh & 0x01 != 0) faults.add('09.相电流溢出');
    if (byteHigh & 0x02 != 0) faults.add('10.相线零点故障');
    if (byteHigh & 0x04 != 0) {
      faults.add((gs1 & 0x800) != 0 ? '17.缺相故障' : '11.相线短路故障');
    }
    if (byteHigh & 0x08 != 0) faults.add('12.线电流零点故障');
    if (byteHigh & 0x10 != 0) faults.add('13.MOSFET上桥故障');
    if (byteHigh & 0x20 != 0) faults.add('14.MOSFET下桥故障');
    if (byteHigh & 0x40 != 0) faults.add('15.MOE电流保护');
    if (mss & 0x8000 != 0) faults.add('16.刹车故障');

    return faults;
  }

  /// 解析FlashRead协议数据包
  static Map<String, dynamic> _parseFlashReadPacket(
    Uint8List data,
    int index,
    int addr,
  ) {
    final result = <String, dynamic>{
      'protocol': 'FlashRead',
      'index': index,
      'addr': addr,
    };

    switch (addr) {
      case 226: // 转速 + 挡位 + 调制比 + 故障
        result['gear'] = data[2] & 0x03;
        result['xs_control'] = (data[2] >> 2) & 0x03;
        result['reversing'] = (data[2] >> 4) & 1;
        result['rolling_v'] = (data[2] >> 5) & 1;
        result['comp_phone'] = (data[2] & 0x80) != 0;
        result['pass_ok'] = (data[3] & 0x18) >> 3;
        result['function_en'] = (data[3] & 0x80) != 0;
        result['modulation'] = data[6] / 128.0;
        result['rpm'] = _toSignedInt16(data[9] * 256 + data[8]);
        result['stop'] = (data[5] & 0x80) != 0;
        result['faults'] = parseFaults(data[4], data[5], 0, 0, 0);

        // 方向判断
        final rollingV = result['rolling_v'] as int;
        final reversing = result['reversing'] as int;
        final gear = result['gear'] as int;
        if (rollingV == 0) {
          result['direction'] = 0;
        } else if (reversing == 0) {
          result['direction'] = (gear < 2 || gear == 3) ? 1 : -1;
        } else {
          result['direction'] = (gear >= 2 || gear == 3) ? 1 : -1;
        }
        break;

      case 232: // 电压 + 电流 + 油门深度
        result['voltage'] = _toSignedInt16(data[3] * 256 + data[2]) / 10.0;
        result['current'] = _toSignedInt16(data[7] * 256 + data[6]) / 4.0;
        result['throttle_depth'] = data[13] * 256 + data[12];
        final voltage = result['voltage'] as double;
        final current = result['current'] as double;
        result['power'] = voltage * current;
        break;

      case 238: // A/C 相电流 + 圈数
        result['turns'] = data[5] * 256 + data[4];
        final rawA = data[6] * 65536 + data[7] * 256 + data[8];
        result['phase_a'] = 1.953125 * math.sqrt(rawA.toDouble());
        final rawC = data[9] * 65536 + data[10] * 256 + data[11];
        result['phase_c'] = 1.953125 * math.sqrt(rawC.toDouble());
        break;

      case 214: // 全局状态寄存器 + MOS 温度
        result['mos_temp'] = _toSignedInt16(data[13] * 256 + data[12]);
        result['gs1'] = data[5] * 256 + data[4];
        result['gs2'] = data[7] * 256 + data[6];
        result['gs3'] = data[9] * 256 + data[8];
        result['gs4'] = data[11] * 256 + data[10];
        final gs1 = result['gs1'] as int;
        final gs2 = result['gs2'] as int;
        result['autolearn'] = (gs1 & 0x20) != 0;
        result['weak_field'] = (gs2 & 0x08) != 0;
        result['motor_on'] = (gs1 & 0x2000) != 0;
        break;

      case 250: // 电机运行/停止状态
        result['motor_stop'] = data[7] * 256 + data[6];
        result['motor_run'] = data[11] * 256;
        break;

      case 244: // 电机温度 + SOC
        result['motor_temp'] = _toSignedInt16(data[3] * 256 + data[2]);
        result['soc'] = data[5];
        break;

      case 130: // 油门电压 + 固件版本
        result['throttle_v'] = (data[3] * 256 + data[2]) * 0.01;
        result['fw_ver'] = data[11] >= 32 ? String.fromCharCode(data[11]) : '?';
        break;

      case 208: // 平均能耗 + 车速参数
        result['avg_power_wh'] = data[5] * 4;
        result['avg_speed_kmh'] = data[8];
        result['wheel_ratio'] = data[6];
        result['wheel_radius'] = data[7];
        result['wheel_width'] = data[9];
        result['rate_ratio'] = data[11] * 256 + data[10];
        break;

      case 18: // 极对数
        result['pole_pairs'] = data[6];
        break;

      case 105: // 里程低16位
        result['distance_low'] = data[11] * 256 + data[10];
        break;

      case 124: // 工作时长 + 里程高16位
        result['total_time_s'] =
            (data[7] * 256 + data[6]) * 65536 + data[5] * 256 + data[4];
        result['work_hours'] = result['total_time_s']! / 3600.0;
        result['distance_high'] = data[13] * 256 + data[12];
        break;

      case 154: // 报警记录
        result['alarm_rec'] = data[7] * 256 + data[6];
        break;
    }

    return result;
  }

  /// 解析Legacy协议数据包
  static Map<String, dynamic> _parseLegacyPacket(Uint8List data, int cmd) {
    final result = <String, dynamic>{
      'protocol': 'Legacy',
      'cmd': cmd,
    };

    switch (cmd) {
      case 0: // 转速 + 挡位 + 故障
        result['gear'] = data[4] & 0x03;
        result['xs_control'] = ((data[4] >> 2) ^ 2) & 0x03;
        result['pass_ok'] = (data[5] & 0x0C) >> 2;
        result['comp_phone'] = (data[5] & 0x10) != 0;
        result['eabs'] = (data[5] & 0x03) == 2;
        result['rpm'] = _toSignedInt16(data[6] * 256 + data[7]);
        result['stop'] = (data[9] & 0x80) != 0;
        result['faults'] = parseFaults(data[8], data[9], 0, 0, 0);

        // 方向判断
        final dirBits = (data[4] & 0xF0) >> 4;
        final gear = result['gear'] as int;
        if (dirBits == 0) {
          result['direction'] = 0;
        } else if (dirBits == 1) {
          result['direction'] = (gear < 2 || gear == 3) ? 1 : -1;
        } else {
          result['direction'] = (gear >= 2 || gear == 3) ? 1 : -1;
        }
        break;

      case 1: // 电压 + 电流 + 调制比 + 油门深度
        result['voltage'] = _toSignedInt16(data[2] * 256 + data[3]) / 10.0;
        result['current'] = _toSignedInt16(data[4] * 256 + data[5]) / 4.0;
        result['modulation'] = data[6] / 128.0;
        result['weak_field'] = (data[7] & 0x01) != 0;
        result['throttle_depth'] = data[12] * 256 + data[13];
        final voltage = result['voltage'] as double;
        final current = result['current'] as double;
        result['power'] = voltage * current;
        break;

      case 2: // A/C 相电流
        final rawA = data[2] * 65536 + data[3] * 256 + data[4];
        result['phase_a'] = 1.953125 * math.sqrt(rawA.toDouble());
        final rawC = data[9] * 65536 + data[10] * 256 + data[11];
        result['phase_c'] = 1.953125 * math.sqrt(rawC.toDouble());
        break;

      case 3: // 相电流比例
        result['phase_a_ratio'] = data[8] * 256 + data[9];
        result['phase_c_ratio'] = data[10] * 256 + data[11];
        break;

      case 4: // MOS 温度 + 线电流比
        var mos = data[4];
        if (mos > 200) mos -= 256;
        result['mos_temp'] = mos;
        result['line_curr_ratio'] = data[8] * 256 + data[9];
        break;

      case 8: // 极对数
        result['pole_pairs'] = data[10];
        break;

      case 10: // SOC
        result['soc'] = data[10];
        break;

      case 13: // 油门电压 + 电机温度 + 版本
        result['motor_temp'] = data[2];
        result['throttle_v'] =
            (data[4] * 256 + data[5]) * 3.3 * 1.5 / 4096.0;
        result['fw_ver'] =
            data[10] >= 32 ? String.fromCharCode(data[10]) : '?';
        break;

      case 15: // 全部状态寄存器
        result['motor_stop'] = data[4] * 256 + data[5];
        result['function_st'] = data[2];
        result['motor_run'] = data[3] * 256;
        result['gs1'] = data[6] * 256 + data[7];
        result['gs2'] = data[8] * 256 + data[9];
        result['gs3'] = data[10] * 256 + data[11];
        result['gs4'] = data[12] * 256 + data[13];
        final gs1 = result['gs1'] as int;
        result['autolearn'] = (gs1 & 0x20) != 0;
        result['motor_on'] = (gs1 & 0x2000) != 0;
        break;

      case 18: // BMS 串联数
        result['series_count'] = data[8];
        break;

      case 32:
      case 33:
      case 34:
      case 35:
      case 36:
      case 37:
      case 38:
      case 39: // BMS 电芯数据
        final base = (cmd - 32) * 6;
        for (int i = 0; i < 6; i++) {
          final mv = _toSignedInt16(data[i * 2 + 2] * 256 + data[i * 2 + 3]);
          result['cell_${base + i}_mv'] = mv;
          if (cmd <= 35) {
            // 电压帧，计算容量
            int cap;
            if (mv > 4110) {
              cap = 127;
            } else if (mv < 3600) {
              cap = 0;
            } else {
              cap = (mv - 3600) ~/ 4;
            }
            result['cell_${base + i}_cap'] = cap;
          }
        }
        break;
    }

    return result;
  }

  /// 解析一个BLE数据包
  ///
  /// [data] - 16字节的原始数据
  /// 返回解析后的数据Map，如果数据无效则返回null
  static Map<String, dynamic>? parsePacket(Uint8List data) {
    // 验证数据包长度和起始字节
    if (data.length != 16 || data[0] != 0xAA) {
      return null;
    }

    final result = <String, dynamic>{
      'raw': data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
    };

    // 判定协议类型
    if ((data[1] & 0xC0) == 0x80) {
      // FlashRead 协议
      final index = data[1] & 0x7F;
      if (index >= flashReadAddr.length) {
        return result;
      }
      final addr = flashReadAddr[index];
      result['protocol'] = 'FlashRead';
      result['index'] = index;
      result['addr'] = addr;
      if (_knownAddrs.contains(addr)) {
        result.addAll(_parseFlashReadPacket(data, index, addr));
      }
    } else {
      // Legacy 协议
      final cmd = data[1];
      result['protocol'] = 'Legacy';
      result['cmd'] = cmd;
      if (_knownCmds.contains(cmd)) {
        result.addAll(_parseLegacyPacket(data, cmd));
      }
    }

    return result;
  }

  /// 从hex字符串解析数据包
  ///
  /// [hexStr] - hex格式的字符串（如 "AA0000040101000000000011FFF402B4"）
  static Map<String, dynamic>? parseFromHex(String hexStr) {
    try {
      final bytes = _hexToBytes(hexStr);
      return parsePacket(bytes);
    } catch (e) {
      return null;
    }
  }

  /// 将hex字符串转换为字节数组
  static Uint8List _hexToBytes(String hexStr) {
    final hex = hexStr.replaceAll(' ', '').toLowerCase();
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}

/// 解析后的数据类
class ParsedControllerData {
  final int? rpm;
  final int? gear;
  final double? voltage;
  final double? current;
  final double? power;
  final double? modulation;
  final int? direction; // 1=前进, -1=后退, 0=静止
  final bool? stop;
  final List<String>? faults;
  final double? phaseA;
  final double? phaseC;
  final int? motorTemp;
  final int? mosTemp;
  final int? soc;

  ParsedControllerData({
    this.rpm,
    this.gear,
    this.voltage,
    this.current,
    this.power,
    this.modulation,
    this.direction,
    this.stop,
    this.faults,
    this.phaseA,
    this.phaseC,
    this.motorTemp,
    this.mosTemp,
    this.soc,
  });

  /// 从解析结果Map创建数据对象
  factory ParsedControllerData.fromMap(Map<String, dynamic> map) {
    return ParsedControllerData(
      rpm: map['rpm'] as int?,
      gear: map['gear'] as int?,
      voltage: (map['voltage'] as num?)?.toDouble(),
      current: (map['current'] as num?)?.toDouble(),
      power: (map['power'] as num?)?.toDouble(),
      modulation: (map['modulation'] as num?)?.toDouble(),
      direction: map['direction'] as int?,
      stop: map['stop'] as bool?,
      faults: map['faults'] as List<String>?,
      phaseA: (map['phase_a'] as num?)?.toDouble(),
      phaseC: (map['phase_c'] as num?)?.toDouble(),
      motorTemp: map['motor_temp'] as int?,
      mosTemp: map['mos_temp'] as int?,
      soc: map['soc'] as int?,
    );
  }

  /// 合并新数据
  ParsedControllerData merge(ParsedControllerData other) {
    return ParsedControllerData(
      rpm: other.rpm ?? rpm,
      gear: other.gear ?? gear,
      voltage: other.voltage ?? voltage,
      current: other.current ?? current,
      power: other.power ?? power,
      modulation: other.modulation ?? modulation,
      direction: other.direction ?? direction,
      stop: other.stop ?? stop,
      faults: other.faults ?? faults,
      phaseA: other.phaseA ?? phaseA,
      phaseC: other.phaseC ?? phaseC,
      motorTemp: other.motorTemp ?? motorTemp,
      mosTemp: other.mosTemp ?? mosTemp,
      soc: other.soc ?? soc,
    );
  }
}
