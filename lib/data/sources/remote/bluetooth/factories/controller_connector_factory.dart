import '../interfaces/connector.dart';
import '../interfaces/bluetooth_manager.dart';
import '../connectors/controller_connector.dart';

/// 控制器连接器工厂实现
class ControllerConnectorFactory implements IConnectorFactory {
  final IBluetoothManager bluetoothManager;
  
  ControllerConnectorFactory(this.bluetoothManager);
  
  @override
  IConnector createConnector() {
    return ControllerConnector(bluetoothManager: bluetoothManager);
  }
  
  @override
  String get supportedDeviceType => 'controller';
}