import 'dart:async';
import 'package:logging/logging.dart';
import 'interfaces/connector.dart';
import '../../../../../core/utils/logger_helper.dart';

final Logger _logger = LoggerHelper.getCoreLogger('connector_registry');

/// 连接器注册表，管理设备类型与连接器的映射关系
class ConnectorRegistry {
  static final ConnectorRegistry _instance = ConnectorRegistry._internal();
  
  factory ConnectorRegistry() {
    return _instance;
  }
  
  ConnectorRegistry._internal();
  
  /// 设备类型到连接器工厂的映射
  final Map<String, IConnectorFactory> _connectorFactories = {};
  
  /// 已创建的连接器实例
  final Map<String, IConnector> _connectorInstances = {};
  
  /// 注册连接器工厂
  void registerConnectorFactory(IConnectorFactory factory) {
    final deviceType = factory.supportedDeviceType;
    _logger.info('注册连接器工厂，支持设备类型: $deviceType');
    _connectorFactories[deviceType] = factory;
  }
  
  /// 注销连接器工厂
  void unregisterConnectorFactory(String deviceType) {
    _logger.info('注销连接器工厂，设备类型: $deviceType');
    _connectorFactories.remove(deviceType);
    
    // 清理相关的连接器实例
    final instancesToRemove = _connectorInstances.entries
        .where((entry) => entry.key.startsWith('$deviceType:'))
        .map((entry) => entry.key)
        .toList();
    
    for (final instanceId in instancesToRemove) {
      _connectorInstances[instanceId]?.dispose();
      _connectorInstances.remove(instanceId);
    }
  }
  
  /// 根据设备类型创建连接器
  IConnector createConnector(String deviceType) {
    final factory = _connectorFactories[deviceType];
    if (factory == null) {
      throw Exception('不支持的设备类型: $deviceType');
    }
    
    _logger.fine('创建连接器实例，设备类型: $deviceType');
    return factory.createConnector();
  }
  
  /// 根据设备ID获取或创建连接器实例
  IConnector getOrCreateConnector(String deviceId, String deviceType) {
    final instanceId = '$deviceType:$deviceId';
    
    if (_connectorInstances.containsKey(instanceId)) {
      _logger.fine('使用现有连接器实例，ID: $instanceId');
      return _connectorInstances[instanceId]!;
    }
    
    final connector = createConnector(deviceType);
    _connectorInstances[instanceId] = connector;
    _logger.fine('创建新的连接器实例，ID: $instanceId');
    
    return connector;
  }
  
  /// 获取支持的设备类型列表
  List<String> getSupportedDeviceTypes() {
    return _connectorFactories.keys.toList();
  }
  
  /// 释放所有连接器资源
  void dispose() {
    _logger.info('释放所有连接器资源');
    
    for (final connector in _connectorInstances.values) {
      connector.dispose();
    }
    
    _connectorInstances.clear();
    _connectorFactories.clear();
  }
  
  /// 释放特定设备的连接器资源
  void disposeConnector(String deviceId, String deviceType) {
    final instanceId = '$deviceType:$deviceId';
    _logger.fine('释放连接器资源，ID: $instanceId');
    
    _connectorInstances[instanceId]?.dispose();
    _connectorInstances.remove(instanceId);
  }
}

/// 连接器注册表单例
final connectorRegistry = ConnectorRegistry();
