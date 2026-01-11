# AHP Dashboard 设计规范文档

## 📋 文档概述

本文档定义了 AHP Dashboard 项目的完整设计规范，包括主题系统、页面设计、动画效果、配色方案、组件化开发和多端适配策略。

**版本**: v1.0  
**最后更新**: 2026-01-06  
**适用平台**: Android, iOS, Linux, Windows, macOS

---

## 🎨 一、主题设计规范

### 1.1 主题模式支持

#### 系统跟随模式
```dart
// 默认行为：跟随系统主题
ThemeMode.system
```

- **自动检测**: 应用启动时检测系统主题设置
- **实时切换**: 监听系统主题变化并自动应用
- **用户体验**: 无需手动配置即可获得舒适的视觉体验

#### 手动切换模式
```dart
// 用户可手动切换主题
ThemeMode.light   // 浅色主题
ThemeMode.dark    // 深色主题
```

#### 主题记忆功能
```dart
// 使用本地存储记住用户选择
class ThemeService {
  static const String _themeKey = 'user_theme_mode';
  
  Future<void> saveThemeMode(ThemeMode mode) async {
    // 保存到本地存储
  }
  
  Future<ThemeMode> loadThemeMode() async {
    // 从本地存储读取
  }
}
```

### 1.2 主题切换流程

```
应用启动
    ↓
检查本地存储的主题设置
    ↓
存在？ → 使用本地主题
    ↓ 不存在
检查系统主题
    ↓
应用对应主题
    ↓
监听系统主题变化
    ↓
用户手动切换 → 保存并应用新主题
```

### 1.3 主题数据管理

```dart
// 主题状态管理 (Riverpod)
@Riverpod()
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    // 初始化时加载保存的主题
    return _loadThemeMode();
  }
  
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    await _saveThemeMode(newMode);
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _saveThemeMode(mode);
  }
}
```

---

## 🎯 二、页面设计规范

### 2.1 设计原则

遵循 **Material Design 3** 规范，同时融入现代化设计元素：

#### 布局原则
- **卡片式设计**: 使用卡片容器，提供视觉层次
- **留白充足**: 保持适当的间距，避免拥挤
- **视觉层次**: 通过大小、颜色、阴影建立层次关系
- **一致性**: 保持页面间的一致性

#### 响应式布局
```dart
// 使用 MediaQuery 进行响应式设计
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    
    if (orientation == Orientation.landscape) {
      // 横屏布局
      return _buildLandscapeLayout(size);
    } else {
      // 竖屏布局
      return _buildPortraitLayout(size);
    }
  }
}
```

### 2.2 页面结构

#### 标准页面模板
```dart
class StandardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 应用栏
      appBar: AppBar(
        title: Text('页面标题'),
        actions: [
          // 操作按钮
        ],
      ),
      
      // 主体内容
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 页面内容组件
            ],
          ),
        ),
      ),
      
      // 悬浮按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 2.3 页面过渡动画

```dart
// 页面切换动画
PageRouteBuilder(
  pageBuilder: (_, __, ___) => TargetPage(),
  transitionsBuilder: (_, animation, __, child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        )),
        child: child,
      ),
    );
  },
  transitionDuration: Duration(milliseconds: 350),
)
```

---

## ✨ 三、动画设计规范

### 3.1 动画理念

借鉴 **苹果 Human Interface Guidelines** 的动画原则：

#### 核心理念
- **自然**: 动画应符合物理直觉
- **有意义**: 每个动画都应传达信息
- **流畅**: 60fps 无卡顿
- **克制**: 避免过度动画

### 3.2 动画曲线

```dart
// 使用苹果风格的缓动曲线
class AppleAnimation {
  // 标准动画
  static const Curve easeInOut = Curves.easeInOutCubic;
  
  // 弹性动画
  static const Curve spring = Curves.elasticOut;
  
  // 快速进入，缓慢退出
  static const Curve easeIn = Curves.easeInCubic;
  
  // 缓慢进入，快速退出
  static const Curve easeOut = Curves.easeOutCubic;
}
```

### 3.3 常用动画模式

#### 1. 微交互动画
```dart
// 按钮点击反馈
class InteractiveButton extends StatefulWidget {
  @override
  _InteractiveButtonState createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
```

#### 2. 列表项进入动画
```dart
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

#### 3. 状态变化动画
```dart
// 状态切换平滑过渡
class SmoothStateTransition extends StatelessWidget {
  final bool isActive;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: isActive 
          ? Icon(Icons.check, key: ValueKey('active'))
          : Icon(Icons.close, key: ValueKey('inactive')),
      ),
    );
  }
}
```

### 3.4 动画性能优化

```dart
// 使用 RepaintBoundary 避免重绘
class OptimizedAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: YourWidget(),
      ),
    );
  }
}
```

---

## 🎨 四、配色方案规范

### 4.1 设计理念

配色方案围绕以下核心概念：
- **科技感**: 现代、未来感
- **扁平化**: 简洁、无渐变
- **速度感**: 动态、活力
- **互联性**: 连接、网络

### 4.2 基础配色

#### 主色调 - 科技蓝
```dart
class AppColors {
  // 主色 - 科技蓝
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // 次要色 - 活力橙
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // 强调色 - 速度绿
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF388E3C);
  
  // 警告色
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
}
```

#### 浅色主题配色
```dart
class LightThemeColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE3E3E3);
  
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF212121);
  
  static const Color divider = Color(0xFFE0E0E0);
  static const Color hint = Color(0xFF757575);
}
```

#### 深色主题配色
```dart
class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onBackground = Color(0xFFE0E0E0);
  
  static const Color divider = Color(0xFF333333);
  static const Color hint = Color(0xFF9E9E9E);
}
```

### 4.3 语义化配色

```dart
class SemanticColors {
  // 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 数据可视化
  static const Color speed = Color(0xFF00BCD4);      // 速度 - 青色
  static const Color power = Color(0xFFFF9800);      // 功率 - 橙色
  static const Color battery = Color(0xFF4CAF50);    // 电量 - 绿色
  static const Color temperature = Color(0xFFF44336); // 温度 - 红色
  
  // 连接状态
  static const Color connected = Color(0xFF4CAF50);
  static const Color connecting = Color(0xFFFFC107);
  static const Color disconnected = Color(0xFF9E9E9E);
  static const Color errorState = Color(0xFFF44336);
}
```

### 4.4 主题配置

```dart
// 浅色主题
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: LightThemeColors.surface,
    background: LightThemeColors.background,
  ),
  scaffoldBackgroundColor: LightThemeColors.background,
  cardColor: LightThemeColors.surface,
  dividerColor: LightThemeColors.divider,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: LightThemeColors.onBackground,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: LightThemeColors.onBackground,
    ),
  ),
);

// 深色主题
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    surface: DarkThemeColors.surface,
    background: DarkThemeColors.background,
  ),
  scaffoldBackgroundColor: DarkThemeColors.background,
  cardColor: DarkThemeColors.surface,
  dividerColor: DarkThemeColors.divider,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: DarkThemeColors.onBackground,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: DarkThemeColors.onBackground,
    ),
  ),
);
```

---

## 🧩 五、组件化开发规范

### 5.1 组件设计原则

#### 单一职责原则 (SRP)
每个组件只负责一个明确的功能，避免"上帝组件"。

```dart
// ❌ 错误示例 - 过度复杂的组件
class BadDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 数据获取
        FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            // 数据处理
            if (snapshot.hasData) {
              // UI 渲染
              return Column(
                children: [
                  // 样式定义
                  Container(
                    // ... 大量代码
                  ),
                  // 事件处理
                  GestureDetector(
                    onTap: () {
                      // 业务逻辑
                    },
                  ),
                ],
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ],
    );
  }
}
```

```dart
// ✅ 正确示例 - 职责分离
// 1. 数据获取组件
class DataFetcher extends StatelessWidget {
  final Widget Function(Map<String, dynamic> data) builder;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return builder(snapshot.data!);
        return LoadingIndicator();
      },
    );
  }
}

// 2. 样式容器组件
class CardContainer extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }
}

// 3. 交互组件
class InteractiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

// 4. 组合使用
class DashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataFetcher(
      builder: (data) => InteractiveCard(
        onTap: () => _handleTap(data),
        child: CardContainer(
          child: DashboardContent(data: data),
        ),
      ),
    );
  }
}
```

### 5.2 组件拆分策略

#### 按功能层次拆分

```
组件层次结构：
├── 原子组件 (Atoms)
│   ├── Button
│   ├── Icon
│   ├── Text
│   └── Divider
│
├── 分子组件 (Molecules)
│   ├── StatCard
│   ├── DeviceItem
│   └── StatusIndicator
│
├── 有机体组件 (Organisms)
│   ├── DashboardGrid
│   ├── DeviceList
│   └── ControlPanel
│
└── 页面组件 (Templates)
    ├── DashboardPage
    ├── SettingsPage
    └── DeviceDetailPage
```

#### 按职责拆分

```dart
// 组件文件结构
lib/
├── presentation/
│   ├── widgets/
│   │   ├── atoms/              // 原子组件
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_icon.dart
│   │   │   └── custom_text.dart
│   │   ├── molecules/          // 分子组件
│   │   │   ├── speed_card.dart
│   │   │   ├── battery_indicator.dart
│   │   │   └── connection_status.dart
│   │   ├── organisms/          // 有机体组件
│   │   │   ├── dashboard_grid.dart
│   │   │   └── device_control_panel.dart
│   │   └── templates/          // 页面模板
│   │       └── dashboard_template.dart
│   └── pages/                  // 页面
│       ├── dashboard_page.dart
│       └── settings_page.dart
```

### 5.3 组件接口设计

```dart
// 统一的组件接口
abstract class CustomWidget extends StatelessWidget {
  const CustomWidget({Key? key}) : super(key: key);
  
  // 标准化属性
  Widget build(BuildContext context);
}

// 带状态的组件接口
abstract class StatefulCustomWidget extends StatefulWidget {
  const StatefulCustomWidget({Key? key}) : super(key: key);
}
```

### 5.4 组件参数规范

```dart
// 使用命名参数提高可读性
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  
  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.unit = '',
    this.color = AppColors.primary,
    this.icon = Icons.show_chart,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 实现代码
  }
}

// 使用示例
StatCard(
  title: '当前速度',
  value: '45',
  unit: 'km/h',
  color: AppColors.speed,
  icon: Icons.speed,
  onTap: () => print('Speed tapped'),
)
```

---

## 📱 六、多端适配规范

### 6.1 平台检测

```dart
class PlatformAdapter {
  // 检测当前平台
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isLinux => Platform.isLinux;
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  
  // 检测移动平台
  static bool get isMobile => isAndroid || isIOS;
  
  // 检测桌面平台
  static bool get isDesktop => isLinux || isWindows || isMacOS;
  
  // 获取平台特定的样式
  static PlatformStyle getPlatformStyle() {
    if (isIOS) return PlatformStyle.cupertino;
    if (isAndroid) return PlatformStyle.material;
    return PlatformStyle.material; // 默认使用 Material
  }
}
```

### 6.2 平台特定 UI

```dart
// 平台自适应按钮
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // iOS 风格按钮
      return CupertinoButton(
        onPressed: onPressed,
        child: Text(text),
      );
    } else {
      // Android/Web/Desktop 风格按钮
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }
  }
}
```

### 6.3 响应式布局系统

```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, LayoutInfo) builder;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        final layoutInfo = LayoutInfo(
          width: width,
          height: height,
          orientation: orientation,
          deviceType: _getDeviceType(width, height),
          screenSize: _getScreenSize(width),
        );
        
        return builder(context, layoutInfo);
      },
    );
  }
  
  DeviceType _getDeviceType(double width, double height) {
    if (width < 600) return DeviceType.mobile;
    if (width < 1200) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  ScreenSize _getScreenSize(double width) {
    if (width < 360) return ScreenSize.small;
    if (width < 600) return ScreenSize.medium;
    if (width < 840) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
}

class LayoutInfo {
  final double width;
  final double height;
  final Orientation orientation;
  final DeviceType deviceType;
  final ScreenSize screenSize;
  
  LayoutInfo({
    required this.width,
    required this.height,
    required this.orientation,
    required this.deviceType,
    required this.screenSize,
  });
  
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
}

enum DeviceType { mobile, tablet, desktop }
enum ScreenSize { small, medium, large, extraLarge }
```

### 6.4 平台特定的间距和字体

```dart
class PlatformSpacing {
  // 根据平台调整间距
  static double get padding {
    if (Platform.isIOS) return 16.0;
    if (Platform.isAndroid) return 16.0;
    return 24.0; // 桌面平台更大
  }
  
  static double get miniPadding {
    if (Platform.isIOS) return 8.0;
    if (Platform.isAndroid) return 8.0;
    return 12.0;
  }
}

class PlatformTypography {
  // 平台特定的字体大小
  static double get titleFontSize {
    if (Platform.isIOS) return 20.0;
    if (Platform.isAndroid) return 22.0;
    return 24.0; // 桌面平台
  }
  
  static double get bodyFontSize {
    if (Platform.isIOS) return 14.0;
    if (Platform.isAndroid) return 16.0;
    return 18.0; // 桌面平台
  }
}
```

---

## 🔄 七、横屏适配规范

### 7.1 横屏检测

```dart
class OrientationManager extends StatelessWidget {
  final Widget portraitBuilder;
  final Widget landscapeBuilder;
  
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    return orientation == Orientation.portrait
      ? portraitBuilder
      : landscapeBuilder;
  }
}
```

### 7.2 横屏布局策略

#### 网格布局调整
```dart
class AdaptiveDashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.portrait ? 2 : 4;
    final childAspectRatio = orientation == Orientation.portrait ? 1.2 : 1.5;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => StatCard(index: index),
    );
  }
}
```

#### 侧边栏布局
```dart
class SplitView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    if (orientation == Orientation.landscape) {
      // 横屏：左右分栏
      return Row(
        children: [
          // 左侧导航/列表
          Expanded(
            flex: 1,
            child: NavigationPanel(),
          ),
          // 分隔线
          VerticalDivider(width: 1),
          // 右侧内容
          Expanded(
            flex: 2,
            child: ContentPanel(),
          ),
        ],
      );
    } else {
      // 竖屏：上下布局
      return Column(
        children: [
          // 顶部导航
          NavigationPanel(),
          // 分隔线
          Divider(),
          // 主要内容
          Expanded(
            child: ContentPanel(),
          ),
        ],
      );
    }
  }
}
```

### 7.3 横屏状态管理

```dart
class LandscapeState {
  final bool isLandscape;
  final double availableWidth;
  final double availableHeight;
  
  LandscapeState({
    required this.isLandscape,
    required this.availableWidth,
    required this.availableHeight,
  });
  
  // 横屏时的组件尺寸调整
  double get adjustedCardHeight {
    return isLandscape ? availableHeight * 0.3 : availableHeight * 0.2;
  }
  
  double get adjustedFontSize {
    return isLandscape ? 18.0 : 16.0;
  }
  
  double get adjustedIconSize {
    return isLandscape ? 32.0 : 24.0;
  }
}
```

### 7.4 横屏动画调整

```dart
class OrientationAwareAnimation extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final duration = orientation == Orientation.landscape 
      ? Duration(milliseconds: 200)  // 横屏更快
      : Duration(milliseconds: 350); // 竖屏更慢
    
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOut,
      child: child,
    );
  }
}
```

---

## 🛠️ 八、实现示例

### 8.1 完整的主题系统实现

```dart
// theme_service.dart
class ThemeService {
  static const String _themeKey = 'app_theme_mode';
  
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }
  
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeKey);
    
    if (modeString == null) {
      return ThemeMode.system; // 默认跟随系统
    }
    
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => ThemeMode.system,
    );
  }
}

// theme_provider.dart
@Riverpod()
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<ThemeMode> build() async {
    // 监听系统主题变化
    final systemMode = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    // 加载用户保存的主题
    final savedMode = await ThemeService().loadThemeMode();
    
    return savedMode;
  }
  
  Future<void> toggleTheme() async {
    final current = state.value ?? ThemeMode.system;
    final newMode = current == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
    
    state = AsyncValue.data(newMode);
    await ThemeService().saveThemeMode(newMode);
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    await ThemeService().saveThemeMode(mode);
  }
  
  // 获取当前主题数据
  ThemeData getThemeData(BuildContext context) {
    final mode = state.value ?? ThemeMode.system;
    
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }
}

// theme_switcher.dart
class ThemeSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider).value ?? ThemeMode.system;
    
    return PopupMenuButton<ThemeMode>(
      icon: Icon(_getIcon(themeMode)),
      onSelected: (mode) => ref.read(themeNotifierProvider.notifier).setTheme(mode),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            leading: Icon(Icons.system_update),
            title: Text('跟随系统'),
            trailing: themeMode == ThemeMode.system ? Icon(Icons.check) : null,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            leading: Icon(Icons.light_mode),
            title: Text('浅色主题'),
            trailing: themeMode == ThemeMode.light ? Icon(Icons.check) : null,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('深色主题'),
            trailing: themeMode == ThemeMode.dark ? Icon(Icons.check) : null,
          ),
        ),
      ],
    );
  }
  
  IconData _getIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.system_update;
    }
  }
}

// main.dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    
    return themeMode.when(
      data: (mode) {
        return MaterialApp(
          title: 'AHP Dashboard',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: HomePage(),
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}
```

### 8.2 响应式组件示例

```dart
// adaptive_card.dart
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  
  const AdaptiveCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    
    return ResponsiveBuilder(
      builder: (context, layout) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(layout.isLandscape ? 8 : 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(layout.isLandscape ? 8 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: layout.isLandscape ? 2 : 4,
                offset: Offset(0, layout.isLandscape ? 1 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(layout.isLandscape ? 8 : 12),
              child: Padding(
                padding: padding ?? EdgeInsets.all(layout.isLandscape ? 12 : 16),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// platform_aware_icon.dart
class PlatformAwareIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // iOS 风格图标
      return Icon(
        icon,
        size: size ?? 24,
        color: color ?? Theme.of(context).iconTheme.color,
      );
    } else {
      // Android/Web/Desktop 风格图标
      return Icon(
        icon,
        size: size ?? 24,
        color: color ?? Theme.of(context).iconTheme.color,
      );
    }
  }
}
```

---

## 📋 九、代码组织规范

### 9.1 目录结构

```
lib/
├── core/                           # 核心配置
│   ├── constants/                  # 常量
│   ├── theme/                      # 主题系统
│   ├── utils/                      # 工具函数
│   └── config/                     # 配置
│
├── data/                           # 数据层
│   ├── models/                     # 数据模型
│   ├── repositories/               # 仓库
│   └── datasources/                # 数据源
│
├── domain/                         # 领域层
│   ├── entities/                   # 实体
│   ├── repositories/               # 仓库接口
│   └── usecases/                   # 用例
│
├── presentation/                   # 表现层
│   ├── widgets/                    # 组件
│   │   ├── atoms/                  # 原子组件
│   │   ├── molecules/              # 分子组件
│   │   ├── organisms/              # 有机体组件
│   │   └── templates/              # 模板
│   ├── pages/                      # 页面
│   ├── theme/                      # 主题配置
│   └── providers/                  # 状态提供者
│
└── main.dart                       # 应用入口
```

### 9.2 导入规范

```dart
// 标准导入顺序
import 'dart:ui';                    // 1. Dart 核心库
import 'package:flutter/material.dart'; // 2. Flutter 框架
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 3. 外部包
import 'package:ahp_dashboard/core/theme/app_colors.dart'; // 4. 项目内部
import 'package:ahp_dashboard/presentation/widgets/atoms/button.dart'; // 5. 组件
```

---

## ✅ 十、检查清单

### 设计规范验证
- [ ] 主题系统支持深色/浅色模式
- [ ] 主题设置能被本地保存
- [ ] 系统主题变化能被实时检测
- [ ] 页面遵循 Material Design 3 规范
- [ ] 动画流畅且有意义
- [ ] 配色方案符合科技、扁平、速度、互联理念
- [ ] 组件职责单一，代码不过长
- [ ] 组件可复用且易于维护
- [ ] 支持 Android、iOS、Linux 平台
- [ ] 横屏布局合理且美观
- [ ] 响应式布局适配不同屏幕尺寸

### 代码质量检查
- [ ] 组件代码行数 < 200 行
- [ ] 使用命名参数提高可读性
- [ ] 避免魔法数字和字符串
- [ ] 正确使用 const 和 final
- [ ] 遵循 DRY 原则（不要重复代码）
- [ ] 适当的错误处理
- [ ] 完整的文档注释

---

**文档版本**: v1.0  
**创建日期**: 2026-01-06  
**最后更新**: 2026-01-06