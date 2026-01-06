import '../parsers/controller_parser.dart';
import '../interfaces/bluetooth_manager.dart';
import '../interfaces/parser.dart';
import 'base_connector.dart';

/// 控制器设备连接器
class ControllerConnector extends BaseConnector {
  ControllerConnector({
    required super.bluetoothManager,
  }) : super(supportedDeviceType: 'controller');

  @override
  IParser createParser(String deviceId) {
    // 创建控制器解析器实例
    return ControllerParser(deviceId);
  }
}
