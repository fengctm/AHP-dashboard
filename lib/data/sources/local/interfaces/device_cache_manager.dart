import 'dart:async';

/// 连接设备信息类
class ConnectedDevice {
  final String id;
  final String type;
  final String name;
  final DateTime lastConnectedAt;
  final bool autoConnect;
  final int priority;
  
  const ConnectedDevice({
    required this.id,
    required this.type,
    required this.name,
    required this.lastConnectedAt,
    required this.autoConnect,
    this.priority = 50,
  });
  
  factory ConnectedDevice.fromMap(Map<String, dynamic> map) {
    return ConnectedDevice(
      id: map['id'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      lastConnectedAt: DateTime.parse(map['lastConnectedAt'] as String),
      autoConnect: map['autoConnect'] as bool,
      priority: map['priority'] as int? ?? 50,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'lastConnectedAt': lastConnectedAt.toIso8601String(),
      'autoConnect': autoConnect,
      'priority': priority,
    };
  }
  
  ConnectedDevice copyWith({
    String? id,
    String? type,
    String? name,
    DateTime? lastConnectedAt,
    bool? autoConnect,
    int? priority,
  }) {
    return ConnectedDevice(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      autoConnect: autoConnect ?? this.autoConnect,
      priority: priority ?? this.priority,
    );
  }
}

/// 设备记忆管理器接口
abstract class IDeviceMemoryManager {
  /// 保存连接的设备
  Future<void> saveConnectedDevice(ConnectedDevice device);
  
  /// 获取所有保存的设备
  Future<List<ConnectedDevice>> getSavedDevices();
  
  /// 获取保存的设备
  Future<ConnectedDevice?> getSavedDevice(String deviceId);
  
  /// 删除保存的设备
  Future<void> forgetDevice(String deviceId);
  
  /// 更新设备自动连接状态
  Future<void> updateAutoConnect(String deviceId, bool autoConnect);
  
  /// 更新设备优先级
  Future<void> updatePriority(String deviceId, int priority);
  
  /// 清除所有保存的设备
  Future<void> clearAllDevices();
  
  /// 设备列表变化流
  Stream<List<ConnectedDevice>> get onDevicesChanged;
}
