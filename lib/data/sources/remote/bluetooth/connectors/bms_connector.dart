import '../parsers/bms_parser.dart';
import '../interfaces/bluetooth_manager.dart';
import '../interfaces/parser.dart';
import 'base_connector.dart';

/// BMS设备连接器
class BmsConnector extends BaseConnector {
  BmsConnector({
    required super.bluetoothManager,
  }) : super(supportedDeviceType: 'bms');

  @override
  IParser createParser(String deviceId) {
    // 创建BMS解析器实例
    return BmsParser(deviceId);
  }
}
