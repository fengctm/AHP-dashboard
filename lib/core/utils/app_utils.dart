import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用工具类
class AppUtils {
  /// 格式化数字显示
  static String formatNumber(double value, {int decimalPlaces = 1}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  /// 格式化时间
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化完整时间
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// 获取状态栏高度
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 获取底部安全区高度
  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// 获取屏幕尺寸
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// 检查是否为横屏
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// 检查是否为深色模式
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 震动反馈
  static void vibrate({Duration duration = const Duration(milliseconds: 50)}) {
    HapticFeedback.vibrate();
  }

  /// 轻微震动
  static void vibrateLight() {
    HapticFeedback.lightImpact();
  }

  /// 中等震动
  static void vibrateMedium() {
    HapticFeedback.mediumImpact();
  }

  /// 重度震动
  static void vibrateHeavy() {
    HapticFeedback.heavyImpact();
  }

  /// 显示提示
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示对话框
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    bool barrierDismissible = true,
  }) async {
    return await showDialog(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// 计算两点间距离
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371000; // 米
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = (dLat / 2) * (dLat / 2) +
        _toRadians(lat1) * _toRadians(lat2) * (dLon / 2) * (dLon / 2);
    final double c = 2 * (a / (1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * 3.141592653589793 / 180;
  }

  /// 防抖函数
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Future.delayed(delay, callback);
  }

  /// 节流函数
  static void throttle(
    VoidCallback callback, {
    Duration interval = const Duration(milliseconds: 1000),
  }) {
    const Map<String, int> lastCall = {};
    final key = callback.hashCode.toString();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (!lastCall.containsKey(key) || 
        now - lastCall[key]! > interval.inMilliseconds) {
      lastCall[key] = now;
      callback();
    }
  }

  /// 生成随机颜色
  static Color randomColor({int seed = 0}) {
    return Color.fromARGB(
      255,
      50 + (seed * 13) % 200,
      50 + (seed * 29) % 200,
      50 + (seed * 47) % 200,
    );
  }

  /// 混合颜色
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.fromARGB(
      255,
      ((color1.r * 255.0).round() * (1 - ratio) + (color2.r * 255.0).round() * ratio).toInt(),
      ((color1.g * 255.0).round() * (1 - ratio) + (color2.g * 255.0).round() * ratio).toInt(),
      ((color1.b * 255.0).round() * (1 - ratio) + (color2.b * 255.0).round() * ratio).toInt(),
    );
  }

  /// 获取对比度颜色（用于文本）
  static Color getContrastColor(Color background) {
    final luminance = ((background.r * 255.0).round() * 0.299 +
            (background.g * 255.0).round() * 0.587 +
            (background.b * 255.0).round() * 0.114) /
        255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 生成唯一ID
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        List.generate(6, (index) => (DateTime.now().microsecondsSinceEpoch % 36).toRadixString(36)).join();
  }

  /// 安全解析数字
  static double safeParseDouble(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// 安全解析整数
  static int safeParseInt(String? value, {int defaultValue = 0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// 检查是否为有效邮箱
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 检查是否为有效手机号
  static bool isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  /// 压缩字符串（显示首尾）
  static String compressString(String text, {int start = 6, int end = 4}) {
    if (text.length <= start + end) return text;
    return '${text.substring(0, start)}...${text.substring(text.length - end)}';
  }

  /// 百分比计算
  static double calculatePercentage(double current, double total) {
    if (total == 0) return 0;
    return (current / total) * 100;
  }

  /// 限制数值范围
  static double clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }

  /// 线性插值
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// 平滑步进
  static double smoothstep(double edge0, double edge1, double x) {
    final t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3 - 2 * t);
  }
}

/// 数值格式化工具
class NumberFormatter {
  /// 格式化速度
  static String speed(double value) {
    return '${value.toStringAsFixed(1)} km/h';
  }

  /// 格式化功率
  static String power(double value) {
    return '${value.toStringAsFixed(1)} kW';
  }

  /// 格式化温度
  static String temperature(double value) {
    return '${value.toStringAsFixed(1)}°C';
  }

  /// 格式化电量
  static String battery(int value) {
    return '$value%';
  }

  /// 格式化里程
  static String mileage(double value) {
    return '${value.toStringAsFixed(1)} km';
  }

  /// 格式化能耗
  static String energy(double value) {
    return '${value.toStringAsFixed(1)} kWh/100km';
  }

  /// 格式化百分比
  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// 格式化大数字
  static String largeNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// 时间格式化工具
class TimeFormatter {
  /// 格式化持续时间
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 格式化倒计时
  static String countdown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化时间戳
  static String timestamp(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return duration.toString().split('.').first;
  }
}