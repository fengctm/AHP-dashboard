import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../../../../data/sources/remote/bluetooth/interfaces/bluetooth_manager.dart';
import '../../../../data/models/bluetooth_device_model.dart';
import '../../../../data/sources/remote/bluetooth/bluetooth_source.dart';
import '../../../../data/sources/local/database_source.dart';
import '../../../../data/sources/local/device_cache_source.dart';
import '../../../../data/sources/remote/bluetooth/connector_registry.dart';
import '../../../../data/sources/remote/bluetooth/factories/bms_connector_factory.dart';
import '../../../../data/sources/remote/bluetooth/factories/controller_connector_factory.dart';
import '../../../../../core/utils/logger_helper.dart';
import '../../../../data/sources/local/interfaces/device_cache_manager.dart';

class BluetoothConnectionPage extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  
  const BluetoothConnectionPage({
    Key? key,
    required this.bluetoothManager,
  }) : super(key: key);

  @override
  State<BluetoothConnectionPage> createState() => _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  String _bluetoothState = 'unknown';
  final List<DeviceAdvertisement> _discoveredDevices = [];
  bool _isScanning = false;

  // 设备类型选择
  String _selectedDeviceType = 'controller'; // 默认选择控制器
  final List<String> _deviceTypes = ['controller', 'bms']; // 支持的设备类型
  final Map<String, String> _deviceTypeNames = {
    'controller': '控制器',
    'bms': 'BMS电池管理系统'
  };

  final Logger _logger = LoggerHelper.getModuleLogger('bluetooth_connection');
  final DatabaseService _dbService = DatabaseService();
  final IDeviceMemoryManager _deviceMemoryManager = DeviceMemoryManager();

  @override
  void initState() {
    super.initState();
    _initBluetooth();
    _registerConnectorFactories();
    _loadSavedDevices();
  }

  @override
  void dispose() {
    super.dispose();
    widget.bluetoothManager.stopScan();
    
    // 取消流订阅
    _adapterStateSubscription?.cancel();
    _deviceDiscoveredSubscription?.cancel();
  }

  /// 已保存的设备列表
  List<AppBluetoothDevice> _savedDevices = [];
  
  /// 流订阅
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<DeviceAdvertisement>? _deviceDiscoveredSubscription;

  /// 初始化蓝牙状态
  Future<void> _initBluetooth() async {
    _logger.fine('初始化蓝牙状态');
    _bluetoothState = await widget.bluetoothManager.getBluetoothState();
    
    // 监听蓝牙状态变化
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() {
          _bluetoothState = state == BluetoothAdapterState.on ? 'on' : 'off';
          _logger.info('蓝牙状态变化: $_bluetoothState');
        });
      }
    });
    
    // 监听设备发现
    _deviceDiscoveredSubscription = widget.bluetoothManager.onDeviceDiscovered.listen((device) {
      if (mounted) {
        setState(() {
          // 避免重复添加
          if (!_discoveredDevices.any((d) => d.deviceId == device.deviceId)) {
            _discoveredDevices.add(device);
          }
        });
      }
    });
    
    // 开始扫描
    _startScan();
  }

  /// 注册连接器工厂
  void _registerConnectorFactories() {
    _logger.fine('注册连接器工厂');
    
    // 注册控制器连接器工厂
    connectorRegistry.registerConnectorFactory(
      ControllerConnectorFactory(widget.bluetoothManager)
    );
    
    // 注册BMS连接器工厂
    connectorRegistry.registerConnectorFactory(
      BmsConnectorFactory(widget.bluetoothManager)
    );
    
    _logger.info('已注册支持的设备类型: ${connectorRegistry.getSupportedDeviceTypes()}');
  }

  /// 加载已保存的设备
  Future<void> _loadSavedDevices() async {
    _logger.fine('加载已保存的设备');
    _savedDevices = await _dbService.getAllBluetoothDevices();
    _logger.finer('共加载到 ${_savedDevices.length} 个已保存的设备');
  }

  /// 开始扫描设备
  Future<void> _startScan() async {
    if (_isScanning) {
      return;
    }
    
    _logger.info('开始扫描设备');
    setState(() {
      _isScanning = true;
      _discoveredDevices.clear();
    });
    
    try {
      await widget.bluetoothManager.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      _logger.severe('扫描设备失败: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// 获取要显示的设备列表，已保存的设备放在前面
  List<DeviceAdvertisement> _getDisplayDevices() {
    // 已保存的设备列表
    final savedDeviceAds = _savedDevices
        .where((savedDevice) => _discoveredDevices.any((d) => d.deviceId == savedDevice.deviceId))
        .map((savedDevice) {
          final deviceAd = _discoveredDevices.firstWhere((d) => d.deviceId == savedDevice.deviceId);
          return deviceAd;
        })
        .toList();
    
    // 未保存的设备列表
    final unsavedDeviceAds = _discoveredDevices
        .where((device) => !_savedDevices.any((d) => d.deviceId == device.deviceId))
        .toList();
    
    // 合并列表，已保存的设备放在前面
    return [...savedDeviceAds, ...unsavedDeviceAds];
  }

  /// 连接设备
  Future<void> _connectDevice(String deviceId) async {
    _logger.info('连接设备: $deviceId, 设备类型: $_selectedDeviceType');
    try {
      // 获取设备信息
      final device = _discoveredDevices.firstWhere((d) => d.deviceId == deviceId);
      
      // 1. 获取或创建连接器
      connectorRegistry.getOrCreateConnector(deviceId, _selectedDeviceType);
      
      // 2. 连接设备
      await widget.bluetoothManager.connect(deviceId);
      
      // 3. 保存设备到内存管理器
      final connectedDevice = ConnectedDevice(
        id: deviceId,
        name: device.name,
        type: _selectedDeviceType,
        lastConnectedAt: DateTime.now(),
        autoConnect: true,
        priority: 50,
      );
      await _deviceMemoryManager.saveConnectedDevice(connectedDevice);
      
      // 4. 保存设备到数据库（为了兼容旧代码）
      final bluetoothDevice = AppBluetoothDevice(
        deviceId: deviceId,
        name: device.name,
        deviceType: _selectedDeviceType,
        lastConnectedAt: DateTime.now(),
        autoConnect: true,
        priority: 50,
        serviceUuids: device.serviceUuids,
        manufacturerData: device.manufacturerData,
      );
      await _dbService.saveBluetoothDevice(bluetoothDevice);
      
      _logger.info('设备连接成功: $deviceId');
      Navigator.pop(context);
    } catch (e) {
      _logger.severe('连接设备失败: $e');
      // 显示连接失败提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 取消记住设备
  Future<void> _forgetDevice(String deviceId, String deviceName) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消记住设备'),
        content: Text('确定要取消记住设备 "$deviceName" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _logger.info('取消记住设备: $deviceId');
      
      // 从数据库删除
      await _dbService.deleteBluetoothDevice(deviceId);
      
      // 从内存管理器删除
      await _deviceMemoryManager.forgetDevice(deviceId);
      
      // 更新UI
      setState(() {
        _savedDevices.removeWhere((d) => d.deviceId == deviceId);
      });
      
      _logger.info('已取消记住设备: $deviceName');
      
      // 显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已取消记住设备 "$deviceName"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _logger.severe('取消记住设备失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙设备连接'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备类型选择
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('设备类型选择', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: _deviceTypes.map((type) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(_deviceTypeNames[type]!),
                            value: type,
                            groupValue: _selectedDeviceType,
                            onChanged: (value) {
                              setState(() {
                                _selectedDeviceType = value!;
                                _logger.info('选择设备类型: $value');
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bluetooth status indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('蓝牙状态:'),
                Text(
                  _bluetoothState == 'on'
                      ? '已开启'
                      : '未开启',
                  style: TextStyle(
                    color: _bluetoothState == 'on'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Scan button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('附近的${_deviceTypeNames[_selectedDeviceType]}设备'),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: Icon(_isScanning ? Icons.pause : Icons.search),
                  label: Text(_isScanning ? '扫描中...' : '扫描'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bluetooth devices list
            Expanded(
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : (_discoveredDevices.isEmpty && _savedDevices.isEmpty)
                      ? const Center(child: Text('未发现设备'))
                      : ListView.builder(
                          itemCount: _getDisplayDevices().length,
                          itemBuilder: (context, index) {
                            final displayDevices = _getDisplayDevices();
                            final device = displayDevices[index];
                            final isSaved = _savedDevices.any((d) => d.deviceId == device.deviceId);
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: isSaved 
                                    ? GestureDetector(
                                        onTap: () => _forgetDevice(device.deviceId, device.name),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 32,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.star_border,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                title: Text(
                                  device.name,
                                  style: TextStyle(
                                    fontWeight: isSaved ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'UUID: ${device.deviceId}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        Text('信号强度: ${device.rssi} dBm'),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.signal_cellular_alt,
                                          size: 16,
                                          color: device.rssi > -50
                                              ? Colors.green
                                              : device.rssi > -70
                                                  ? Colors.yellow
                                                  : Colors.red,
                                        ),
                                      ],
                                    ),
                                    if (isSaved)
                                      const Text(
                                        '已记住（点击星星可取消）',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    await _connectDevice(device.deviceId);
                                  },
                                  child: const Text('连接'),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
