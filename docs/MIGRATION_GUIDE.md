# iOS 依赖管理迁移指南

本指南说明如何从 CocoaPods 迁移到现代化的 Swift Package Manager (SPM) 和 XcodeGen。

## 为什么迁移？

| 特性 | CocoaPods | SPM + XcodeGen |
|-----|---------|----------------|
| 依赖管理 | Ruby 脚本，外部工具 | Swift 原生，无额外依赖 |
| 项目配置 | .pbxproj（二进制，难以合并） | Project.yml（YAML，易读易合并） |
| 构建速度 | 较慢，额外编译步骤 | 快，集成到 Xcode |
| 维护成本 | 高（Pods 目录庞大，难以版本管理） | 低（轻量级配置文件） |
| 新项目支持 | 逐渐淘汰 | Apple 官方推荐 |

## 迁移步骤

### 1. 安装 XcodeGen

```bash
brew install xcodegen
```

验证安装：
```bash
xcodegen version
```

### 2. 生成新项目配置

```bash
cd /Users/yangpengliang/project/PlayVoice/ios
xcodegen generate
```

这将根据 `Project.yml` 生成新的 `.pbxproj` 文件。

### 3. 备份旧配置（可选但推荐）

```bash
# 备份旧的 Podfile 和 Pods
git add Podfile* ios/GoogleSignInDemo.xcodeproj/
git commit -m "backup: CocoaPods configuration before migration"
```

### 4. 清理 CocoaPods 数据

```bash
# 删除 Pods 目录
rm -rf ios/Pods

# 删除 Podfile（如果完全迁移到 SPM）
rm ios/Podfile ios/Podfile.lock

# 清理 CocoaPods 缓存（可选）
pod cache clean --all
```

### 5. 添加 SPM 依赖到 Xcode

在 Xcode 中：
1. 打开项目 `GoogleSignInDemo.xcodeproj`
2. 选择 **Project > GoogleSignInDemo > Package Dependencies**
3. 点击 **+** 添加包：
   - SnapKit: `https://github.com/SnapKit/SnapKit.git` (版本 5.7.1)
   - GoogleSignIn: `https://github.com/google/GoogleSignIn-iOS.git` (版本 7.1.0)

或使用 Swift 命令行：
```bash
xcodegen generate  # 自动通过 Project.yml 配置
```

### 6. 更新导入语句

无需修改导入语句，SPM 与 CocoaPods 的导入方式相同：

```swift
import SnapKit
import GoogleSignIn
```

### 7. 构建并测试

```bash
# 清空 build 缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/GoogleSignInDemo-*

# 使用 Xcode 或命令行构建
xcodebuild -scheme GoogleSignInDemo -configuration Debug build
```

## 部分迁移策略

如果不想一次性迁移所有依赖，可以**混用 CocoaPods 和 SPM**：

### 保留 CocoaPods 方案

修改 `Project.yml` 中注释掉的部分，继续使用 CocoaPods：

```yaml
# 移除 packages 和相关配置
# 执行: pod install
# 在 Xcode 中打开 .xcworkspace 文件
```

### 逐步迁移方案

1. 先迁移无依赖关系的包（如 SnapKit）
2. 测试确认无误后，迁移有依赖的包（如 GoogleSignIn）
3. 最后删除 Podfile

## 常见问题

### Q: 迁移后 build 失败？

A: 清理 build 缓存并重新生成：
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodegen generate
xcodebuild clean build
```

### Q: SwiftUI 和 UIKit 混用时的依赖冲突？

A: SPM 支持条件化导入和平台特定依赖。编辑 `Package.swift`：

```swift
.target(
    name: "GoogleSignInDemo",
    dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
    ],
    swiftSettings: [
        .define("SWIFT_UI_ONLY", .when(platforms: [.iOS]))
    ]
)
```

### Q: 某些包不支持 SPM？

A: 保留这些包的 CocoaPods，其他迁移到 SPM。编辑 `Project.yml`：

```yaml
# 配置 CocoaPods 依赖
# 配置 SPM 依赖
```

### Q: 如何回滚到 CocoaPods？

A: 从 git 恢复：
```bash
git restore ios/Podfile ios/Podfile.lock
pod install
# 删除 Project.yml 和 Package.swift
rm ios/Project.yml ios/Package.swift
```

## Bridging Header 配置

如果项目包含 Objective-C 代码（如 WebRTC），需要配置桥接头：

创建 `GoogleSignInDemo/Bridging-Header.h`：

```objc
//
//  Bridging-Header.h
//  GoogleSignInDemo
//

#ifndef Bridging_Header_h
#define Bridging_Header_h

#import "ARDCaptureController.h"
#import "RoomClient.h"
#import "WebRTCVideoView.h"

#endif /* Bridging_Header_h */
```

在 `Project.yml` 中配置：

```yaml
targets:
  GoogleSignInDemo:
    settings:
      SWIFT_OBJC_BRIDGING_HEADER: GoogleSignInDemo/Bridging-Header.h
```

## XcodeGen 配置维护

修改依赖或构建设置时，编辑 `Project.yml` 然后重新生成：

```bash
# 编辑 Project.yml
vim ios/Project.yml

# 生成新配置
xcodegen generate

# 提交更新
git add ios/Project.yml ios/GoogleSignInDemo.xcodeproj
git commit -m "chore: update project configuration via XcodeGen"
```

## 资源

- [Apple SPM 官方文档](https://developer.apple.com/documentation/swift_packages)
- [XcodeGen GitHub](https://github.com/yonaskolb/XcodeGen)
- [SnapKit SPM 支持](https://github.com/SnapKit/SnapKit#installation)
- [GoogleSignIn-iOS SPM 支持](https://github.com/google/GoogleSignIn-iOS)

---

**建议流程：**

1. 在新分支上进行迁移
2. 在该分支上运行完整的单元测试和集成测试
3. 通过 PR 审查后再合并到 main
4. 文档更新后通知团队

