import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;

import '../../application/bluetooth/bluetooth_provider.dart';
import '../../application/bluetooth/bluetooth_state.dart';
import '../../core/services/bluetooth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/logging_service.dart';
import 'log_viewer_page.dart';

/// 蓝牙设备连接页面
class BluetoothConnectPage extends ConsumerStatefulWidget {
  const BluetoothConnectPage({super.key});

  @override
  ConsumerState<BluetoothConnectPage> createState() =>
      _BluetoothConnectPageState();
}

class _BluetoothConnectPageState extends ConsumerState<BluetoothConnectPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时自动开始扫描
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bluetoothStateProvider.notifier).startScan();
    });
  }

  @override
  void dispose() {
    // 页面销毁时停止扫描
    ref.read(bluetoothStateProvider.notifier).stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bluetoothState = ref.watch(bluetoothStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('连接远驱控制器'),
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        elevation: 0,
        actions: [
          // 查看日志按钮
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () async {
              // 初始化日志
              await logger.initialize();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogViewerPage(),
                  ),
                );
              }
            },
            tooltip: '查看日志',
          ),
          // 帮助按钮
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context, isDark),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.9),
                  ]
                : [
                    AppColors.backgroundLight,
                    AppColors.backgroundLight.withValues(alpha: 0.95),
                  ],
          ),
        ),
        child: Column(
          children: [
            // 状态指示器
            _buildStatusIndicator(bluetoothState, isDark),

            const SizedBox(height: 16),

            // 扫描按钮
            _buildScanButton(bluetoothState, isDark),

            const SizedBox(height: 8),

            // 设备列表
            Expanded(
              child: _buildDeviceList(bluetoothState, isDark),
            ),

            // 错误消息/提示信息
            if (bluetoothState.errorMessage != null)
              _buildErrorMessage(bluetoothState.errorMessage!, isDark),
          ],
        ),
      ),
    );
  }

  /// 显示帮助对话框
  void _showHelpDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        title: const Text('使用说明'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem('1.', '确保设备蓝牙已开启'),
              const SizedBox(height: 8),
              _buildHelpItem('2.', '点击"开始扫描"查找设备'),
              const SizedBox(height: 8),
              _buildHelpItem('3.', '从列表中选择远驱控制器设备'),
              const SizedBox(height: 8),
              _buildHelpItem('4.', '等待连接成功后自动返回'),
              const SizedBox(height: 16),
              Text(
                '支持的设备名称:',
                style: TextStyle(
                  color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '远驱、YuanQu、Controller、BLE等',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '知道了',
              style: TextStyle(
                color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: Text(text)),
      ],
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(BluetoothState state, bool isDark) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (state.connectionState) {
      case BleConnectionState.disconnected:
        statusText = '未连接';
        statusColor = Colors.grey;
        statusIcon = Icons.bluetooth_disabled;
        break;
      case BleConnectionState.scanning:
        statusText = '扫描中...';
        statusColor = isDark ? AppColors.cyanNeon : AppColors.primaryBlue;
        statusIcon = Icons.bluetooth_searching;
        break;
      case BleConnectionState.connecting:
        statusText = '连接中...';
        statusColor = Colors.orange;
        statusIcon = Icons.bluetooth_connected;
        break;
      case BleConnectionState.connected:
        statusText = '已连接';
        statusColor = Colors.green;
        statusIcon = Icons.bluetooth_connected;
        break;
      default:
        statusText = '未知状态';
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (state.isConnected && state.connectedDevice != null)
            Text(
              state.connectedDevice!.platformName,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建扫描按钮
  Widget _buildScanButton(BluetoothState state, bool isDark) {
    final isScanning = state.isScanning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isScanning
              ? () => ref.read(bluetoothStateProvider.notifier).stopScan()
              : () => ref.read(bluetoothStateProvider.notifier).startScan(),
          icon: Icon(isScanning ? Icons.stop : Icons.search),
          label: Text(isScanning ? '停止扫描' : '开始扫描'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
            foregroundColor: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建设备列表
  Widget _buildDeviceList(BluetoothState state, bool isDark) {
    if (state.scanResults.isEmpty && !state.isScanning) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_searching,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 24),
              Text(
                '准备扫描设备',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '点击下方按钮开始扫描',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildTips(isDark),
            ],
          ),
        ),
      );
    }

    if (state.scanResults.isEmpty && state.isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '正在扫描设备...',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 设备数量提示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.devices,
                size: 16,
                color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                '找到 ${state.scanResults.length} 个设备',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // 设备列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.scanResults.length,
            itemBuilder: (context, index) {
              final result = state.scanResults[index];
              return _buildDeviceItem(result, isDark);
            },
          ),
        ),

        // 验证状态显示
        if (state.isConnected && state.errorMessage != null)
          _buildValidationStatus(state, isDark),

        const SizedBox(height: 8),

        // 错误消息
        if (state.errorMessage != null && !state.isConnected)
          _buildErrorMessage(state.errorMessage!, isDark),
      ],
    );
  }

  /// 构建验证状态显示
  Widget _buildValidationStatus(BluetoothState state, bool isDark) {
    final isValidating = state.errorMessage?.contains('验证') == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValidating
            ? Colors.orange.withValues(alpha: 0.1)
            : (state.latestData != null
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValidating
              ? Colors.orange
              : (state.latestData != null ? Colors.green : Colors.red),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (isValidating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  state.latestData != null ? Icons.check_circle : Icons.error,
                  color: state.latestData != null ? Colors.green : Colors.red,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.errorMessage ?? '验证中...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (isValidating)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                backgroundColor: isDark ? Colors.white24 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建提示信息
  Widget _buildTips(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white10 : Colors.black12)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                '提示',
                style: TextStyle(
                  color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTipItem('• 确保远驱控制器已开机'),
          _buildTipItem('• 设备应在2米范围内'),
          _buildTipItem('• 只会显示可能的远驱设备'),
          _buildTipItem('• 连接后会验证数据，10秒内无数据将自动断开'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 构建设备项
  Widget _buildDeviceItem(ble.ScanResult result, bool isDark) {
    final device = result.device;
    final name = device.platformName;
    final rssi = result.rssi;

    // 检查是否可能是远驱设备
    final isYuanquDevice = _couldBeYuanquDevice(name);

    // 信号强度
    String signalText;
    Color signalColor;
    if (rssi >= -60) {
      signalText = '强';
      signalColor = Colors.green;
    } else if (rssi >= -80) {
      signalText = '中';
      signalColor = Colors.orange;
    } else {
      signalText = '弱';
      signalColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success = await ref
                .read(bluetoothStateProvider.notifier)
                .connect(device);

            // 连接失败，直接返回
            if (!success || !mounted) {
              return;
            }

            // 连接成功，设置监听器
            ref.listen<BluetoothState>(
              bluetoothStateProvider,
              (previous, next) {
                // 收到有效数据，返回仪表盘
                if (next.latestData != null &&
                    (previous?.latestData?.timestamp !=
                        next.latestData?.timestamp)) {
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                }
                // 如果连接断开且没有收到数据，也返回
                if (!next.isConnected && next.latestData == null) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isYuanquDevice
                    ? (isDark ? AppColors.cyanNeon : AppColors.primaryBlue)
                    : (isDark ? Colors.white24 : Colors.black12),
                width: isYuanquDevice ? 2 : 1,
              ),
              boxShadow: isYuanquDevice
                  ? [
                      BoxShadow(
                        color: (isDark ? AppColors.cyanNeon : AppColors.primaryBlue)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // 蓝牙图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cyanNeon.withValues(alpha: 0.2)
                        : AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth,
                        color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
                        size: 24,
                      ),
                      if (isYuanquDevice)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // 设备信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name.isNotEmpty ? name : '未命名设备',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isYuanquDevice) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.cyanNeon : AppColors.primaryBlue)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '远驱',
                                style: TextStyle(
                                  color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MAC: ${device.remoteId.toString().substring(0, 17)}...',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '信号强度: $rssi dBm',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // 信号强度
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: signalColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        color: signalColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        signalText,
                        style: TextStyle(
                          color: signalColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 检查是否可能是远驱设备
  bool _couldBeYuanquDevice(String name) {
    if (name.isEmpty) return false;
    final lowerName = name.toLowerCase();
    return lowerName.contains('远驱') ||
        lowerName.contains('yuanqu') ||
        lowerName.contains('controller') ||
        lowerName.contains('ble') ||
        lowerName.contains('motor') ||
        lowerName.contains('电机') ||
        lowerName.contains('controller');
  }

  /// 构建错误消息
  Widget _buildErrorMessage(String message, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              ref.read(bluetoothStateProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }
}
