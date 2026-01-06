import '../interfaces/connector.dart';
import '../interfaces/bluetooth_manager.dart';
import '../connectors/bms_connector.dart';

/// BMS连接器工厂实现
class BmsConnectorFactory implements IConnectorFactory {
  final IBluetoothManager bluetoothManager;
  
  BmsConnectorFactory(this.bluetoothManager);
  
  @override
  IConnector createConnector() {
    return BmsConnector(bluetoothManager: bluetoothManager);
  }
  
  @override
  String get supportedDeviceType => 'bms';
}