import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../../../core/utils/logger_helper.dart';
import '../../../../data/sources/remote/bluetooth/bluetooth_source.dart';
import '../../bluetooth/pages/bluetooth_connection_page.dart';

enum DeviceType {
  bms,
  controller,
  tpms,
}

/// 设备数据项配置
class DeviceDataItem {
  final String label;
  final String key;
  final IconData icon;
  final String defaultValue;

  const DeviceDataItem({
    required this.label,
    required this.key,
    required this.icon,
    this.defaultValue = '未知',
  });
}

/// 设备配置
class DeviceConfig {
  final List<DeviceDataItem> simpleItems;
  final List<DeviceDataItem> detailedItems;

  const DeviceConfig({
    required this.simpleItems,
    required this.detailedItems,
  });
}

class ExpandableDeviceCard extends StatefulWidget {
  final String title;
  final DeviceType deviceType;
  final bool isConnected; // 连接状态
  final String? bluetoothName; // 蓝牙设备名称
  final String status;
  final String value1;
  final String value2;
  final String? value3;
  final Map<String, dynamic> detailedData;
  final BluetoothManager bluetoothManager;

  const ExpandableDeviceCard({
    super.key,
    required this.title,
    required this.deviceType,
    required this.isConnected,
    this.bluetoothName,
    required this.status,
    required this.value1,
    required this.value2,
    this.value3,
    required this.detailedData,
    required this.bluetoothManager,
  });

  @override
  State<ExpandableDeviceCard> createState() => _ExpandableDeviceCardState();
}

class _ExpandableDeviceCardState extends State<ExpandableDeviceCard> {
  bool _isExpanded = false;

  final Logger _logger = LoggerHelper.getWidgetLogger('expandable_device_card');

  // 设备配置映射
  final Map<DeviceType, DeviceConfig> _deviceConfigs = {
    DeviceType.bms: DeviceConfig(
      simpleItems: [
        DeviceDataItem(
            label: '电压', key: 'voltage', icon: Icons.battery_unknown),
        DeviceDataItem(label: '容量', key: 'soc', icon: Icons.percent),
      ],
      detailedItems: [
        DeviceDataItem(
            label: '电池状态', key: 'batteryStatus', icon: Icons.battery_full),
        DeviceDataItem(
            label: '当前电压', key: 'voltage', icon: Icons.battery_unknown),
        DeviceDataItem(label: '剩余容量', key: 'soc', icon: Icons.percent),
        DeviceDataItem(
            label: '电流', key: 'current', icon: Icons.arrow_right_alt),
        DeviceDataItem(label: '温度', key: 'temperature', icon: Icons.thermostat),
      ],
    ),
    DeviceType.controller: DeviceConfig(
      simpleItems: [
        DeviceDataItem(label: '温度', key: 'temperature', icon: Icons.thermostat),
        DeviceDataItem(label: '挡位', key: 'gear', icon: Icons.switch_left),
      ],
      detailedItems: [
        DeviceDataItem(
            label: '系统状态',
            key: 'systemStatus',
            icon: Icons.system_security_update_good),
        DeviceDataItem(
            label: 'MOS温度', key: 'temperature', icon: Icons.thermostat),
        DeviceDataItem(label: '挡位', key: 'gear', icon: Icons.switch_left),
        DeviceDataItem(label: '转速', key: 'rpm', icon: Icons.speed),
        DeviceDataItem(
            label: '电压', key: 'voltage', icon: Icons.battery_unknown),
        DeviceDataItem(
            label: '电流', key: 'current', icon: Icons.arrow_right_alt),
        DeviceDataItem(label: '速度', key: 'speed', icon: Icons.speed),
      ],
    ),
    DeviceType.tpms: DeviceConfig(
      simpleItems: [
        DeviceDataItem(label: '前胎压', key: 'pressure', icon: Icons.air),
        DeviceDataItem(label: '后胎压', key: 'pressure', icon: Icons.air),
      ],
      detailedItems: [
        DeviceDataItem(label: '前胎压', key: 'frontPressure', icon: Icons.air),
        DeviceDataItem(label: '后胎压', key: 'rearPressure', icon: Icons.air),
        DeviceDataItem(
            label: '前胎温', key: 'frontTemperature', icon: Icons.thermostat),
        DeviceDataItem(
            label: '后胎温', key: 'rearTemperature', icon: Icons.thermostat),
        DeviceDataItem(
            label: '传感器状态', key: 'sensorStatus', icon: Icons.sensors),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Simple card view (always visible)
          InkWell(
            onTap: () {
              _logger.fine('${widget.title}卡片${_isExpanded ? '折叠' : '展开'}');
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title, bluetooth name and connection status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and Bluetooth Name
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.isConnected &&
                              widget.bluetoothName != null) // 仅连接时显示蓝牙名称
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                widget.bluetoothName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Connection Status Bubble - now clickable
                      GestureDetector(
                        onTap: () {
                          _logger.info('点击${widget.title}设备连接状态，打开蓝牙连接对话框');
                          _showBluetoothConnectionDialog();
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isConnected
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isConnected
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.isConnected ? '已连接' : '未连接',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.isConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Device-specific values (仅连接时显示)
                  if (widget.isConnected) ...[
                    _buildSimpleCardContent(),

                    // Expand/collapse indicator
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ] else ...[
                    // 未连接时显示提示
                    const SizedBox(height: 12),
                    Text(
                      '未连接到设备',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Complex card view (expands when tapped)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0,
            constraints:
                _isExpanded ? null : const BoxConstraints(maxHeight: 0),
            child: _isExpanded ? _buildComplexCardContent() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCardContent() {
    final config = _deviceConfigs[widget.deviceType]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status with icon
        Row(
          children: [
            Icon(
              widget.status == '正常' ? Icons.check_circle : Icons.error,
              color: widget.status == '正常' ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              widget.status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.status == '正常' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),

        // Device-specific values in horizontal layout
        Row(
          children: List.generate(config.simpleItems.length, (index) {
            final item = config.simpleItems[index];
            // 从detailedData中动态获取值，使用配置的key
            final value =
                widget.detailedData[item.key]?.toString() ?? item.defaultValue;

            return [
              _buildHorizontalValueItem(item.label, value, item.icon),
              if (index < config.simpleItems.length - 1)
                const SizedBox(width: 16),
            ];
          }).expand((element) => element).toList(),
        ),
      ],
    );
  }

  Widget _buildComplexCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '详细信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 12),

          // Device-specific detailed content in grid layout
          _buildDetailedContent(),
        ],
      ),
    );
  }

  Widget _buildDetailedContent() {
    final config = _deviceConfigs[widget.deviceType]!;
    final items = <Widget>[];

    // 添加详细数据项
    for (final item in config.detailedItems) {
      String value =
          widget.detailedData[item.key]?.toString() ?? item.defaultValue;

      // 特殊处理TPMS的胎压和温度数据
      if (widget.deviceType == DeviceType.tpms) {
        if (item.key == 'frontPressure' || item.key == 'rearPressure') {
          value = widget.detailedData[item.key]?.toString() ??
              widget.detailedData['pressure']?.toString() ??
              '0 bar';
        } else if (item.key == 'frontTemperature' ||
            item.key == 'rearTemperature') {
          value = widget.detailedData[item.key]?.toString() ??
              widget.detailedData['temperature']?.toString() ??
              '0°C';
        }
      }

      items.add(_buildGridItem(item.label, value, item.icon));
    }

    // 添加异常状态项（如果有错误）
    if (widget.detailedData['errors'] != null &&
        widget.detailedData['errors'].isNotEmpty) {
      items.add(_buildGridItem('异常状态', '存在', Icons.error));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: items,
    );
  }

  Widget _buildGridItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalValueItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showBluetoothConnectionDialog() {
    _logger.fine('显示${widget.title}蓝牙连接页面');

    // 跳转到新的蓝牙连接页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BluetoothConnectionPage(
          bluetoothManager: widget.bluetoothManager,
        ),
      ),
    );
  }
}
