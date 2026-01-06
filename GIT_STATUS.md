# Git 配置状态说明

## 当前 .gitignore 配置

已为 AHP Dashboard 项目创建了全面的 `.gitignore` 文件，包含以下类别：

### ✅ 会被忽略的文件类型

1. **构建产物**
   - `build/` 目录及其所有内容
   - Android 构建输出 (`android/app/build/`, `android/.gradle/`)
   - iOS 构建输出 (`ios/build/`)
   - Windows 构建输出 (`windows/build/`)
   - 应用包文件 (`*.apk`, `*.aab`, `*.ipa`)

2. **IDE 配置**
   - IntelliJ/Android Studio (`.idea/`, `*.iml`, `*.ipr`, `*.iws`)
   - VS Code (`.vscode/`, `*.code-workspace`)
   - 其他 IDE 临时文件

3. **依赖缓存**
   - Pub 缓存 (`.pub-cache/`, `.pub/`)
   - CocoaPods (`ios/Pods/`, `macos/Pods/`)
   - Dart 工具 (`.dart_tool/`)

4. **本地开发文件**
   - 环境变量 (`.env`, `.env.*`)
   - 临时文件 (`*.tmp`, `*.temp`, `*.bak`)
   - 本地配置 (`*.local`, `*.development`)

5. **敏感信息**
   - 证书和密钥 (`*.key`, `*.pem`, `*.p12`, `*.pfx`)
   - API 密钥和密码 (`*api_key*`, `*secret*`, `*password*`, `*token*`)

6. **本地数据库**
   - Hive 数据库文件 (`*.hive`, `*.hive.lock`)

7. **测试和覆盖率**
   - 测试覆盖率报告 (`coverage/`)

### ✅ 会被提交的文件类型

1. **源代码**
   - `lib/` - Flutter Dart 源代码
   - `test/` - 测试代码

2. **配置文件**
   - `pubspec.yaml` - 依赖配置
   - `pubspec.lock` - 依赖版本锁定
   - `analysis_options.yaml` - 代码分析配置
   - `.gitignore` - Git 忽略规则
   - `README.md` - 项目说明
   - `项目功能说明.md` - 功能文档
   - `GIT_COMMIT_GUIDE.md` - 提交指南（新建）
   - `GIT_STATUS.md` - 本文件（新建）

3. **Android 原生资源**
   - `android/app/src/main/res/` - 应用图标和资源
   - `android/app/src/main/AndroidManifest.xml` - 清单文件
   - `android/app/build.gradle` - 构建配置

4. **Windows 原生资源**
   - `windows/runner/resources/` - Windows 图标
   - `windows/runner/*.cpp`, `*.h` - 原生代码
   - `windows/runner/CMakeLists.txt` - 构建配置

5. **Flutter 资源**
   - `lib/statics/logo.png` - 应用 Logo
   - 任何在 `pubspec.yaml` 中定义的 assets 目录

6. **其他**
   - `.metadata` - Flutter 项目元数据
   - `.flutter-plugins-dependencies` - 插件依赖
   - `fix_imports.bat` - 自定义脚本

## 使用建议

### 1. 首次使用前清理
```bash
# 清理所有构建产物
flutter clean

# 删除所有未被跟踪的文件（谨慎使用）
git clean -fdX
```

### 2. 检查将要提交的文件
```bash
# 查看当前状态
git status

# 查看将要提交的文件
git add -n .
```

### 3. 添加必要的原生文件
如果发现某些原生资源文件未被跟踪，手动添加：
```bash
# Android 资源
git add android/app/src/main/res/
git add android/app/src/main/AndroidManifest.xml

# Windows 资源
git add windows/runner/resources/
git add windows/runner/*.cpp
git add windows/runner/*.h
git add windows/runner/CMakeLists.txt

# Flutter 资源
git add lib/statics/
```

## 重要提醒

### ⚠️ 绝对不要提交的内容
- 任何包含敏感信息的文件
- 构建产物和缓存文件
- 个人 IDE 配置
- 本地数据库文件

### ✅ 必须提交的内容
- 所有源代码文件
- 配置文件（pubspec.yaml, pubspec.lock）
- Android 和 Windows 的原生资源文件
- 应用图标和必要的资源文件

## 验证配置

可以使用以下命令验证 `.gitignore` 是否正确工作：

```bash
# 查看哪些文件被忽略
git status --ignored

# 查看特定文件是否被忽略
git check-ignore -v android/app/build/
```

## 下一步

1. 运行 `flutter clean` 清理构建产物
2. 检查 `git status` 确认没有意外的文件
3. 确保所有必要的原生文件都已添加
4. 提交代码到 Git 仓库

---

*文档创建时间: 2026-01-06*