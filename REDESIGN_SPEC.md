# AHP Dashboard 界面重新设计规格说明书

## 文档信息
- **创建日期**: 2026年1月11日
- **版本**: 1.0.0
- **状态**: 规划中
- **优先级**: 高

---

## 📋 需求概览

### 设计目标
重新设计整个仪表盘界面，增加科技感，优化信息架构，提升用户体验。

---

## 🎯 核心需求

### 1. 整体布局架构
**状态**: ⌛ 待开始

**需求描述**:
- 界面分为上下两个主要区域
- 上部：完整仪表盘区域（速度显示 + 信息区域）
- 下部：详细信息区域（多模块信息展示）

**技术要点**:
- 响应式布局，支持横竖屏
- 科技感视觉设计
- 流畅的动画过渡

---

### 2. 仪表盘区域设计
**状态**: ⌛ 待开始

**需求描述**:
分为两个子区域：
- **速度区域**: 大数字显示当前时速
- **信息区域**: 紧凑的状态信息

**功能要求**:
- [ ] 速度数字显示（大字体，醒目）
- [ ] 单位切换功能（km/h ↔ mph）
- [ ] 故障灯系统集成
- [ ] 实时数据更新动画

**视觉设计**:
- 科技感配色方案
- 深色背景为主
- 霓虹/发光效果
- 网格线或仪表盘纹理

---

### 3. 速度显示系统
**状态**: ⌛ 待开始

**需求描述**:
- 纯数字速度显示
- 支持公里/英里制切换
- 故障灯内嵌在速度区域

**功能规格**:
```dart
// 数据模型
class SpeedDisplayData {
  double speed;              // 当前速度值
  String unit;               // 'km/h' 或 'mph'
  bool showFaultLights;     // 是否显示故障灯
  List<FaultLight> faults;  // 故障灯列表
}

// 故障灯类型
enum FaultType {
  gpsSignal,      // GPS信号故障
  batteryLow,     // 电量过低
  temperature,    // 温度异常
  connection,     // 连接异常
  controller,     // 控制器故障
  bms,            // BMS故障
}
```

**故障灯显示逻辑**:
- **GPS信号故障灯**:
  - 信号良好: 隐藏或绿色
  - 信号弱 (1-2格): 警告色 (黄色/橙色)
  - 无信号: 错误色 (红色)
  - 信号质量数据: 0-100% 或 0-5格

**数据交换预留**:
```dart
// 状态管理结构
final speedDisplayProvider = StateProvider<SpeedDisplayData>((ref) {
  return SpeedDisplayData(
    speed: 0.0,
    unit: 'km/h',
    showFaultLights: true,
    faults: [],
  );
});

// GPS信号质量监控
final gpsSignalProvider = StateProvider<int>((ref) => 100); // 0-100
```

---

### 4. 信息区域设计（仪表盘下部）
**状态**: ⌛ 待开始

**需求描述**:
显示大量零散信息，需要选择合适的展示方式。

**信息分类**:
1. **控制器信息**
   - 电机温度
   - 控制器温度
   - 输出功率
   - 工作状态

2. **BMS信息**
   - 电池电量百分比
   - 电池电压
   - 电池电流
   - 充电状态
   - 电池温度
   - 健康状态 (SOH)

3. **行程信息**
   - 当前里程
   - 本次行程距离
   - 平均速度
   - 平均能耗
   - 最高速度

4. **拓展功能区**
   - 地图信息（未来）
   - 媒体播放信息（未来）

**展示方案选择**:

#### 方案A: 标签页/分页系统
- **优点**: 信息分类清晰，不拥挤
- **缺点**: 需要切换查看，不够直观

#### 方案B: 滚动卡片列表
- **优点**: 所有信息可见，易于扩展
- **缺点**: 可能过长，需要滚动

#### 方案C: 网格布局 + 可折叠面板
- **优点**: 空间利用率高，可分组折叠
- **缺点**: 实现复杂度较高

#### 方案D: 侧边栏 + 主内容区（横屏优化）
- **优点**: 横屏体验好，信息层次清晰
- **缺点**: 竖屏需要适配

**推荐方案**: **方案C + 方案B的混合**
- 使用可折叠的分组卡片
- 默认展开关键信息组
- 其他信息可折叠或隐藏
- 支持横向滑动切换视图

**布局结构**:
```
┌─────────────────────────────┐
│ 信息区域标题栏              │
├─────────────────────────────┤
│ [控制器] ▼  [展开/收起]     │
│ 电机温度: 42°C              │
│ 输出功率: 3.2 kW            │
├─────────────────────────────┤
│ [BMS] ▼  [展开/收起]        │
│ 电量: 85%  电压: 54.6V      │
│ 电流: -2.3A  温度: 28°C     │
├─────────────────────────────┤
│ [行程] ▼  [展开/收起]       │
│ 里程: 1250.5 km             │
│ 本次: 45.2 km  均速: 32 km/h│
├─────────────────────────────┤
│ [拓展] 地图/媒体 (占位)     │
└─────────────────────────────┘
```

---

### 5. 数据交换与状态管理
**状态**: ⌛ 待开始

**需求描述**:
为故障灯和各模块预留数据交换手段。

**状态管理架构**:
```dart
// 主仪表盘状态
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final SpeedData speed;
  final GPSSignalData gps;
  final BatteryData battery;
  final ControllerData controller;
  final BMSData bms;
  final TripData trip;
  final List<FaultLight> activeFaults;
  final ThemeMode themeMode; // 主题模式
  final bool isLandscape;    // 横屏状态

  DashboardState({
    required this.speed,
    required this.gps,
    required this.battery,
    required this.controller,
    required this.bms,
    required this.trip,
    required this.activeFaults,
    required this.themeMode,
    required this.isLandscape,
  });
}

// GPS信号数据
class GPSSignalData {
  final int signalStrength; // 0-100
  final bool hasFix;
  final int satelliteCount;

  GPSSignalData({
    required this.signalStrength,
    required this.hasFix,
    required this.satelliteCount,
  });

  // 计算故障等级
  FaultLevel get faultLevel {
    if (!hasFix || signalStrength < 10) return FaultLevel.error;
    if (signalStrength < 50) return FaultLevel.warning;
    return FaultLevel.normal;
  }
}

// 故障灯数据结构
class FaultLight {
  final FaultType type;
  final FaultLevel level;
  final String message;
  final DateTime timestamp;

  FaultLight({
    required this.type,
    required this.level,
    required this.message,
    required this.timestamp,
  });
}

enum FaultLevel {
  normal,    // 正常（隐藏）
  warning,   // 警告（黄色/橙色）
  error,     // 错误（红色）
}
```

**数据流设计**:
```
蓝牙设备数据 → 数据解析器 → 状态管理 → UI组件
     ↓              ↓            ↓         ↓
  原始数据      标准化数据    Riverpod   响应式更新
```

**主题与布局状态集成**:
- 利用现有 `themeNotifierProvider` 管理深浅色主题
- 监听 `MediaQuery.orientation` 变化，自动更新横屏状态
- 状态变化时触发UI重绘，确保主题和布局同步更新

---

## 📊 信息区域详细内容规划

### 5.1 控制器信息组
**状态**: ⌛ 待开始

- 电机温度 (Motor Temp)
- 控制器温度 (Controller Temp)
- 输出功率 (Output Power)
- 工作模式 (Eco/Sport/Normal)
- 故障代码 (如果有)

### 5.2 BMS信息组
**状态**: ⌛ 待开始

- 电池电量 (SOC - State of Charge)
- 电池电压 (Voltage)
- 电池电流 (Current)
- 充电状态 (Charging Status)
- 电池温度 (Battery Temp)
- 健康状态 (SOH - State of Health)
- 循环次数 (Cycle Count)

### 5.3 行程信息组
**状态**: ⌛ 待开始

- 总里程 (Total Odometer)
- 本次行程 (Trip Distance)
- 平均速度 (Average Speed)
- 最高速度 (Max Speed)
- 平均能耗 (Avg Energy Consumption)
- 骑行时间 (Riding Time)

### 5.4 拓展功能区
**状态**: ⌛ 待开始

- **地图模块** (未来)
  - 当前位置
  - 轨迹记录
  - 导航信息
  
- **媒体控制** (未来)
  - 当前播放歌曲
  - 播放/暂停控制
  - 音量调节

---

## 🎨 视觉设计规范

### 配色方案 (科技感)
**状态**: ⌛ 待开始

**深色主题 (Dark Mode)**:
- 主背景: `#0A0E1A` (极深蓝黑)
- 卡片背景: `#151922` (深蓝灰)
- 强调色: `#00D9FF` (霓虹青)
- 次要强调: `#FF6B35` (活力橙)
- 文字: `#E0E0E0` (浅灰白)
- 辅助文字: `#9E9E9E` (中灰)

**浅色主题 (Light Mode)**:
- 主背景: `#F5F5F5` (浅灰)
- 卡片背景: `#FFFFFF` (纯白)
- 强调色: `#2196F3` (科技蓝)
- 次要强调: `#FF9800` (橙色)
- 文字: `#212121` (深灰黑)
- 辅助文字: `#757575` (中灰)

**状态色 (双主题适配)**:
- 正常:
  - 深色: `#00FF88` (荧光绿)
  - 浅色: `#4CAF50` (标准绿)
- 警告:
  - 深色: `#FFB800` (琥珀黄)
  - 浅色: `#FFC107` (标准黄)
- 错误:
  - 深色: `#FF3366` (霓虹红)
  - 浅色: `#F44336` (标准红)

**速度显示配色**:
- 深色: `#00D9FF` (霓虹青) + 发光效果
- 浅色: `#00BCD4` (青色) + 阴影效果

### 字体规范
**状态**: ⌛ 待开始

- **速度数字**:
  - 竖屏: 80-100px, 粗体
  - 横屏: 120-160px, 粗体
  - 深色: 发光/辉光效果
  - 浅色: 粗体+阴影
- **标签**: 14-16px, 中等粗细
- **数值**: 18-24px, 粗体
- **故障灯文字**: 12-14px, 紧凑显示

### 动画效果
**状态**: ⌛ 待开始

- **速度变化**: 数字滚动动画 (0.3s)
- **故障灯**:
  - 警告: 呼吸动画 (1.5s周期)
  - 错误: 闪烁动画 (0.5s周期)
- **卡片展开**: 滑动动画 (0.3s)
- **数据更新**: 渐变过渡 (0.2s)
- **主题切换**: 平滑颜色过渡 (0.5s)

### 深浅色主题适配策略
**状态**: ⌛ 待开始

**现有基础设施**:
- ✅ 已有完整的 `lightTheme` 和 `darkTheme` 配置
- ✅ 已有 `ThemeNotifier` 状态管理
- ✅ 已有 `ThemeSwitcher` UI组件
- ✅ 已有 `AppColors` 和 `SemanticColors` 颜色系统

**新组件适配要求**:
1. **使用主题颜色**: 所有新组件必须使用 `Theme.of(context).colorScheme` 或自定义的 `AppColors`
2. **避免硬编码颜色**: 不直接使用 `Colors.white` 等，应使用主题感知颜色
3. **动态配色**: 故障灯、状态指示器等需要根据主题调整颜色
4. **测试验证**: 必须在深浅色两种主题下测试视觉效果

**主题感知颜色映射**:
```dart
// 示例：故障灯颜色适配
Color getFaultColor(FaultLevel level, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  switch (level) {
    case FaultLevel.normal:
      return isDark ? AppColors.success : AppColors.success;
    case FaultLevel.warning:
      return isDark ? const Color(0xFFB800) : AppColors.warning;
    case FaultLevel.error:
      return isDark ? const Color(0xFF3366) : AppColors.error;
  }
}
```

### 横屏适配策略
**状态**: ⌛ 待开始

**现有基础设施**:
- ✅ 已有 `ResponsiveBuilder` 组件
- ✅ 已有 `LayoutInfo` 布局信息类
- ✅ 已有 `Orientation` 检测逻辑
- ✅ 现有组件已支持横竖屏适配

**新设计横屏布局**:

**竖屏模式 (Portrait)**:
```
┌─────────────────────────────┐
│ AppBar + 状态指示器         │
├─────────────────────────────┤
│                             │
│    [速度区域 - 大数字]      │
│    故障灯指示器             │
│                             │
├─────────────────────────────┤
│ 信息区域 (可滚动)           │
│ ┌─────────────────────────┐ │
│ │ [控制器] 展开/收起      │ │
│ │ 详细信息                │ │
│ ├─────────────────────────┤ │
│ │ [BMS] 展开/收起         │ │
│ │ 详细信息                │ │
│ ├─────────────────────────┤ │
│ │ [行程] 展开/收起        │ │
│ │ 详细信息                │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**横屏模式 (Landscape)**:
```
┌─────────────────────────────────────────────┐
│ AppBar + 状态指示器                         │
├──────────────────────┬──────────────────────┤
│                      │                      │
│   速度区域           │   信息概览           │
│   (超大数字)         │   - 关键指标         │
│                      │   - 故障灯           │
│                      │                      │
│                      ├──────────────────────┤
│                      │ 详细信息区域         │
│                      │ - 分组卡片           │
│                      │ - 横向滑动/网格      │
│                      │                      │
└──────────────────────┴──────────────────────┘
```

**横屏优化要点**:
1. **速度区域**: 字体更大，占据左侧 40% 宽度
2. **信息区域**: 右侧分栏显示，支持横向滑动切换
3. **故障灯**: 集成在速度区域下方或信息区域顶部
4. **卡片布局**: 网格列数增加 (2列 → 3-4列)
5. **间距调整**: 适当缩小间距，提高信息密度

**响应式断点**:
- **竖屏**: 任意宽度，速度数字 80-100px
- **横屏移动**: 宽度 ≥ 600px，速度数字 120-140px
- **横屏平板**: 宽度 ≥ 900px，速度数字 140-160px
- **横屏桌面**: 宽度 ≥ 1200px，速度数字 160px+

**组件适配示例**:
```dart
// 速度显示组件的响应式设计
Widget buildSpeedDisplay(BuildContext context) {
  final orientation = MediaQuery.of(context).orientation;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final fontSize = orientation == Orientation.landscape ? 140.0 : 90.0;
  final glowColor = isDark ? Colors.cyan : Colors.blue;

  return Text(
    speedValue,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: glowColor,
      shadows: isDark ? [
        Shadow(
          color: glowColor.withValues(alpha: 0.8),
          blurRadius: 20,
        ),
      ] : [
        Shadow(
          color: Colors.black.withValues(alpha: 0.3),
          offset: Offset(2, 2),
          blurRadius: 4,
        ),
      ],
    ),
  );
}
```

---

## 📱 响应式设计

### 核心设计原则
**状态**: ⌛ 待开始

1. **主题自适应**: 自动适配深浅色主题
2. **方向自适应**: 横竖屏布局优化
3. **尺寸自适应**: 不同屏幕尺寸的适配
4. **状态同步**: 主题切换时的平滑过渡

### 竖屏模式 (Portrait) - 移动端
```
┌─────────────────────────────────┐
│ AHP Dashboard      [主题] [连接] │
├─────────────────────────────────┤
│                                   │
│      85 km/h                     │
│      [速度区域 - 超大数字]       │
│                                   │
│   [故障灯] GPS信号弱             │
│                                   │
├─────────────────────────────────┤
│ 信息区域 (可滚动)                │
│ ┌─────────────────────────────┐ │
│ │ ▼ 控制器信息                │ │
│ │ 电机: 42°C  功率: 3.2kW     │ │
│ ├─────────────────────────────┤ │
│ │ ▼ BMS信息                   │ │
│ │ 电量: 85%  电压: 54.6V      │ │
│ │ 电流: -2.3A  温度: 28°C     │ │
│ ├─────────────────────────────┤ │
│ │ ▼ 行程信息                  │ │
│ │ 里程: 1250.5km  本次: 45km  │ │
│ │ 均速: 32km/h  能耗: 5.2     │ │
│ ├─────────────────────────────┤ │
│ │ [拓展] 地图/媒体 (占位)      │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### 横屏模式 (Landscape) - 移动端/平板
```
┌─────────────────────────────────────────────┐
│ AHP Dashboard      [主题] [连接]             │
├──────────────────────┬──────────────────────┤
│                      │                      │
│                      │   关键信息概览       │
│                      │   电量: 85%          │
│      120 km/h        │   温度: 42°C         │
│      [超大数字]      │   里程: 1250km       │
│                      │                      │
│   [故障灯]           ├──────────────────────┤
│   GPS信号弱          │  详细信息区域        │
│                      │  ┌────┐┌────┐┌────┐ │
│                      │  │控制器││BMS ││行程│ │
│                      │  │信息 ││信息 ││信息 │ │
│                      │  └────┘└────┘└────┘ │
│                      │                      │
└──────────────────────┴──────────────────────┘
```

### 横屏模式 (Landscape) - 大屏设备
```
┌──────────────────────────────────────────────────────┐
│ AHP Dashboard      [主题] [连接] [刷新] [设置]        │
├───────────────────┬──────────────────────────────────┤
│                   │                                  │
│                   │   速度: 120 km/h                 │
│                   │   功率: 3.2 kW   温度: 42°C      │
│    120 km/h       │   电量: 85%      里程: 1250km    │
│    [超大数字]     │                                  │
│                   │   [故障灯] GPS信号弱             │
│                   │                                  │
│   快速操作        ├──────────────────────────────────┤
│   ┌─────────┐     │  详细信息网格 (4列)              │
│   │ 扫描设备│     │  ┌────┬────┬────┬────┐          │
│   │ 同步数据│     │  │控制器│BMS │行程 │地图 │      │
│   └─────────┘     │  ├────┼────┼────┼────┤          │
│   ┌─────────┐     │  │信息 │信息 │信息 │占位 │      │
│   │ 导出数据│     │  └────┴────┴────┴────┘          │
│   └─────────┘     │                                  │
│                   │                                  │
└───────────────────┴──────────────────────────────────┘
```

### 主题切换适配
**状态**: ⌛ 待开始

**切换流程**:
1. 用户点击主题切换按钮
2. `ThemeNotifier` 更新状态并保存到本地
3. 所有使用 `Theme.of(context)` 的组件自动重绘
4. 颜色、阴影、发光效果平滑过渡

**视觉变化**:
- **深色 → 浅色**:
  - 背景从深蓝黑 → 浅灰
  - 速度数字从霓虹青 → 科技蓝
  - 发光效果 → 阴影效果
  - 卡片从深灰 → 纯白

- **浅色 → 深色**:
  - 背景从浅灰 → 深蓝黑
  - 速度数字从科技蓝 → 霓虹青
  - 阴影效果 → 发光效果
  - 卡片从纯白 → 深灰

### 横竖屏切换适配
**状态**: ⌛ 待开始

**切换流程**:
1. 设备方向改变触发 `MediaQuery` 更新
2. `ResponsiveBuilder` 检测新布局
3. 组件根据新方向重新渲染
4. 字体大小、间距、布局自动调整

**布局变化**:
- **竖屏 → 横屏**:
  - 速度数字增大 (90px → 140px)
  - 信息区域分栏
  - 卡片网格列数增加
  - 间距适当缩小

- **横屏 → 竖屏**:
  - 速度数字减小 (140px → 90px)
  - 信息区域合并
  - 卡片网格列数减少
  - 间距适当增大

### 响应式组件设计
**状态**: ⌛ 待开始

**速度显示组件**:
```dart
class ResponsiveSpeedDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    // 字体大小计算
    double fontSize;
    if (orientation == Orientation.landscape) {
      if (width >= 1200) fontSize = 160;
      else if (width >= 900) fontSize = 140;
      else fontSize = 120;
    } else {
      fontSize = width >= 600 ? 100 : 85;
    }

    // 颜色和效果
    final textColor = isDark ? const Color(0xFF00D9FF) : const Color(0xFF00BCD4);
    final shadows = isDark
      ? [Shadow(color: textColor.withValues(alpha: 0.8), blurRadius: 20)]
      : [Shadow(color: Colors.black.withValues(alpha: 0.3), offset: Offset(2, 2), blurRadius: 4)];

    return Text(
      speedValue,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
        shadows: shadows,
      ),
    );
  }
}
```

**故障灯组件**:
```dart
class ResponsiveFaultLights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 布局调整
    final direction = orientation == Orientation.portrait
      ? Axis.vertical
      : Axis.horizontal;

    final spacing = orientation == Orientation.portrait ? 8.0 : 16.0;

    return Flex(
      direction: direction,
      children: activeFaults.map((fault) {
        return _buildFaultLight(fault, isDark, spacing);
      }).toList(),
    );
  }
}
```

**信息区域组件**:
```dart
class ResponsiveInfoArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final width = MediaQuery.of(context).size.width;

    if (orientation == Orientation.landscape && width >= 900) {
      // 横屏大屏：网格布局
      return GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: infoGroups,
      );
    } else if (orientation == Orientation.landscape) {
      // 横屏中屏：2列网格
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: infoGroups,
      );
    } else {
      // 竖屏：可折叠列表
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: infoGroups.length,
        itemBuilder: (context, index) => ExpandableInfoGroup(
          group: infoGroups[index],
        ),
      );
    }
  }
}
```

### 测试要点
**状态**: ⌛ 待开始

- [ ] 深色主题下所有文字清晰可读
- [ ] 浅色主题下所有文字清晰可读
- [ ] 横屏切换时布局平滑过渡
- [ ] 不同屏幕尺寸下组件不溢出
- [ ] 故障灯在不同主题下颜色正确
- [ ] 速度数字在不同方向下大小合适
- [ ] 信息区域在横屏下充分利用空间
- [ ] 触摸交互在所有方向下正常工作

---

## 🔧 技术实现规划

### 组件层级
```
DashboardPage (主页面)
├── SpeedDashboard (上部仪表盘)
│   ├── SpeedDisplay (速度显示)
│   ├── FaultLights (故障灯系统)
│   └── QuickInfo (紧凑信息)
└── InfoArea (下部信息区)
    ├── ExpandableGroup (可折叠组)
    ├── StatGrid (统计网格)
    └── FutureModules (拓展模块占位)
```

### 数据流
```
硬件设备 → 蓝牙连接 → 数据解析 → Riverpod状态 → UI响应式更新
```

---

## 📝 开发任务清单

### 阶段1: 基础架构
- [ ] 创建新的页面结构
- [ ] 设计状态管理架构
- [ ] 实现数据模型
- [ ] 搭建基础UI组件
- [ ] **主题适配基础**: 确保所有新组件支持深浅色主题
- [ ] **响应式基础**: 集成现有 ResponsiveBuilder

### 阶段2: 仪表盘区域 (速度显示)
- [ ] 速度显示组件 (支持数字显示)
- [ ] 单位切换逻辑 (km/h ↔ mph)
- [ ] 故障灯系统 (GPS信号监控)
- [ ] GPS信号质量检测与映射
- [ ] **主题适配**: 速度数字发光/阴影效果
- [ ] **横屏适配**: 速度区域大小调整

### 阶段3: 信息区域 (详细信息)
- [ ] 可折叠分组组件 (ExpandableGroup)
- [ ] 控制器信息展示 (电机温度、功率等)
- [ ] BMS信息展示 (电量、电压、电流等)
- [ ] 行程信息展示 (里程、均速、能耗等)
- [ ] 拓展模块占位 (地图、媒体)
- [ ] **主题适配**: 卡片颜色、文字颜色
- [ ] **横屏适配**: 网格布局、分栏显示

### 阶段4: 视觉优化与主题系统
- [ ] 科技感配色方案 (深浅色两套)
- [ ] 动画效果实现 (速度变化、故障灯、卡片展开)
- [ ] **主题切换动画**: 平滑颜色过渡
- [ ] **故障灯主题适配**: 动态颜色映射
- [ ] **字体规范**: 不同方向下的字体大小
- [ ] **阴影/发光效果**: 根据主题切换

### 阶段5: 响应式布局优化
- [ ] **竖屏布局**: 上下分屏，可滚动信息区
- [ ] **横屏布局**: 左右分栏，网格信息区
- [ ] **断点适配**: 移动、平板、桌面优化
- [ ] **组件响应式**: 速度、故障灯、信息区
- [ ] **间距自适应**: 根据方向和尺寸调整

### 阶段6: 数据集成与状态管理
- [ ] 蓝牙数据接入
- [ ] 状态管理集成 (DashboardState)
- [ ] 故障灯逻辑实现 (GPS信号映射)
- [ ] 实时数据更新
- [ ] **主题状态集成**: 与现有 themeNotifier 联动
- [ ] **布局状态集成**: 监听 orientation 变化

### 阶段7: 测试与优化
- [ ] **主题测试**: 深浅色切换测试
- [ ] **方向测试**: 横竖屏切换测试
- [ ] **功能测试**: 所有交互功能
- [ ] **性能优化**: 动画流畅度
- [ ] **用户体验测试**: 视觉一致性
- [ ] **Bug修复**: 跨平台兼容性

---

## 📅 进度追踪

| 需求模块 | 状态 | 完成度 | 备注 |
|---------|------|--------|------|
| 整体布局架构 | ⌛ 待开始 | 0% | 上下分屏设计 |
| 仪表盘区域 | ⌛ 待开始 | 0% | 速度+故障灯 |
| 速度显示系统 | ⌛ 待开始 | 0% | 数字+单位切换 |
| 故障灯系统 | ⌛ 待开始 | 0% | GPS信号监控 |
| 信息区域设计 | ⌛ 待开始 | 0% | 多模块分组 |
| 数据交换架构 | ⌛ 待开始 | 0% | 状态管理预留 |
| **深浅色主题适配** | ⌛ 待开始 | 0% | **新增需求** |
| **横屏布局适配** | ⌛ 待开始 | 0% | **新增需求** |
| 视觉设计规范 | ⌛ 待开始 | 0% | 科技感配色 |
| 响应式设计 | ⌛ 待开始 | 0% | 方向/尺寸适配 |
| 技术实现 | ⌛ 待开始 | 0% | 编码实现 |
| 测试与优化 | ⌛ 待开始 | 0% | 功能验证 |

**总体进度**: 0%

### 新增需求说明
- **深浅色主题适配**: 利用现有主题系统，确保新组件支持双主题
- **横屏布局适配**: 优化横屏下的信息展示效率和视觉体验
- **响应式策略**: 结合现有 ResponsiveBuilder，实现完整的响应式设计

---

## 🎯 下一步行动

1. **确认设计方案**
   - 信息区域展示方案最终选择
   - 视觉设计风格确认
   - 横屏布局细节确认

2. **开始原型开发**
   - 实现速度显示组件 (含主题适配)
   - 实现故障灯系统 (含GPS监控)
   - 实现基础状态管理架构

3. **搭建可运行版本**
   - 创建新仪表盘页面
   - 集成现有主题系统
   - 测试横竖屏切换

4. **迭代优化**
   - 根据实际效果调整设计
   - 优化动画和交互体验
   - 完善响应式细节

---

## 📋 需求确认

**当前状态**: 需求收集完成，等待设计确认

**待确认事项**:
- [ ] 信息区域展示方案最终选择
- [ ] 视觉设计风格确认
- [ ] 横屏布局细节确认
- [ ] 优先级功能排序
- [ ] 开发时间规划

---

## 📚 现有基础设施利用

### ✅ 可直接使用的组件
- **主题系统**: `lightTheme`, `darkTheme`, `ThemeNotifier`, `ThemeSwitcher`
- **颜色系统**: `AppColors`, `SemanticColors`, `LightThemeColors`, `DarkThemeColors`
- **响应式工具**: `ResponsiveBuilder`, `LayoutInfo`, `ResponsiveWidget`
- **基础组件**: `AdaptiveCard`, `TitledAdaptiveCard`, `StatAdaptiveCard`
- **状态指示器**: `StatusIndicator`, `ConnectionIndicator`, `BatteryIndicator`

### ⚠️ 需要适配的现有组件
- `StatCard` - 需要添加主题适配
- `SpeedCard` - 需要重构为响应式
- `BatteryCard` - 需要主题适配
- `PowerCard` - 需要主题适配
- `TemperatureCard` - 需要主题适配
- `ConnectionCard` - 需要主题适配

### 🆕 需要新建的组件
- `DashboardPageV2` - 新仪表盘主页面
- `SpeedDashboard` - 速度显示区域
- `FaultLightSystem` - 故障灯系统
- `InfoArea` - 信息区域容器
- `InfoGroup` - 信息分组组件
- `ResponsiveSpeedDisplay` - 响应式速度显示
- `GPSSignalMonitor` - GPS信号监控

---

**文档维护**: 此文档将随开发进度持续更新
**最后更新**: 2026年1月11日

---

## 🔚 整体需求完成确认

**当前状态**: ❌ 未完成

**待完成事项**:
- 所有核心需求尚未开始实现
- 设计方案需要进一步细化
- 技术实现需要开始编码
- **新增**: 深浅色主题适配
- **新增**: 横屏布局适配

**完成标准**:
- [ ] 所有功能模块实现完成
- [ ] 深浅色主题适配完成
- [ ] 横竖屏切换流畅
- [ ] 通过功能测试
- [ ] UI/UX达到预期效果
- [ ] 性能优化完成
- [ ] 文档更新至"已完成"状态

**当所有需求完成后，请删除此文档或标记为已完成状态。**
