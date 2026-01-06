import 'package:logging/logging.dart';
import '../interfaces/bluetooth_manager.dart';
import '../../../../../core/utils/logger_helper.dart';

/// TPMS数据解析器
class TpmsParser {
  final Logger _logger = LoggerHelper.getAdapterLogger('tpms_parser');

  /// 解析TPMS原始数据
  DeviceState parseTpmsData(String deviceId, List<int> payload) {
    _logger.fine('解析TPMS数据: 设备ID=$deviceId, 原始数据=${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    // 记录HEX数据到日志
    _logger.info('TPMS HEX数据: ${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    // 默认值
    double frontPressure = 0.0;
    double rearPressure = 0.0;
    double frontTemperature = 0.0;
    double rearTemperature = 0.0;
    String sensorStatus = '未知';

    try {
      // 假设TPMS数据格式
      if (payload.length >= 8) {
        // 解析前胎压
        frontPressure = ((payload[1] << 8) | payload[2]) / 100.0;

        // 解析后胎压
        rearPressure = ((payload[3] << 8) | payload[4]) / 100.0;

        // 解析前胎温
        frontTemperature = payload[5].toDouble();

        // 解析后胎温
        rearTemperature = payload[6].toDouble();

        // 解析传感器状态
        final statusCode = payload[7];
        sensorStatus = statusCode == 0 ? '正常' : '异常';

        _logger.fine('TPMS解析成功: 前胎压=$frontPressure bar, 后胎压=$rearPressure bar, 前胎温=$frontTemperature °C, 后胎温=$rearTemperature °C, 状态=$sensorStatus');
      }
    } catch (e) {
      _logger.severe('解析TPMS数据失败: $e');
    }

    return DeviceState(
      deviceId: deviceId,
      deviceType: 'tpms',
      timestamp: DateTime.now(),
      temperature: (frontTemperature + rearTemperature) / 2,
      extra: {
        'frontPressure': '$frontPressure bar',
        'rearPressure': '$rearPressure bar',
        'frontTemperature': '$frontTemperature °C',
        'rearTemperature': '$rearTemperature °C',
        'sensorStatus': sensorStatus,
        'rawData': payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '),
      },
    );
  }

  /// 检查数据是否为TPMS数据
  bool isTpmsData(List<int> payload) {
    // 简单检查：如果数据长度合适，则认为是TPMS数据
    return payload.length >= 8;
  }
  
  /// 发送命令到TPMS设备
  Future<bool> sendCommand(String deviceId, List<int> payload) async {
    _logger.info('发送命令到TPMS设备 $deviceId: ${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    
    try {
      // 这里将在实际实现中调用蓝牙管理器的writeData方法
      // 模拟成功
      return true;
    } catch (e) {
      _logger.severe('发送命令到TPMS设备失败: $e');
      return false;
    }
  }
}