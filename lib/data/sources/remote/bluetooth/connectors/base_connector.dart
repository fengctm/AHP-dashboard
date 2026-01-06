import 'dart:async';
import 'package:logging/logging.dart';
import '../interfaces/connector.dart';
import '../interfaces/parser.dart';
import '../interfaces/bluetooth_manager.dart';
import '../../../../../core/utils/logger_helper.dart';

/// 基础连接器实现
abstract class BaseConnector implements IConnector {
  final IBluetoothManager bluetoothManager;
  final Logger _logger;
  final String _supportedDeviceType;
  
  final StreamController<DeviceState> _deviceStateController = 
      StreamController<DeviceState>.broadcast();
  final StreamController<Object> _errorController = 
      StreamController<Object>.broadcast();
  
  final Map<String, IParser> _deviceParsers = {};
  final Map<String, ConnectionStatus> _connectionStatus = {};
  
  BaseConnector({
    required this.bluetoothManager,
    required String supportedDeviceType,
  }) : 
    _supportedDeviceType = supportedDeviceType,
    _logger = LoggerHelper.getCoreLogger('connector_$supportedDeviceType') {
    
    // 监听蓝牙管理器的连接状态变化
    bluetoothManager.onDeviceConnectionChanged.listen(_handleConnectionChange);
    
    // 监听蓝牙管理器的设备消息
    bluetoothManager.onDeviceMessage.listen(_handleDeviceMessage);
    
    _logger.fine('$_supportedDeviceType 连接器初始化完成');
  }
  
  @override
  Future<void> connect(String deviceId) async {
    _logger.info('尝试连接 $_supportedDeviceType 设备: $deviceId');
    
    // 更新连接状态为连接中
    _updateConnectionStatus(deviceId, ConnectionStatus.connecting);
    
    try {
      // 使用蓝牙管理器连接设备
      final connection = await bluetoothManager.connect(deviceId);
      
      if (connection.connected) {
        _logger.info('$_supportedDeviceType 设备连接成功: $deviceId');
        _updateConnectionStatus(deviceId, ConnectionStatus.connected);
        
        // 为设备创建解析器
        final parser = createParser(deviceId);
        _deviceParsers[deviceId] = parser;
        
        // 注册解析器回调
        parser.notice((deviceState) {
          _deviceStateController.add(deviceState);
        });
        
        parser.onError((error) {
          _logger.severe('解析器错误: $deviceId, 错误: $error');
          _errorController.add(error);
        });
      } else {
        _logger.severe('$_supportedDeviceType 设备连接失败: $deviceId');
        _updateConnectionStatus(deviceId, ConnectionStatus.error);
        _errorController.add(Exception('连接失败'));
      }
    } catch (e) {
      _logger.severe('$_supportedDeviceType 设备连接异常: $deviceId, 错误: $e');
      _updateConnectionStatus(deviceId, ConnectionStatus.error);
      _errorController.add(e);
      rethrow;
    }
  }
  
  @override
  Future<void> disconnect(String deviceId) async {
    _logger.info('尝试断开 $_supportedDeviceType 设备连接: $deviceId');
    
    try {
      // 使用蓝牙管理器断开设备
      await bluetoothManager.disconnect(deviceId);
      
      // 清理解析器资源
      final parser = _deviceParsers.remove(deviceId);
      parser?.dispose();
      
      // 更新连接状态
      _updateConnectionStatus(deviceId, ConnectionStatus.disconnected);
      
      _logger.info('$_supportedDeviceType 设备断开成功: $deviceId');
    } catch (e) {
      _logger.severe('$_supportedDeviceType 设备断开异常: $deviceId, 错误: $e');
      _errorController.add(e);
      rethrow;
    }
  }
  
  @override
  bool matches(String deviceType) {
    return deviceType == _supportedDeviceType;
  }
  
  @override
  Stream<DeviceState> get onDeviceState => _deviceStateController.stream;
  
  @override
  Stream<Object> get onError => _errorController.stream;
  
  @override
  Future<void> sendCommand(String deviceId, List<int> command) async {
    _logger.info('发送命令到 $_supportedDeviceType 设备: $deviceId, 命令: ${command.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    
    try {
      // 使用蓝牙管理器发送命令
      // 注意：这里需要根据实际蓝牙管理器的接口进行调整
      // 目前的IBluetoothManager接口没有直接的sendCommand方法，需要扩展
      // 暂时使用writeData方法，后续可能需要调整
      // await bluetoothManager.writeData(deviceId, command);
      _logger.warning('sendCommand方法尚未完全实现');
    } catch (e) {
      _logger.severe('发送命令失败: $deviceId, 错误: $e');
      _errorController.add(e);
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _logger.fine('释放 $_supportedDeviceType 连接器资源');
    
    // 断开所有连接的设备
    _connectionStatus.forEach((deviceId, status) {
      if (status == ConnectionStatus.connected) {
        disconnect(deviceId).catchError((e) {
          _logger.warning('断开设备连接失败: $deviceId, 错误: $e');
        });
      }
    });
    
    // 清理所有解析器
    _deviceParsers.forEach((deviceId, parser) {
      parser.dispose();
    });
    
    // 关闭流控制器
    _deviceStateController.close();
    _errorController.close();
  }
  
  /// 处理连接状态变化
  void _handleConnectionChange(DeviceConnection connection) {
    final deviceId = connection.deviceId;
    final status = connection.connected 
        ? ConnectionStatus.connected 
        : ConnectionStatus.disconnected;
    
    _updateConnectionStatus(deviceId, status);
    
    if (!connection.connected) {
      // 设备断开连接，清理解析器
      final parser = _deviceParsers.remove(deviceId);
      parser?.dispose();
      
      _logger.info('设备断开连接: $deviceId');
    }
  }
  
  /// 处理设备消息
  void _handleDeviceMessage(DeviceMessage message) {
    final deviceId = message.deviceId;
    
    // 检查是否有对应的解析器
    final parser = _deviceParsers[deviceId];
    if (parser != null) {
      // 使用解析器解析数据
      parser.parse(message.payload);
    }
  }
  
  /// 更新连接状态
  void _updateConnectionStatus(String deviceId, ConnectionStatus status) {
    _connectionStatus[deviceId] = status;
    _logger.fine('设备连接状态更新: $deviceId, 状态: $status');
  }
  
  /// 创建解析器实例，需要由具体连接器实现
  IParser createParser(String deviceId);
}
