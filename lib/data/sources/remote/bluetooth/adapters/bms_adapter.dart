import '../interfaces/bluetooth_manager.dart';
import 'base_adapter.dart';
import '../parsers/bms_parser.dart';

class AntProtectAdapter extends BaseDeviceAdapter {
  BmsParser? _parser;

  AntProtectAdapter() : super('bms');

  @override
  bool matches(DeviceAdvertisement ad) {
    // Match by device name or manufacturer data
    final matches = ad.name.toLowerCase().contains('ant') ||
        ad.name.toLowerCase().contains('protect') ||
        ad.name.toLowerCase().contains('bms') ||
        (ad.manufacturerData != null &&
            ad.manufacturerData!.containsKey(0x1234));
    logger.fine('设备匹配结果: 设备名称=${ad.name}, 匹配结果=$matches');
    return matches;
  }

  @override
  DeviceState parse(DeviceMessage msg) {
    logger.fine('解析设备消息: 设备ID=${msg.deviceId}, 负载长度=${msg.payload.length}');
    
    // 创建或获取parser
    _parser ??= BmsParser(msg.deviceId);
    
    // 存储最后解析的状态
    DeviceState? lastState;
    
    // 设置回调以接收解析结果
    _parser!.notice((state) {
      lastState = state;
    });
    
    // 解析数据
    _parser!.parse(msg.payload);
    
    // 返回解析后的状态，如果为空则返回默认状态
    return lastState ?? DeviceState(
      deviceId: msg.deviceId,
      deviceType: 'bms',
      timestamp: DateTime.now(),
      batteryVoltage: 0.0,
      temperature: 0.0,
      rpm: null,
    );
  }

  @override
  Future<void> sendCommand(String deviceId, List<int> payload) async {
    logger.fine('发送命令到Ant Protect BMS $deviceId: ${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    // BMS暂不支持发送命令
  }
}
