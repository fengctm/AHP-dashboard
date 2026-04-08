import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logging_service.dart';
import '../../core/theme/app_colors.dart';

/// 日志查看页面
class LogViewerPage extends ConsumerStatefulWidget {
  const LogViewerPage({super.key});

  @override
  ConsumerState<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends ConsumerState<LogViewerPage> {
  @override
  void initState() {
    super.initState();
    // 初始化日志服务
    logger.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙调试日志'),
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        elevation: 0,
        actions: [
          // 清空按钮
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              final confirmed = await _showConfirmDialog(context, isDark);
              if (confirmed && mounted) {
                logger.clear();
                setState(() {});
              }
            },
            tooltip: '清空日志',
          ),
          // 分享按钮
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareLog(isDark),
            tooltip: '分享日志',
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
          // 日志信息栏
          _buildInfoBar(isDark),

          const SizedBox(height: 8),

          // 日志内容
          Expanded(
            child: _buildLogContent(isDark),
          ),
        ],
      ),
      ),
    );
  }

  /// 构建信息栏
  Widget _buildInfoBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            size: 16,
            color: isDark ? AppColors.cyanNeon : AppColors.primaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '日志文件: ${logger.logFilePath ?? "未初始化"}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建日志内容
  Widget _buildLogContent(bool isDark) {
    final logs = logger.logs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无日志',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '操作蓝牙设备后，日志将显示在这里',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogItem(log, isDark, index);
      },
    );
  }

  /// 构建单条日志
  Widget _buildLogItem(String log, bool isDark, int index) {
    // 解析日志级别
    Color levelColor = Colors.grey;
    if (log.contains('[DEBUG]')) {
      levelColor = Colors.blue;
    } else if (log.contains('[INFO]')) {
      levelColor = Colors.green;
    } else if (log.contains('[WARNING]')) {
      levelColor = Colors.orange;
    } else if (log.contains('[ERROR]')) {
      levelColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        log,
        style: TextStyle(
          color: levelColor,
          fontSize: 11,
          fontFamily: 'Courier',
          height: 1.4,
        ),
      ),
    );
  }

  /// 显示确认对话框
  Future<bool> _showConfirmDialog(BuildContext context, bool isDark) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        title: const Text('清空日志'),
        content: const Text('确定要清空所有日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 分享日志
  void _shareLog(bool isDark) async {
    final logFile = await logger.getLogFileForSharing();
    if (logFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志文件不存在')),
        );
      }
      return;
    }

    // 这里可以使用 share_plus 包分享文件
    // 暂时只显示提示
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
