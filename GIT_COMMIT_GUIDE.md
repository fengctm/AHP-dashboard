# Git 提交指南

## 应该提交到 Git 的文件

### 1. 源代码文件
- `lib/` - Flutter Dart 源代码
- `test/` - 测试代码
- `android/` - Android 原生代码（部分）
- `ios/` - iOS 原生代码（部分）
- `windows/` - Windows 原生代码（部分）
- `linux/` - Linux 原生代码（部分）
- `macos/` - macOS 原生代码（部分）

### 2. 配置文件
- `pubspec.yaml` - Flutter 依赖配置
- `pubspec.lock` - 依赖版本锁定（可选，建议提交）
- `analysis_options.yaml` - Dart 代码分析配置
- `.gitignore` - Git 忽略配置
- `README.md` - 项目说明
- `项目功能说明.md` - 项目功能文档

### 3. Android 原生资源（重要）
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png
├── mipmap-mdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
├── mipmap-xxxhdpi/ic_launcher.png
├── drawable/ (自定义 drawable)
├── values/ (颜色、字符串等)
└── AndroidManifest.xml
```

### 4. Windows 原生资源（重要）
```
windows/runner/
├── resources/
│   └── app_icon.ico
├── main.cpp
├── flutter_window.cpp
├── flutter_window.h
├── utils.cpp
├── utils.h
├── win32_window.cpp
├── win32_window.h
├── resource.h
├── Runner.rc
├── runner.exe.manifest
└── CMakeLists.txt
```

### 5. Flutter 资源文件
- `lib/statics/` - 静态资源（如 logo.png）
- `assets/` - 自定义资源目录（如果存在）
- 任何在 `pubspec.yaml` 中定义的 assets

### 6. 其他重要文件
- `.metadata` - Flutter 项目元数据
- `.flutter-plugins-dependencies` - Flutter 插件依赖
- `fix_imports.bat` - 自定义脚本（如果需要共享）

## 不应该提交到 Git 的文件

### 1. 构建产物
```
build/
android/app/build/
android/app/.cxx/
android/.gradle/
android/build/
ios/build/
macos/build/
linux/build/
windows/build/
web/
```

### 2. IDE 配置（个人）
```
.idea/workspace.xml
.idea/tasks.xml
.vscode/
*.iml
*.ipr
*.iws
```

### 3. 本地开发文件
```
.env
.env.*
*.local
*.development
*.tmp
*.temp
*.bak
*~
```

### 4. 依赖缓存
```
.pub-cache/
.pub/
android/app/build/
ios/Pods/
macos/Pods/
```

### 5. 敏感信息
```
*.key
*.pem
*.p12
*.pfx
*.crt
*.cer
*.keystore
*.jks
*api_key*
*secret*
*password*
*token*
```

### 6. 本地数据库
```
*.hive
*.hive.lock
*.db
*.sqlite
*.sqlite3
```

### 7. 测试和覆盖率
```
coverage/
test/.test_coverage.dart
```

### 8. 平台特定构建产物
```
*.apk
*.aab
*.ipa
*.app
*.zip
```

## 检查清单

在提交代码前，请确认：

- [ ] 已经运行 `flutter clean` 清理构建产物
- [ ] 没有包含敏感信息（API 密钥、密码等）
- [ ] 包含了所有必要的原生资源文件
- [ ] 包含了 pubspec.yaml 和 pubspec.lock
- [ ] 包含了项目文档（README.md, 功能说明.md）
- [ ] 没有包含个人 IDE 配置文件
- [ ] 没有包含构建产物和缓存文件

## 常见问题

### Q: 为什么需要提交 Android 和 Windows 的原生文件？
A: 这些文件是应用正常运行所必需的，包括应用图标、清单文件、原生代码等。没有这些文件，其他开发者无法正确构建和运行项目。

### Q: pubspec.lock 应该提交吗？
A: 是的，建议提交。它确保所有开发者使用相同版本的依赖，避免版本不一致导致的问题。

### Q: 如果我有自定义的 assets 目录怎么办？
A: 确保在 pubspec.yaml 中正确定义，并且不要在 .gitignore 中排除这些目录。

## 参考资料

- [Flutter 官方 .gitignore](https://github.com/flutter/flutter/blob/master/.gitignore)
- [GitHub 的 Flutter .gitignore 模板](https://github.com/github/gitignore/blob/main/Flutter.gitignore)