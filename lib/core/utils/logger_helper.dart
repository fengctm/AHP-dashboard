import 'package:logging/logging.dart';

/// 日志工具类，用于统一管理日志配置和获取Logger实例
class LoggerHelper {
  /// 初始化日志系统
  static void initializeLogger({
    Level rootLevel = Level.ALL,
    void Function(LogRecord)? onRecord,
  }) {
    // 设置根日志级别
    Logger.root.level = rootLevel;

    // 设置日志记录处理器
    Logger.root.onRecord.listen(onRecord ?? _defaultLogHandler);
  }

  /// 默认日志处理函数
  static void _defaultLogHandler(LogRecord record) {
    final time = record.time.toLocal().toString().substring(11, 23);
    final loggerName = record.loggerName;
    final level = record.level.name.padRight(7);
    final message = record.message;
    final error = record.error;
    final stackTrace = record.stackTrace;

    String logString = '$time: $loggerName: $level: $message';
    if (error != null) {
      logString += '\n  Error: $error';
    }
    if (stackTrace != null) {
      logString += '\n  StackTrace: $stackTrace';
    }

    // 在开发环境下使用print，生产环境下可以替换为其他日志输出方式
    // ignore: avoid_print
    print(logString);
  }

  /// 获取指定名称的Logger实例
  static Logger getLogger(String name) {
    return Logger(name);
  }

  /// 获取核心服务模块的Logger
  static Logger getCoreLogger(String serviceName) {
    return getLogger('core.$serviceName');
  }

  /// 获取适配器模块的Logger
  static Logger getAdapterLogger(String adapterName) {
    return getLogger('adapter.$adapterName');
  }

  /// 获取业务模块的Logger
  static Logger getModuleLogger(String moduleName) {
    return getLogger('module.$moduleName');
  }

  /// 获取组件模块的Logger
  static Logger getWidgetLogger(String widgetName) {
    return getLogger('widget.$widgetName');
  }

  /// 设置指定Logger的日志级别
  static void setLoggerLevel(String loggerName, Level level) {
    Logger(loggerName).level = level;
  }

  /// 设置根日志级别
  static void setRootLevel(Level level) {
    Logger.root.level = level;
  }
}
