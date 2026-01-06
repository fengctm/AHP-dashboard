import '../interfaces/bluetooth_manager.dart';
import 'base_adapter.dart';
import '../parsers/tpms_parser.dart';

class TPMSAdapter extends BaseDeviceAdapter {
  final TpmsParser _parser = TpmsParser();

  TPMSAdapter() : super('tpms');

  @override
  bool matches(DeviceAdvertisement ad) {
    // Match by device name or manufacturer data
    final matches = ad.name.toLowerCase().contains('tpms') ||
        ad.name.toLowerCase().contains('tire') ||
        ad.name.toLowerCase().contains('pressure') ||
        (ad.manufacturerData != null &&
            ad.manufacturerData!.containsKey(0x5678));
    logger.fine('设备匹配结果: 设备名称=${ad.name}, 匹配结果=$matches');
    return matches;
  }

  @override
  DeviceState parse(DeviceMessage msg) {
    logger.fine('解析TPMS设备消息: 设备ID=${msg.deviceId}, 负载长度=${msg.payload.length}');
    
    // 使用TPMS解析器解析数据
    return _parser.parseTpmsData(msg.deviceId, msg.payload);
  }

  @override
  Future<void> sendCommand(String deviceId, List<int> payload) async {
    logger.fine('发送命令到TPMS设备 $deviceId: ${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    // 使用TPMS解析器发送命令
    await _parser.sendCommand(deviceId, payload);
  }
}
