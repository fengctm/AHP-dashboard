import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../../../data/models/device_data_model.dart';
import '../../../../data/sources/remote/bluetooth/bluetooth_source.dart';
import '../../../../../core/utils/logger_helper.dart';
import '../../bluetooth/pages/bluetooth_connection_page.dart';

class DeviceDetailPage extends StatelessWidget {
  final DeviceData deviceData;
  final BluetoothManager bluetoothManager;

  const DeviceDetailPage({
    super.key,
    required this.deviceData,
    required this.bluetoothManager,
  });

  @override
  Widget build(BuildContext context) {
    final Logger logger = LoggerHelper.getModuleLogger('device_detail_screen');
    logger.fine('构建设备详情页面');

    return Scaffold(
      appBar: AppBar(
        title: const Text('设备详情'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备连接状态区域
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '设备连接状态',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDeviceConnectionStatus(
                          context, 'BMS', deviceData.bms.isConnected,
                          deviceData.bms.bluetoothName,
                          () {
                            _openBluetoothConnection(context, 'BMS');
                          },
                        ),
                        _buildDeviceConnectionStatus(
                          context, '控制器', deviceData.controller.isConnected,
                          deviceData.controller.bluetoothName,
                          () {
                            _openBluetoothConnection(context, '控制器');
                          },
                        ),
                        _buildDeviceConnectionStatus(
                          context, 'TPMS', deviceData.tpms.isConnected,
                          deviceData.tpms.bluetoothName,
                          () {
                            _openBluetoothConnection(context, 'TPMS');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BMS 详细数据
            _buildDeviceSection(
              context, 'BMS', Icons.battery_unknown, Colors.blue,
              deviceData.bms.isConnected,
              [
                _buildDetailItem(context, '电池状态', deviceData.bms.batteryStatus),
                _buildDetailItem(context, '电压', '${deviceData.bms.voltage}V'),
                _buildDetailItem(context, '电量', '${deviceData.bms.soc}%'),
                _buildDetailItem(context, '电流', '${deviceData.bms.current}A'),
                _buildDetailItem(context, '功率', '${deviceData.bms.power}W'),
                _buildDetailItem(context, '温度', '${deviceData.bms.temperature}°C'),
                _buildDetailItem(context, 'MOS管温度', '${deviceData.bms.mosTemperature}°C'),
                _buildDetailItem(context, 'T0电池包温度', '${deviceData.bms.t0Temperature}°C'),
              ],
              deviceData.bms.errors,
            ),
            const SizedBox(height: 20),

            // 控制器详细数据
            _buildDeviceSection(
              context, '控制器', Icons.speed, Colors.green,
              deviceData.controller.isConnected,
              [
                _buildDetailItem(context, '系统状态', deviceData.controller.systemStatus),
                _buildDetailItem(context, 'MOS管温度', '${deviceData.controller.temperature}°C'),
                _buildDetailItem(context, '电机温度', '${deviceData.controller.motorTemperature}°C'),
                _buildDetailItem(context, '挡位', deviceData.controller.gear),
                _buildDetailItem(context, '转速', '${deviceData.controller.rpm} RPM'),
                _buildDetailItem(context, '电压', '${deviceData.controller.voltage}V'),
                _buildDetailItem(context, '电流', '${deviceData.controller.current}A'),
                _buildDetailItem(context, '速度', '${deviceData.controller.speed} km/h'),
              ],
              deviceData.controller.errors,
            ),
            const SizedBox(height: 20),

            // TPMS 详细数据
            _buildDeviceSection(
              context, 'TPMS', Icons.air, Colors.orange,
              deviceData.tpms.isConnected,
              [
                _buildDetailItem(context, '胎压', '${deviceData.tpms.pressure} bar'),
                _buildDetailItem(context, '温度', '${deviceData.tpms.temperature}°C'),
                _buildDetailItem(context, '传感器状态', deviceData.tpms.sensorStatus),
              ],
              deviceData.tpms.errors,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 构建设备连接状态项
  Widget _buildDeviceConnectionStatus(
    BuildContext context, 
    String deviceName, 
    bool isConnected, 
    String? bluetoothName,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isConnected ? Icons.check_circle : Icons.error,
                size: 40,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deviceName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isConnected ? '已连接' : '未连接',
            style: TextStyle(
              fontSize: 14,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
          if (isConnected && bluetoothName != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 100,
              child: Text(
                bluetoothName,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (!isConnected) ...[
            const SizedBox(height: 4),
            Text(
              '点击连接',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建设备数据区域
  Widget _buildDeviceSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isConnected,
    List<Widget> items,
    List<String> errors,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备标题
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isConnected ? '已连接' : '未连接',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isConnected) ...[
              // 设备数据项
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: items,
              ),

              // 异常信息
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  '异常信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...errors.map((error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    )),
              ],
            ] else ...[
              // 未连接提示
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    '设备未连接，无法显示详细数据',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建详细数据项
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  /// 打开蓝牙连接窗口
  void _openBluetoothConnection(BuildContext context, String deviceType) {
    final Logger logger = LoggerHelper.getModuleLogger('device_detail_screen');
    logger.info('打开$deviceType蓝牙连接窗口');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BluetoothConnectionPage(
          bluetoothManager: bluetoothManager,
        ),
      ),
    );
  }
}
