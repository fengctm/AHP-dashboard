import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;

import '../../application/bluetooth/bluetooth_provider.dart';
import '../../application/bluetooth/bluetooth_state.dart';
import '../../core/services/bluetooth_service.dart';
import '../../core/utils/logging_service.dart';
import 'log_viewer_page.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bluetoothStateProvider.notifier).startScan();
    });
  }

  @override
  void dispose() {
    ref.read(bluetoothStateProvider.notifier).stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('连接远驱控制器'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                onPressed: () async {
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
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildStatusIndicator(bluetoothState, colorScheme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildScanButton(bluetoothState),
            ),
          ),
          if (bluetoothState.errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildErrorMessage(bluetoothState.errorMessage!, colorScheme),
              ),
            ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 8),
          ),
          _buildDeviceList(bluetoothState, colorScheme),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '远驱、YuanQu、Controller、BLE等',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildStatusIndicator(BluetoothState state, ColorScheme colorScheme) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (state.connectionState) {
      case BleConnectionState.disconnected:
        statusText = '未连接';
        statusColor = colorScheme.onSurfaceVariant;
        statusIcon = Icons.bluetooth_disabled;
        break;
      case BleConnectionState.scanning:
        statusText = '扫描中...';
        statusColor = colorScheme.primary;
        statusIcon = Icons.bluetooth_searching;
        break;
      case BleConnectionState.connecting:
        statusText = '连接中...';
        statusColor = colorScheme.tertiary;
        statusIcon = Icons.bluetooth_connected;
        break;
      case BleConnectionState.connected:
        statusText = '已连接';
        statusColor = colorScheme.primary;
        statusIcon = Icons.bluetooth_connected;
        break;
      default:
        statusText = '未知状态';
        statusColor = colorScheme.onSurfaceVariant;
        statusIcon = Icons.help_outline;
    }

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 28),
            const SizedBox(width: 12),
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (state.isConnected && state.connectedDevice != null)
              Text(
                state.connectedDevice!.platformName,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BluetoothState state) {
    final isScanning = state.isScanning;

    return FilledButton.icon(
      onPressed: isScanning
          ? () => ref.read(bluetoothStateProvider.notifier).stopScan()
          : () => ref.read(bluetoothStateProvider.notifier).startScan(),
      icon: Icon(isScanning ? Icons.stop : Icons.search),
      label: Text(isScanning ? '停止扫描' : '开始扫描'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }

  Widget _buildDeviceList(BluetoothState state, ColorScheme colorScheme) {
    if (state.scanResults.isEmpty && !state.isScanning) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth_searching,
                  size: 80,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 24),
                Text(
                  '准备扫描设备',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '点击下方按钮开始扫描',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTips(colorScheme),
              ],
            ),
          ),
        ),
      );
    }

    if (state.scanResults.isEmpty && state.isScanning) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在扫描设备...',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.devices,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '找到 ${state.scanResults.length} 个设备',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.isConnected && state.errorMessage != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildValidationStatus(state, colorScheme),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: state.scanResults.length,
            itemBuilder: (context, index) {
              final result = state.scanResults[index];
              return _buildDeviceItem(result, colorScheme);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildValidationStatus(BluetoothState state, ColorScheme colorScheme) {
    final isValidating = state.errorMessage?.contains('验证') == true;
    final isSuccess = state.latestData != null;

    return Card.filled(
      color: isValidating
          ? colorScheme.tertiaryContainer
          : (isSuccess
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.errorMessage ?? '验证中...',
                    style: const TextStyle(
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
                  color: colorScheme.tertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTips(ColorScheme colorScheme) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '提示',
                  style: TextStyle(
                    color: colorScheme.primary,
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
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildDeviceItem(ble.ScanResult result, ColorScheme colorScheme) {
    final device = result.device;
    final name = device.platformName;
    final rssi = result.rssi;

    final isYuanquDevice = _couldBeYuanquDevice(name);

    String signalText;
    Color signalColor;
    if (rssi >= -60) {
      signalText = '强';
      signalColor = colorScheme.primary;
    } else if (rssi >= -80) {
      signalText = '中';
      signalColor = colorScheme.tertiary;
    } else {
      signalText = '弱';
      signalColor = colorScheme.error;
    }

    return Card(
      elevation: isYuanquDevice ? 2 : 0,
      color: isYuanquDevice ? null : colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () async {
          final success = await ref
              .read(bluetoothStateProvider.notifier)
              .connect(device);

          if (!success || !mounted) {
            return;
          }

          ref.listen<BluetoothState>(
            bluetoothStateProvider,
            (previous, next) {
              if (next.latestData != null &&
                  (previous?.latestData?.timestamp !=
                      next.latestData?.timestamp)) {
                if (mounted) {
                  Navigator.pop(context, true);
                }
              }
              if (!next.isConnected && next.latestData == null) {
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isYuanquDevice
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.bluetooth,
                      color: isYuanquDevice
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
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
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: colorScheme.onPrimary, size: 10),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name.isNotEmpty ? name : '未命名设备',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isYuanquDevice) ...[
                          const SizedBox(width: 8),
                          Chip(
                            label: const Text('远驱'),
                            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MAC: ${device.remoteId.toString().substring(0, 17)}...',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '信号强度: $rssi dBm',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: signalColor.withAlpha(80),
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
    );
  }

  bool _couldBeYuanquDevice(String name) {
    if (name.isEmpty) return false;
    final lowerName = name.toLowerCase();
    return lowerName.contains('远驱') ||
        lowerName.contains('yuanqu') ||
        lowerName.contains('controller') ||
        lowerName.contains('ble') ||
        lowerName.contains('motor') ||
        lowerName.contains('电机');
  }

  Widget _buildErrorMessage(String message, ColorScheme colorScheme) {
    return Card.filled(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
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
      ),
    );
  }
}
