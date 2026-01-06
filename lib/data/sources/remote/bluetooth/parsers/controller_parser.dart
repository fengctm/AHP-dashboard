import 'package:logging/logging.dart';
import '../interfaces/parser.dart';
import '../interfaces/bluetooth_manager.dart';
import '../../../../../core/utils/logger_helper.dart';

/// 控制器数据解析器 - 实现IParser接口
class ControllerParser implements IParser {
  final Logger _logger = LoggerHelper.getAdapterLogger('controller_parser');
  final String deviceId;
  
  Function(DeviceState)? _dataCallback;
  Function(Object)? _errorCallback;

  ControllerParser(this.deviceId);

  @override
  void notice(Function(DeviceState) callback) {
    _dataCallback = callback;
  }

  @override
  void onError(Function(Object) errorCallback) {
    _errorCallback = errorCallback;
  }

  @override
  void parse(List<int> data) {
    _logger.info('收到南京远驱控制器原始数据: 设备ID=$deviceId');
    _logger.info('控制器HEX数据: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    try {
      // TODO: 实现真实的南京远驱控制器数据解析逻辑
      // 当前只是将原始数据记录到日志，返回默认状态
      
      final deviceState = DeviceState(
        deviceId: deviceId,
        deviceType: supportedDeviceType,
        timestamp: DateTime.now(),
        batteryVoltage: 0.0,
        temperature: 0.0,
        rpm: 0.0,
        extra: {
          'rawData': data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '),
          'dataLength': data.length,
        },
      );

      // 调用数据回调
      _dataCallback?.call(deviceState);
    } catch (e) {
      _logger.severe('解析控制器数据失败: $e');
      _errorCallback?.call(e);
    }
  }

  @override
  void dispose() {
    _dataCallback = null;
    _errorCallback = null;
    _logger.fine('控制器解析器已释放资源');
  }

  @override
  String get supportedDeviceType => 'controller';
}