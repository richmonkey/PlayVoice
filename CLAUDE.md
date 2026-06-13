# PlayVoice 项目规范

PRODUCT_REQUIREMENTS.md 是产品功能文档

---

## 任务完成输出规范

**禁止自动生成说明文档**。执行任务完成后，遵循以下规范：

1. **只生成简要结论** — 一句话或两句话总结做了什么
2. **说明文档可选** — 仅在以下情况生成：
   - 用户主动要求："生成文档"、"写说明"、"创建指南"
   - 字段不清楚，需要指导性文档澄清流程
3. **代码注释规则** — 遵循下述代码风格规范
4. **不生成的内容**：
   - ✗ 任务总结文档
   - ✗ 实现清单
   - ✗ 迁移指南
   - ✗ 快速开始文档
   - ✗ 变更日志

---

## iOS 项目架构

iOS 客户端开发优先使用系统原生控件，项目使用 Swift 语言 + UIKit 框架。

### 整体分层

```
App
├── Presentation      # UI 渲染，不含业务逻辑
├── Domain            # 业务核心，零框架依赖
├── Data              # 数据转换与聚合
└── Infrastructure    # 网络、数据库、基础服务
```

**依赖方向严格单向：** Presentation → Domain ← Data ← Infrastructure

Domain 层不依赖任何外部框架，便于单元测试和替换底层实现。

### 目录结构

```
GoogleSignInDemo/
├── Presentation/
│   ├── Scenes/               # UIViewController 或 SwiftUI View
│   │   ├── Home/
│   │   ├── Login/
│   │   ├── VoiceRoom/
│   │   └── Profile/
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── AuthViewModel.swift
│   │   └── ...
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.strings
│       └── LaunchScreen.storyboard
│
├── Domain/
│   ├── UseCases/
│   │   ├── LoginUseCase.swift
│   │   ├── FetchFollowedChannelsUseCase.swift
│   │   └── ...
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── Channel.swift
│   │   ├── Session.swift
│   │   └── ...
│   └── Protocols/
│       ├── UserRepositoryProtocol.swift
│       ├── ChannelRepositoryProtocol.swift
│       ├── AuthRepositoryProtocol.swift
│       └── ...
│
├── Data/
│   ├── Repositories/
│   │   ├── UserRepository.swift
│   │   ├── AuthRepository.swift
│   │   ├── ChannelRepository.swift
│   │   └── ...
│   ├── DTOs/
│   │   ├── UserSearchDTO.swift
│   │   ├── AuthDTO.swift
│   │   ├── ChannelDTO.swift
│   │   └── ...
│   └── Mappers/
│       ├── AuthMapper.swift
│       ├── ChannelMapper.swift
│       └── ...
│
└── Infrastructure/
    ├── Network/
    │   ├── APIClient.swift
    │   ├── Endpoint.swift
    │   └── Interceptors/
    ├── Room/              # WebRTC 相关
    │   ├── RoomClient.m
    │   ├── ARDCaptureController.m
    │   └── WebRTCVideoView.m
    └── Core/
        ├── AppDI.swift
        ├── AppCoordinator.swift
        ├── AppConfig.swift
        └── AppError.swift
```

### DTO vs Entity

两者服务于不同边界，严禁混用。

**DTO（Data Layer）** - 贴着外部数据格式
- 字段命名遵循 API 规范（snake_case），通过 `CodingKeys` 映射
- 类型宽松（`String`、`Int`），随 API 版本变化
- 不含任何业务逻辑

**Entity（Domain Layer）** - 贴着业务概念
- 字段命名由业务语言决定（camelCase）
- 类型严格（`UUID`、`Date`、枚举），由 Mapper 在转换时验证
- 可含计算属性和业务方法
- 不 import 任何框架

**Mapper** - 负责 DTO ↔ Entity 转换，提供默认值和类型验证

### ViewModel

ViewModel 是 View 与 Domain 之间的"翻译官"：

1. **接收用户意图（Input）** — 把手势/事件封装为语义明确的输入
2. **调用 UseCase** — 唯一与 Domain 层打交道的地方
3. **转换数据为 ViewState** — 格式化、聚合，生成 View 可直接绑定的状态
4. **管理 loading / error 生命周期**

**规则：**
- ViewModel 文件不 `import UIKit`，与 UI 框架完全解耦
- 通过协议注入 UseCase，便于 mock 单测
- ViewState 枚举，View 只做 switch 渲染，不含 if/else 业务判断

### 网络层约定

- 所有请求通过 `APIClient` 发出，不在 Repository 直接使用 `URLSession`
- `Endpoint` 枚举定义所有接口，包含 path、method、参数
- Token 注入、Retry、日志统一在 `Interceptors/` 处理
- 错误统一映射为项目自定义的 `AppError` 类型

### 依赖注入约定

- 通过 `AppDI.swift` 统一注册和解析依赖
- ViewModel、UseCase、Repository 均通过构造器注入，不使用 Service Locator
- 测试时替换为 Mock 实现，无需修改被测类

### 项目构建管理

项目使用 **XcodeGen** 管理配置，支持 **SPM** 和 **CocoaPods** 两种依赖管理方案：

- **Project.yml** - XcodeGen 项目配置文件
- **Package.swift** - Swift Package Manager 清单
- **Bridging-Header.h** - Objective-C ↔ Swift 桥接（WebRTC 使用）
- **setup.sh** - 自动化项目初始化脚本

详见 `ios/` 目录下的 BUILD_SETUP.md 和 MIGRATION_GUIDE.md。