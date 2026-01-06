import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../../../data/models/device_data_model.dart';
import '../../../../../core/utils/logger_helper.dart';

class DeviceStatusCard extends StatelessWidget {
  final DeviceData deviceData;
  final VoidCallback onTap;

  const DeviceStatusCard({
    super.key,
    required this.deviceData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Logger logger = LoggerHelper.getWidgetLogger('device_status_card');
    logger.fine('构建设备状态大卡片');

    // 根据设备连接状态动态生成参数项列表
    final List<Widget> parameterItems = [];

    // BMS 关键参数（仅当BMS连接时显示）
    if (deviceData.bms.isConnected) {
      parameterItems.addAll([
        _buildParameterItem(
          context, 'BMS电量', '${deviceData.bms.soc}%', Icons.battery_full,
          Colors.blue,
        ),
        _buildParameterItem(
          context, 'BMS电压', '${deviceData.bms.voltage}V', Icons.battery_unknown,
          Colors.blue,
        ),
        _buildParameterItem(
          context, 'BMS功率', '${deviceData.bms.power}W', Icons.power,
          Colors.blue,
        ),
        _buildParameterItem(
          context, 'BMS状态', deviceData.bms.status, Icons.check_circle,
          deviceData.bms.status == '正常' ? Colors.green : Colors.red,
        ),
        _buildParameterItem(
          context, 'BMS MOS温度', '${deviceData.bms.mosTemperature}°C', Icons.thermostat,
          Colors.orange,
        ),
        _buildParameterItem(
          context, 'BMS T0温度', '${deviceData.bms.t0Temperature}°C', Icons.thermostat,
          Colors.orange,
        ),
      ]);
    }

    // 控制器关键参数（仅当控制器连接时显示）
    if (deviceData.controller.isConnected) {
      parameterItems.addAll([
        _buildParameterItem(
          context, '控制器MOS温度', '${deviceData.controller.temperature}°C', Icons.thermostat,
          Colors.orange,
        ),
        _buildParameterItem(
          context, '控制器状态', deviceData.controller.systemStatus, Icons.system_security_update_good,
          deviceData.controller.systemStatus == '正常运行' ? Colors.green : Colors.red,
        ),
        _buildParameterItem(
          context, '控制器电机温度', '${deviceData.controller.motorTemperature}°C', Icons.thermostat,
          Colors.orange,
        ),
      ]);
    }

    // TPMS 关键参数（仅当TPMS连接时显示）
    if (deviceData.tpms.isConnected) {
      parameterItems.addAll([
        _buildParameterItem(
          context, '胎压', '${deviceData.tpms.pressure} bar', Icons.air,
          Colors.orange,
        ),
        _buildParameterItem(
          context, '胎温', '${deviceData.tpms.temperature}°C', Icons.thermostat,
          Colors.orange,
        ),
        _buildParameterItem(
          context, 'TPMS状态', deviceData.tpms.sensorStatus, Icons.check_circle,
          deviceData.tpms.sensorStatus == '正常' ? Colors.green : Colors.red,
        ),
      ]);
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // 添加弹性滚动效果
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 卡片标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '设备状态',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).hintColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 连接状态行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildConnectionStatus(
                      context, 'BMS', deviceData.bms.isConnected,
                      deviceData.bms.bluetoothName,
                    ),
                    _buildConnectionStatus(
                      context, '控制器', deviceData.controller.isConnected,
                      deviceData.controller.bluetoothName,
                    ),
                    _buildConnectionStatus(
                      context, 'TPMS', deviceData.tpms.isConnected,
                      deviceData.tpms.bluetoothName,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 关键参数网格布局，一行显示三个
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // 禁用网格自身滚动，使用卡片的滚动
                  crossAxisCount: 3, // 一行显示三个
                  crossAxisSpacing: 16, // 水平间距
                  mainAxisSpacing: 16, // 垂直间距
                  childAspectRatio: 1.2, // 调整宽高比
                  children: parameterItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建连接状态项
  Widget _buildConnectionStatus(BuildContext context, String deviceName, bool isConnected, String? bluetoothName) {
    return Column(
      children: [
        Text(
          deviceName,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConnected ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              isConnected ? '已连接' : '未连接',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        if (isConnected && bluetoothName != null) ...[
          const SizedBox(height: 4),
          Text(
            bluetoothName,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建参数项
  Widget _buildParameterItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
