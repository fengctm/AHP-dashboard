import 'package:logging/logging.dart';
import '../interfaces/bluetooth_manager.dart';
import '../../../../../core/utils/logger_helper.dart';

abstract class BaseDeviceAdapter implements IDeviceAdapter {
  final String deviceType;

  // 使用protected可见性，让子类可以访问
  final Logger logger;

  BaseDeviceAdapter(this.deviceType)
      : logger = LoggerHelper.getAdapterLogger(deviceType);

  @override
  Future<void> sendCommand(String deviceId, List<int> payload) async {
    logger.fine('发送命令到设备 $deviceId: $payload');
    // Default implementation, can be overridden by subclasses
  }
}
