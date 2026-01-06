import 'dart:async';
import 'bluetooth_manager.dart';

/// 连接器接口定义
abstract class IConnector {
  /// 连接设备
  Future<void> connect(String deviceId);
  
  /// 断开设备连接
  Future<void> disconnect(String deviceId);
  
  /// 检查是否匹配指定设备类型
  bool matches(String deviceType);
  
  /// 设备状态流
  Stream<DeviceState> get onDeviceState;
  
  /// 错误流
  Stream<Object> get onError;
  
  /// 发送命令到设备
  Future<void> sendCommand(String deviceId, List<int> command);
  
  /// 释放资源
  void dispose();
}

/// 连接器工厂接口
abstract class IConnectorFactory {
  /// 创建连接器实例
  IConnector createConnector();
  
  /// 获取支持的设备类型
  String get supportedDeviceType;
}

/// 设备连接状态
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// 连接器事件
class ConnectorEvent {
  final ConnectionStatus status;
  final String deviceId;
  final Object? error;
  
  const ConnectorEvent({
    required this.status,
    required this.deviceId,
    this.error,
  });
}
