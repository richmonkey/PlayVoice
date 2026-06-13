# 项目构建设置

本文档说明如何快速设置和构建项目。

## 系统要求

- macOS 12.0 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9+
- iOS 16.0+ SDK

## 快速开始

### 方案 A：使用 XcodeGen（推荐）

```bash
# 1. 安装 XcodeGen（一次性）
brew install xcodegen

# 2. 进入项目目录
cd /Users/yangpengliang/project/PlayVoice/ios

# 3. 生成 Xcode 项目
xcodegen generate

# 4. 打开项目
open GoogleSignInDemo.xcodeproj

# 5. 在 Xcode 中构建（Cmd+B）
```

### 方案 B：使用 CocoaPods（传统方式，逐步淘汰）

```bash
# 1. 安装 CocoaPods（如未安装）
sudo gem install cocoapods

# 2. 进入项目目录
cd /Users/yangpengliang/project/PlayVoice/ios

# 3. 安装依赖
pod install --repo-update

# 4. 打开 workspace
open GoogleSignInDemo.xcworkspace

# 5. 在 Xcode 中构建（Cmd+B）
```

## 项目结构

```
ios/
├── GoogleSignInDemo/
│   ├── Presentation/          # UI 层（UIViewController、SwiftUI）
│   │   ├── Scenes/           # 各个页面的 ViewController
│   │   │   ├── Home/
│   │   │   ├── Login/
│   │   │   ├── VoiceRoom/
│   │   │   └── Profile/
│   │   └── ViewModels/       # 视图逻辑
│   ├── Domain/               # 业务层（纯 Swift，无框架依赖）
│   │   ├── UseCases/         # 业务用例
│   │   ├── Entities/         # 业务数据模型
│   │   └── Protocols/        # 接口定义
│   ├── Data/                 # 数据层（Repository、DTO、Mapper）
│   │   ├── Repositories/     # 数据仓储
│   │   ├── DTOs/             # 网络/数据库 DTO
│   │   └── Mappers/          # DTO ↔ Entity 转换
│   ├── Infrastructure/       # 基础层（网络、数据库、DI）
│   │   ├── Network/          # API 客户端
│   │   ├── Database/         # 数据库访问
│   │   └── Core/             # 依赖注入、日志等
│   ├── Resources/            # 资源文件
│   │   ├── Assets.xcassets
│   │   ├── Localizable.strings
│   │   └── LaunchScreen.storyboard
│   ├── AppDelegate.swift     # 应用代理
│   ├── SceneDelegate.swift   # 场景代理
│   └── Bridging-Header.h     # ObjC-Swift 桥接
├── Project.yml               # XcodeGen 项目配置
├── Package.swift             # Swift Package Manager 配置
├── Podfile                   # CocoaPods 配置（可选，逐步淘汰）
├── BUILD_SETUP.md           # 本文件
├── MIGRATION_GUIDE.md       # 迁移指南
└── CLAUDE.md                # 项目架构文档
```

## 构建设置

### 开发构建

```bash
# 清理构建缓存
xcodebuild clean

# 开发模式构建
xcodebuild -scheme GoogleSignInDemo -configuration Debug build
```

### 发布构建

```bash
# 发布模式构建（优化大小和性能）
xcodebuild -scheme GoogleSignInDemo -configuration Release build
```

### 运行单元测试

```bash
xcodebuild -scheme GoogleSignInDemo test
```

### 构建 iPhone 模拟器

```bash
xcodebuild -scheme GoogleSignInDemo \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
  build
```

## 常见问题排查

### 1. 找不到 Swift.h 或其他 header

**症状：** `fatal error: 'Swift.h' file not found`

**解决：**
```bash
# 清理 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 重新生成项目
xcodegen generate

# 在 Xcode 中 clean build folder (Shift+Cmd+K)
```

### 2. CocoaPods 版本冲突

**症状：** `CocoaPods could not find compatible versions`

**解决：**
```bash
# 更新 pod 仓库
pod repo update

# 清理 Pods 并重新安装
rm -rf Pods Podfile.lock
pod install --repo-update
```

### 3. SPM 依赖下载失败

**症状：** `Cannot fetch package from ...`

**解决：**
```bash
# 清理 SPM 缓存
rm -rf ~/Library/Caches/com.apple.dt.Xcode/SourcePackages

# 重新生成项目
xcodegen generate

# 在 Xcode 中：File > Packages > Reset Package Caches
```

### 4. Objective-C 桥接头找不到

**症状：** `Bridging header ... not found`

**解决：**
确保 `Project.yml` 中的配置正确：
```yaml
settings:
  SWIFT_OBJC_BRIDGING_HEADER: GoogleSignInDemo/Bridging-Header.h
```

然后重新生成：
```bash
xcodegen generate
```

### 5. WebRTC framework 找不到

**症状：** `ld: framework not found WebRTC`

**解决：**
1. 确保 `WebRTC.xcframework` 存在：
   ```bash
   ls -la ios/WebRTC.xcframework
   ```

2. 在 `Project.yml` 中配置 framework 搜索路径：
   ```yaml
   frameworkSearchPaths:
     - $(SRCROOT)/WebRTC.xcframework
     - $(SRCROOT)/protooclient.xcframework
   ```

3. 重新生成项目

## 环境变量和配置

编辑 `Project.yml` 中的 `settings` 部分来修改全局构建设置：

```yaml
settings:
  DEVELOPMENT_TEAM: "YOUR_TEAM_ID"  # 设置开发团队 ID
  CODE_SIGN_STYLE: Automatic
  SWIFT_VERSION: "5.9"
  IPHONEOS_DEPLOYMENT_TARGET: "16.0"
```

## 脚本命令

快速设置脚本（保存为 `setup.sh`）：

```bash
#!/bin/bash

set -e

echo "📱 GoogleSignInDemo 项目设置"

# 检查 XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "📦 安装 XcodeGen..."
    brew install xcodegen
fi

# 生成项目
echo "🔨 生成 Xcode 项目..."
xcodegen generate

# 清理缓存
echo "🧹 清理构建缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/GoogleSignInDemo-*

echo "✅ 完成！"
echo "下一步："
echo "  open GoogleSignInDemo.xcodeproj"
```

使用脚本：
```bash
chmod +x setup.sh
./setup.sh
```

## 依赖管理

### 查看已安装的依赖

#### SPM 方式：
```bash
# Package.swift 或 Project.yml 中的 packages 部分
cat Package.swift | grep -A 20 dependencies
```

#### CocoaPods 方式：
```bash
pod list
```

### 更新依赖

#### SPM 方式：
编辑 `Project.yml` 中的版本号，然后重新生成：
```bash
xcodegen generate
```

#### CocoaPods 方式：
```bash
pod update
pod install
```

## 持续集成 (CI/CD)

使用 GitHub Actions 示例（`.github/workflows/build.yml`）：

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'
      
      - name: Install XcodeGen
        run: brew install xcodegen
      
      - name: Generate project
        working-directory: ios
        run: xcodegen generate
      
      - name: Build
        working-directory: ios
        run: xcodebuild -scheme GoogleSignInDemo build
```

## 更新项目文档

修改项目配置后，记得更新本文档和 `Project.yml` 中的注释。

---

**最后更新：** 2026-06-13

