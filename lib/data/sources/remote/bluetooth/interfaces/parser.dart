import 'dart:async';
import 'bluetooth_manager.dart';

/// 解析器接口定义
abstract class IParser {
  /// 注册数据解析完成回调
  void notice(Function(DeviceState) callback);
  
  /// 注册错误处理回调
  void onError(Function(Object) errorCallback);
  
  /// 解析原始数据
  void parse(List<int> data);
  
  /// 释放资源
  void dispose();
  
  /// 获取支持的设备类型
  String get supportedDeviceType;
}

/// 解析器工厂接口
abstract class IParserFactory {
  /// 创建解析器实例
  IParser createParser();
  
  /// 获取支持的设备类型
  String get supportedDeviceType;
}

/// 解析器数据类
class ParserData {
  final List<int> rawData;
  final DateTime timestamp;
  
  const ParserData({
    required this.rawData,
    required this.timestamp,
  });
}

/// 解析器事件
class ParserEvent {
  final ParserEventType type;
  final DeviceState? deviceState;
  final Object? error;
  
  const ParserEvent({
    required this.type,
    this.deviceState,
    this.error,
  });
}

/// 解析器事件类型
enum ParserEventType {
  dataParsed,
  parseError,
  connectionError,
  disconnected,
}
