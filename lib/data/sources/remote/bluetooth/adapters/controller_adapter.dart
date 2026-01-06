import '../interfaces/bluetooth_manager.dart';
import 'base_adapter.dart';
import '../parsers/controller_parser.dart';

class NanJingYuanQuAdapter extends BaseDeviceAdapter {
  ControllerParser? _parser;

  NanJingYuanQuAdapter() : super('controller');

  @override
  bool matches(DeviceAdvertisement ad) {
    // Match by device name or service UUID
    final matches = ad.name.toLowerCase().contains('yuanqu') ||
        ad.name.toLowerCase().contains('njyq') ||
        ad.name.toLowerCase().contains('yuqufoc') ||
        ad.name.toLowerCase().contains('yuanqufoc') ||
        (ad.serviceUuids != null &&
            ad.serviceUuids!.contains('0000ffe0-0000-1000-8000-00805f9b34fb'));
    logger.fine('设备匹配结果: 设备名称=${ad.name}, 匹配结果=$matches');
    return matches;
  }

  @override
  DeviceState parse(DeviceMessage msg) {
    logger.fine('解析设备消息: 设备ID=${msg.deviceId}, 负载长度=${msg.payload.length}');
    
    // 创建或获取parser
    _parser ??= ControllerParser(msg.deviceId);
    
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
      deviceType: 'controller',
      timestamp: DateTime.now(),
      batteryVoltage: 0.0,
      temperature: 0.0,
      rpm: 0.0,
    );
  }

  @override
  Future<void> sendCommand(String deviceId, List<int> payload) async {
    logger.fine('发送命令到南京园区控制器 $deviceId: ${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    // 控制器暂不支持发送命令
  }
}
