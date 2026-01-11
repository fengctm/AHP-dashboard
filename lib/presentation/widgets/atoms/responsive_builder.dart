import 'package:flutter/material.dart';

/// 设备类型枚举
enum DeviceType { mobile, tablet, desktop }

/// 屏幕尺寸枚举
enum ScreenSize { small, medium, large, extraLarge }

/// 布局信息类
class LayoutInfo {
  final double width;
  final double height;
  final Orientation orientation;
  final DeviceType deviceType;
  final ScreenSize screenSize;
  final double pixelRatio;

  LayoutInfo({
    required this.width,
    required this.height,
    required this.orientation,
    required this.deviceType,
    required this.screenSize,
    required this.pixelRatio,
  });

  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  bool get isMobile => deviceType == DeviceType.mobile;

  bool get isTablet => deviceType == DeviceType.tablet;

  bool get isDesktop => deviceType == DeviceType.desktop;

  double get aspectRatio => width / height;

  /// 获取适合当前屏幕的字体大小
  double getResponsiveFontSize(double baseSize) {
    double multiplier = 1.0;

    if (isDesktop) multiplier = 1.2;
    if (isTablet) multiplier = 1.1;
    if (isLandscape) multiplier *= 1.1;

    return baseSize * multiplier;
  }

  /// 获取适合当前屏幕的间距
  double getResponsiveSpacing(double baseSpacing) {
    double multiplier = 1.0;

    if (isDesktop) multiplier = 1.3;
    if (isTablet) multiplier = 1.15;
    if (isLandscape) multiplier *= 1.1;

    return baseSpacing * multiplier;
  }

  /// 获取网格列数
  int getGridColumnCount() {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    if (isLandscape) return 2;
    return 1;
  }
}

/// 响应式构建器
/// 根据屏幕尺寸和方向自动调整布局
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, LayoutInfo) builder;
  final Widget? mobilePortrait;
  final Widget? mobileLandscape;
  final Widget? tabletPortrait;
  final Widget? tabletLandscape;
  final Widget? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
    this.mobilePortrait,
    this.mobileLandscape,
    this.tabletPortrait,
    this.tabletLandscape,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final pixelRatio = MediaQuery.of(context).devicePixelRatio;

        // 确定设备类型
        DeviceType deviceType;
        if (width < 600) {
          deviceType = DeviceType.mobile;
        } else if (width < 1200) {
          deviceType = DeviceType.tablet;
        } else {
          deviceType = DeviceType.desktop;
        }

        // 确定屏幕尺寸
        ScreenSize screenSize;
        if (width < 360) {
          screenSize = ScreenSize.small;
        } else if (width < 600) {
          screenSize = ScreenSize.medium;
        } else if (width < 840) {
          screenSize = ScreenSize.large;
        } else {
          screenSize = ScreenSize.extraLarge;
        }

        final layoutInfo = LayoutInfo(
          width: width,
          height: height,
          orientation: orientation,
          deviceType: deviceType,
          screenSize: screenSize,
          pixelRatio: pixelRatio,
        );

        // 如果提供了特定布局，优先使用
        if (desktop != null && deviceType == DeviceType.desktop) {
          return desktop!;
        }
        if (tabletLandscape != null &&
            deviceType == DeviceType.tablet &&
            orientation == Orientation.landscape) {
          return tabletLandscape!;
        }
        if (tabletPortrait != null &&
            deviceType == DeviceType.tablet &&
            orientation == Orientation.portrait) {
          return tabletPortrait!;
        }
        if (mobileLandscape != null &&
            deviceType == DeviceType.mobile &&
            orientation == Orientation.landscape) {
          return mobileLandscape!;
        }
        if (mobilePortrait != null &&
            deviceType == DeviceType.mobile &&
            orientation == Orientation.portrait) {
          return mobilePortrait!;
        }

        return builder(context, layoutInfo);
      },
    );
  }
}

/// 简化的响应式小部件
class ResponsiveWidget extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? landscape;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.landscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final width = MediaQuery.of(context).size.width;

    // 横屏优先
    if (orientation == Orientation.landscape && landscape != null) {
      return landscape!(context);
    }

    // 桌面优先
    if (width >= 1200 && desktop != null) {
      return desktop!(context);
    }

    // 平板优先
    if (width >= 600 && tablet != null) {
      return tablet!(context);
    }

    // 默认移动端
    return mobile(context);
  }
}

/// 响应式间距
class ResponsiveSpacing {
  static double of(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    double multiplier = 1.0;

    if (width >= 1200) {
      multiplier = 1.3; // 桌面
    } else if (width >= 600) {
      multiplier = 1.15; // 平板
    } else if (orientation == Orientation.landscape) {
      multiplier = 1.1; // 移动横屏
    }

    return base * multiplier;
  }

  static double small(BuildContext context) => of(context, 8.0);

  static double medium(BuildContext context) => of(context, 16.0);

  static double large(BuildContext context) => of(context, 24.0);

  static double extraLarge(BuildContext context) => of(context, 32.0);
}

/// 响应式字体大小
class ResponsiveFontSize {
  static double of(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    double multiplier = 1.0;

    if (width >= 1200) {
      multiplier = 1.2; // 桌面
    } else if (width >= 600) {
      multiplier = 1.1; // 平板
    } else if (orientation == Orientation.landscape) {
      multiplier = 1.1; // 移动横屏
    }

    return base * multiplier;
  }

  static double headline(BuildContext context) => of(context, 32.0);

  static double title(BuildContext context) => of(context, 20.0);

  static double body(BuildContext context) => of(context, 16.0);

  static double small(BuildContext context) => of(context, 14.0);
}
