# 项目结构说明

## 📁 目录结构

```
AHP-dashboard/
├── lib/
│   ├── core/                           # 核心配置和工具
│   │   ├── constants/                  # 常量定义
│   │   │   └── app_constants.dart      # 应用常量
│   │   ├── theme/                      # 主题系统
│   │   │   ├── app_colors.dart         # 配色方案
│   │   │   └── theme_config.dart       # 主题配置
│   │   │   └── theme_service.dart      # 主题服务
│   │   └── utils/                      # 工具类
│   │       └── app_utils.dart          # 应用工具
│   │
│   ├── data/                           # 数据层（预留）
│   │   ├── models/                     # 数据模型
│   │   ├── repositories/               # 仓库
│   │   └── datasources/                # 数据源
│   │
│   ├── domain/                         # 领域层（预留）
│   │   ├── entities/                   # 实体
│   │   ├── repositories/               # 仓库接口
│   │   └── usecases/                   # 用例
│   │
│   ├── presentation/                   # 表现层
│   │   ├── widgets/                    # 组件库
│   │   │   ├── atoms/                  # 原子组件
│   │   │   │   ├── adaptive_card.dart  # 响应式卡片
│   │   │   │   ├── custom_button.dart  # 自定义按钮
│   │   │   │   ├── responsive_builder.dart # 响应式构建器
│   │   │   │   ├── status_indicator.dart # 状态指示器
│   │   │   │   └── theme_switcher.dart # 主题切换器
│   │   │   ├── molecules/              # 分子组件
│   │   │   │   └── stat_card.dart      # 统计卡片
│   │   │   └── organisms/              # 有机体组件
│   │   │       └── dashboard_grid.dart # 仪表盘网格
│   │   ├── pages/                      # 页面
│   │   │   └── dashboard_page.dart     # 仪表盘页面
│   │   ├── providers/                  # 状态提供者
│   │   │   └── theme_provider.dart     # 主题提供者
│   │   └── screens/                    # 屏幕（预留）
│   │
│   └── main.dart                       # 应用入口
│
├── pubspec.yaml                        # 依赖配置
├── analysis_options.yaml               # 代码分析配置
├── DESIGN_SPEC.md                      # 设计规范
├── DESIGN_SUMMARY.md                   # 设计摘要
├── DESIGN_CHECKLIST.md                 # 设计检查清单
├── QUICK_START.md                      # 快速开始
├── PROJECT_STRUCTURE.md                # 本文件
└── README.md                           # 项目说明
```

## 🎯 核心组件说明

### 1. 主题系统
- **AppColors**: 基础配色和语义化颜色
- **ThemeConfig**: 浅色和深色主题配置
- **ThemeService**: 本地存储管理
- **ThemeProvider**: Riverpod 状态管理
- **ThemeSwitcher**: UI 组件

### 2. 原子组件 (Atoms)
- **AdaptiveCard**: 响应式卡片容器
- **CustomButton**: 自定义按钮系列
- **ResponsiveBuilder**: 响应式布局构建器
- **StatusIndicator**: 状态指示器
- **ThemeSwitcher**: 主题切换器

### 3. 分子组件 (Molecules)
- **StatCard**: 统计卡片（速度、电量、功率、温度等）
- **SpeedCard**: 速度专用卡片
- **BatteryCard**: 电池状态卡片
- **PowerCard**: 功率卡片
- **TemperatureCard**: 温度卡片
- **ConnectionCard**: 连接状态卡片

### 4. 有机体组件 (Organisms)
- **DashboardGrid**: 仪表盘网格布局
- **DashboardGroup**: 分组布局
- **DashboardView**: 完整页面布局

### 5. 页面 (Pages)
- **DashboardPage**: 主仪表盘页面

## 🔧 技术栈

### 核心依赖
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9      # 状态管理
  shared_preferences: ^2.2.2    # 本地存储
  flutter_animate: ^4.2.0+1     # 动画库
  cupertino_icons: ^1.0.2       # 图标
```

### 开发依赖
```yaml
dev_dependencies:
  flutter_lints: ^2.0.0         # 代码规范
  riverpod_lint: ^2.3.7         # Riverpod 代码检查
```

## 📊 设计规范实现

### ✅ 已实现
1. **主题设计**
   - ✅ 深色/浅色主题支持
   - ✅ 系统跟随模式
   - ✅ 手动切换
   - ✅ 主题记忆

2. **页面设计**
   - ✅ Material Design 3 规范
   - ✅ 卡片式布局
   - ✅ 视觉层次

3. **动画设计**
   - ✅ 苹果风格动画
   - ✅ 流畅过渡
   - ✅ 交互反馈

4. **配色方案**
   - ✅ 科技蓝主色调
   - ✅ 扁平化设计
   - ✅ 语义化颜色

5. **组件化开发**
   - ✅ 单一职责原则
   - ✅ 原子/分子/有机体分层
   - ✅ 高复用性

6. **多端适配**
   - ✅ Android/iOS/Linux 支持
   - ✅ 响应式布局
   - ✅ 平台检测

7. **横屏适配**
   - ✅ 布局自动切换
   - ✅ 网格调整
   - ✅ 分栏布局

## 🚀 使用指南

### 启动应用
```bash
flutter pub get
flutter run
```

### 添加新组件
1. 确定组件层级（原子/分子/有机体）
2. 遵循单一职责原则
3. 使用响应式设计
4. 添加适当的动画
5. 遵循配色规范

### 添加新页面
1. 在 `presentation/pages/` 创建页面
2. 使用 `DashboardView` 或自定义布局
3. 集成主题系统
4. 添加横屏支持

### 修改主题
1. 在 `app_colors.dart` 添加颜色
2. 在 `theme_config.dart` 更新主题
3. 组件会自动应用新主题

## 📝 开发规范

### 代码风格
- 使用 `const` 构造函数
- 使用命名参数
- 遵循 DRY 原则
- 组件代码 < 200 行

### 文件命名
- 小写下划线：`custom_button.dart`
- 类名大驼峰：`CustomButton`
- 常量大写：`AppConstants`

### 导入顺序
1. Dart 核心库
2. Flutter 框架
3. 外部包
4. 项目内部

## 🎨 设计原则

### 1. 响应式优先
```dart
// 使用 LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    // 根据尺寸调整
  },
)
```

### 2. 主题感知
```dart
// 使用 Theme.of(context)
Color color = Theme.of(context).colorScheme.primary;
```

### 3. 动画适度
```dart
// 使用 Animate
Animate(
  effects: [FadeEffect(), SlideEffect()],
  child: Widget(),
)
```

### 4. 组件独立
```dart
// 每个组件独立文件
// 每个组件单一职责
// 每个组件可复用
```

## 🔍 测试策略

### 单元测试
- 测试工具函数
- 测试数据转换
- 测试状态管理

### 组件测试
- 测试渲染
- 测试交互
- 测试响应式

### 集成测试
- 测试完整流程
- 测试横竖屏切换
- 测试主题切换

## 📈 未来扩展

### 短期
- [ ] 数据图表组件
- [ ] 设备连接功能
- [ ] 历史数据页面
- [ ] 设置页面

### 中期
- [ ] 实时数据更新
- [ ] 数据导出功能
- [ ] 通知系统
- [ ] 多语言支持

### 长期
- [ ] 云端同步
- [ ] AI 分析
- [ ] 社交功能
- [ ] 插件系统

---

**版本**: v1.0  
**创建日期**: 2026-01-06  
**最后更新**: 2026-01-06