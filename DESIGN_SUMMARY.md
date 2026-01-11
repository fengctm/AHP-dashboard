# AHP Dashboard 设计规范摘要

## 🎨 主题设计

### 核心要求
- ✅ 支持深色/浅色主题
- ✅ 默认跟随系统主题
- ✅ 可手动切换主题
- ✅ 记住用户选择的主题

### 实现要点
```dart
// 主题切换逻辑
ThemeMode.system → 自动跟随
ThemeMode.light → 强制浅色
ThemeMode.dark  → 强制深色

// 本地存储
SharedPreferences 保存用户选择
```

---

## 📱 页面设计

### 设计原则
- **Material Design 3** 规范
- **卡片式布局**，视觉层次清晰
- **充足留白**，避免拥挤
- **一致性**，保持统一风格

### 布局策略
```dart
// 竖屏：上下结构
Column(
  NavigationBar,
  Expanded(Content),
)

// 横屏：左右结构  
Row(
  Expanded(Navigation),
  VerticalDivider,
  Expanded(Content),
)
```

---

## ✨ 动画设计

### 苹果风格理念
- **自然**: 符合物理直觉
- **有意义**: 传达信息
- **流畅**: 60fps 无卡顿
- **克制**: 避免过度动画

### 常用动画曲线
```dart
// 标准动画
Curves.easeInOutCubic

// 弹性效果
Curves.elasticOut

// 快速进入，缓慢退出
Curves.easeInCubic

// 缓慢进入，快速退出
Curves.easeOutCubic
```

### 动画时长
- **微交互**: 100-150ms
- **状态变化**: 200-250ms
- **页面切换**: 300-350ms
- **列表进入**: 300ms + index * 50ms

---

## 🎨 配色方案

### 核心概念
- **科技感**: 现代、未来感
- **扁平化**: 简洁、无渐变
- **速度感**: 动态、活力
- **互联性**: 连接、网络

### 主要颜色
```dart
// 主色调 - 科技蓝
primary: #2196F3

// 次要色 - 活力橙  
secondary: #FF9800

// 强调色 - 速度绿
accent: #4CAF50

// 语义化颜色
success: #4CAF50
warning: #FFC107
error: #F44336
speed: #00BCD4      // 速度显示
power: #FF9800      // 功率显示
battery: #4CAF50    // 电量显示
temperature: #F44336 // 温度显示
```

### 浅色主题
```dart
background: #F5F5F5
surface: #FFFFFF
onSurface: #212121
divider: #E0E0E0
```

### 深色主题
```dart
background: #121212
surface: #1E1E1E
onSurface: #E0E0E0
divider: #333333
```

---

## 🧩 组件化开发

### 单一职责原则
每个组件只负责一个明确功能，避免"上帝组件"。

### 组件层次
```
原子组件 (Atoms)     → Button, Icon, Text
分子组件 (Molecules)  → StatCard, DeviceItem
有机体 (Organisms)   → DashboardGrid, ControlPanel
模板 (Templates)     → DashboardPage
```

### 拆分标准
- **代码行数**: 超过 200 行考虑拆分
- **功能复杂度**: 超过 3 个职责考虑拆分
- **复用需求**: 可能被复用的代码独立出来

### 参数规范
```dart
// 使用命名参数
MyWidget({
  required this.title,
  this.color = Colors.blue,
  this.onTap,
}) : super(key: key);
```

---

## 📱 多端适配

### 平台检测
```dart
Platform.isAndroid    // Android
Platform.isIOS        // iOS  
Platform.isLinux      // Linux
Platform.isWindows    // Windows
Platform.isMacOS      // macOS
```

### 平台特定 UI
```dart
// iOS 使用 Cupertino
if (Platform.isIOS) {
  return CupertinoButton(...);
}

// Android 使用 Material
return ElevatedButton(...);
```

### 响应式断点
```dart
// 屏幕宽度分类
< 600px   → Mobile
600-1200 → Tablet
> 1200px  → Desktop
```

---

## 🔄 横屏适配

### 检测方法
```dart
final orientation = MediaQuery.of(context).orientation;
bool isLandscape = orientation == Orientation.landscape;
```

### 布局调整
```dart
// 网格列数
portrait: 2列
landscape: 4列

// 卡片比例
portrait: 1.2
landscape: 1.5

// 字体大小
portrait: 16px
landscape: 18px
```

### 分栏布局
```dart
// 横屏：左右分栏
Row(
  Expanded(flex: 1, child: NavigationPanel()),
  VerticalDivider(),
  Expanded(flex: 2, child: ContentPanel()),
)

// 竖屏：上下布局
Column(
  NavigationPanel(),
  Divider(),
  Expanded(child: ContentPanel()),
)
```

---

## 🎯 快速参考

### 主题切换
```dart
// 在页面中使用主题
final brightness = Theme.of(context).brightness;
final isDark = brightness == Brightness.dark;

// 切换主题
ref.read(themeNotifierProvider.notifier).toggleTheme();
```

### 组件创建模板
```dart
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // 响应式设计
      padding: EdgeInsets.all(PlatformSpacing.padding),
      // 平台特定样式
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
```

### 横屏适配模板
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    return orientation == Orientation.portrait
      ? PortraitLayout()
      : LandscapeLayout();
  }
}
```

---

**版本**: v1.0  
**更新**: 2026-01-06