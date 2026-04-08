import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志服务
///
/// 将日志保存到本地文件，方便调试和问题排查
class LoggingService {
  // 单例模式
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final _logController = StreamController<String>.broadcast();
  File? _logFile;
  final _logs = <String>[];
  bool _isInitialized = false;
  final int _maxLogs = 1000; // 最多保存1000条日志

  // 写入队列和锁
  final _writeQueue = <String>[];
  bool _isWriting = false;

  /// 日志流
  Stream<String> get logStream => _logController.stream;

  /// 初始化日志服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      // 创建日志目录
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 使用日期时间作为日志文件名
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
      _logFile = File('${logDir.path}/yuanqu_ble_$dateStr.log');

      // 写入文件头
      final header = '''
========================================
远驱控制器蓝牙日志
开始时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}
========================================

''';
      await _logFile!.writeAsString(header);

      _isInitialized = true;
      _log(LogLevel.info, '日志服务初始化成功');
      _log(LogLevel.info, '日志文件: ${_logFile!.path}');

      // 启动写入队列处理
      _startWriteQueueProcessor();
    } catch (e) {
      debugPrint('日志服务初始化失败: $e');
      // 即使初始化失败，也允许运行（使用控制台输出）
      _isInitialized = true;
    }
  }

  /// 启动写入队列处理器
  void _startWriteQueueProcessor() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_writeQueue.isNotEmpty && !_isWriting) {
        _isWriting = true;
        final batch = List<String>.from(_writeQueue);
        _writeQueue.clear();

        try {
          final content = batch.join('\n');
          await _logFile?.writeAsString(content, mode: FileMode.append);
          if (kDebugMode) {
            debugPrint('写入 ${batch.length} 条日志到文件');
          }
        } catch (e) {
          debugPrint('写入日志失败: $e');
        } finally {
          _isWriting = false;
        }
      }
    });
  }

  /// 写入日志
  void _log(LogLevel level, String message) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss.SSS').format(now);
    final levelStr = level.name.toUpperCase();

    final logEntry = '[$timeStr] [$levelStr] $message';

    // 添加到内存
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // 发送到流
    if (!_logController.isClosed) {
      _logController.add(logEntry);
    }

    // 添加到写入队列
    _writeQueue.add(logEntry);

    // 同时打印到控制台
    debugPrint(logEntry);
  }

  /// DEBUG级别日志
  void debug(String message) => _log(LogLevel.debug, message);

  /// INFO级别日志
  void info(String message) => _log(LogLevel.info, message);

  /// WARNING级别日志
  void warning(String message) => _log(LogLevel.warning, message);

  /// ERROR级别日志
  void error(String message) => _log(LogLevel.error, message);

  /// 获取所有日志
  List<String> get logs => List.unmodifiable(_logs);

  /// 清空日志
  void clear() {
    _logs.clear();
    _writeQueue.clear();
    _log(LogLevel.info, '日志已清空');
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFile?.path;

  /// 获取日志文件内容
  Future<String> getLogFileContent() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return '日志文件不存在';
    }
    return await _logFile!.readAsString();
  }

  /// 获取日志文件用于分享
  Future<File?> getLogFileForSharing() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return null;
    }
    return _logFile;
  }

  /// 释放资源
  void dispose() {
    _logController.close();
  }
}

/// 全局日志实例
final logger = LoggingService();
