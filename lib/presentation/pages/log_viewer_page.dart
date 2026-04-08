import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logging_service.dart';

class LogViewerPage extends ConsumerStatefulWidget {
  const LogViewerPage({super.key});

  @override
  ConsumerState<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends ConsumerState<LogViewerPage> {
  @override
  void initState() {
    super.initState();
    logger.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('蓝牙调试日志'),
            actions: [
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () async {
                  final confirmed = await _showConfirmDialog(context);
                  if (confirmed && mounted) {
                    logger.clear();
                    setState(() {});
                  }
                },
                tooltip: '清空日志',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareLog(),
                tooltip: '分享日志',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildInfoBar(colorScheme),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 8),
          ),
          _buildLogContent(colorScheme),
        ],
      ),
    );
  }

  Widget _buildInfoBar(ColorScheme colorScheme) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.description,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '日志文件: ${logger.logFilePath ?? "未初始化"}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogContent(ColorScheme colorScheme) {
    final logs = logger.logs;

    if (logs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无日志',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '操作蓝牙设备后，日志将显示在这里',
                style: TextStyle(
                  color: colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildLogItem(log, colorScheme, index);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 2),
      ),
    );
  }

  Widget _buildLogItem(String log, ColorScheme colorScheme, int index) {
    Color levelColor = colorScheme.outline;
    if (log.contains('[DEBUG]')) {
      levelColor = colorScheme.primary;
    } else if (log.contains('[INFO]')) {
      levelColor = colorScheme.tertiary;
    } else if (log.contains('[WARNING]')) {
      levelColor = colorScheme.tertiary;
    } else if (log.contains('[ERROR]')) {
      levelColor = colorScheme.error;
    }

    return Card.filled(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          log,
          style: TextStyle(
            color: levelColor,
            fontSize: 11,
            fontFamily: 'Courier',
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空所有日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '清空',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _shareLog() async {
    final logFile = await logger.getLogFileForSharing();
    if (logFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志文件不存在')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('日志文件路径: ${logFile.path}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
