import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../../../core/utils/logger_helper.dart';
import '../../../../data/sources/local/permission_source.dart';
import '../../dashboard/pages/dashboard_page.dart';

class PermissionPage extends ConsumerStatefulWidget {
  const PermissionPage({super.key});

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage> {
  late PermissionManager _permissionManager;

  final Logger _logger = LoggerHelper.getModuleLogger('permission');

  bool _isRequesting = false;
  bool _locationPermissionGranted = false;
  bool _bluetoothPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _permissionManager = PermissionManager();

    // Start permission request immediately
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    _logger.info('开始请求权限');
    setState(() {
      _isRequesting = true;
    });

    try {
      // Request location permission
      _logger.fine('请求位置权限');
      final locationResult = await _permissionManager.ensureLocation(false);
      _locationPermissionGranted = locationResult.success;
      _logger.fine('位置权限请求结果: $_locationPermissionGranted');

      // Request bluetooth permission
      _logger.fine('请求蓝牙权限');
      final bluetoothResult = await _permissionManager.ensureBluetoothOn();
      _bluetoothPermissionGranted = bluetoothResult;
      _logger.fine('蓝牙权限请求结果: $_bluetoothPermissionGranted');

      // If all permissions are granted, navigate to dashboard
      if (_locationPermissionGranted && _bluetoothPermissionGranted) {
        _logger.info('所有权限已授予，导航到仪表盘');
        _navigateToDashboard();
      } else {
        _logger.warning(
            '部分权限未授予: 位置=$_locationPermissionGranted, 蓝牙=$_bluetoothPermissionGranted');
      }
    } catch (e) {
      _logger.severe('请求权限时出错: $e');
    } finally {
      setState(() {
        _isRequesting = false;
      });
      _logger.fine('权限请求流程完成');
    }
  }

  void _navigateToDashboard() {
    _logger.info('导航到仪表盘');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  Future<void> _openAppSettings() async {
    _logger.info('打开应用设置');
    await _permissionManager.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'AHP Dashboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '需要以下权限才能正常工作',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Permission list
                _buildPermissionItem(
                  icon: Icons.location_on,
                  title: '位置权限',
                  description: '用于获取实时速度和位置信息',
                  granted: _locationPermissionGranted,
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(
                  icon: Icons.bluetooth,
                  title: '蓝牙权限',
                  description: '用于连接到您的设备',
                  granted: _bluetoothPermissionGranted,
                ),
                const SizedBox(height: 48),

                // Action buttons
                if (_isRequesting)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _requestPermissions,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('授予权限'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _openAppSettings,
                        child: const Text('打开设置'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: granted
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              granted ? Icons.check : icon,
              color: granted ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
