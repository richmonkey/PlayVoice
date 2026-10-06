# AGENTS.md

## 项目技术栈

- Android 原生开发
- Kotlin 优先；旧 Java 代码允许保留并与 Kotlin 混用
- 新 UI 优先使用 Jetpack Compose + Material 3
- 多 Activity 项目允许继续使用 `Intent` 导航；仅在单 Activity或 Activity 内多页面场景使用 Navigation Compose
- 状态管理使用 ViewModel + StateFlow
- 异步任务使用 Kotlin Coroutines
- 默认使用显式构造函数注入和手工 AppContainer； 仅在依赖关系明显复杂时再引入 Hilt。
- 网络层使用 Retrofit + OkHttp
- 本地结构化数据使用 Room
- 配置、偏好等小型数据使用 DataStore

## 架构原则

采用分层架构：

```text
UI / Feature
    ↓
ViewModel
    ↓
UseCase（仅复杂业务需要）
    ↓
Repository
    ↓
Remote / Local
```

约定：

- UI 不直接访问 Retrofit、Room、DataStore。
- ViewModel 不处理具体 UI 布局。
- Repository 负责统一数据访问。
- 简单 CRUD 不强制增加 UseCase。
- 复杂业务逻辑放入 Domain / UseCase。
- Repository 接口放 `domain/repository`。
- Repository 实现放 `data/repository`。
- `domain` 不依赖 `data`、Compose、Retrofit、Room 等基础设施。

## 推荐目录结构

```text
app/
core/
    network/
    database/
    datastore/
    ui/

feature/
    login/
    home/
    user/
    settings/

domain/
    model/
    repository/
    usecase/

data/
    repository/
    remote/
        api/
        dto/
    local/
        dao/
        entity/
    mapper/
```

采用“UI 按 Feature 组织，Domain/Data 按层统一组织”的方式。

## 目录职责

### `app/`

应用入口和全局组装层。

主要负责：

- `Application`
- `MainActivity`
- App 级 Compose 根节点
- 全局 Navigation
- App 级依赖装配
- 全局生命周期相关初始化

不要在这里放具体业务逻辑。

示例：

```text
app/
    App.kt
    MainActivity.kt
    navigation/
```

### `core/`

整个项目共享的基础能力。

只放与具体业务无关、可被多个模块复用的代码。

#### `core/network/`

网络基础设施，例如：

- Retrofit 创建与配置
- OkHttpClient
- Interceptor
- 通用网络错误
- JSON 序列化配置

不要放 `UserApi`、`OrderApi` 等具体业务 API。

#### `core/database/`

数据库基础设施，例如：

- `RoomDatabase`
- 数据库初始化
- Migration
- 通用数据库配置

具体业务的 DAO / Entity 放到 `data/local`。

#### `core/datastore/`

DataStore 基础设施，例如：

- DataStore 创建
- Preferences Key
- Serializer
- App 级设置存储封装

用于主题、语言、首次启动状态等简单配置。

#### `core/ui/`

跨 Feature 复用的 UI 组件，例如：

- Loading
- Error
- Empty
- 通用 Button
- Dialog
- AppBar
- Theme / Design System

业务专属 UI 不放这里。

### `feature/`

页面和交互层。

按业务功能划分，例如：

```text
feature/
    login/
    user/
    order/
    settings/
```

每个 Feature 主要包含：

- `Screen`
- `Route`
- `ViewModel`
- `UiState`
- UI Event
- Feature 专属 Component

示例：

```text
feature/user/
    UserListRoute.kt
    UserListScreen.kt
    UserListViewModel.kt
    UserListUiState.kt
    UserDetailRoute.kt
    UserDetailScreen.kt
    component/
```

约定：

- Feature 负责 UI 和页面交互。
- Feature 可以依赖 `domain`。
- Feature 不直接访问 Retrofit、Room。
- Feature 不保存 Repository 的具体实现。

### `domain/`

业务规则层。

该层应尽量保持纯 Kotlin，不依赖 Android UI 和数据存储实现。

#### `domain/model/`

业务模型。

例如：

```text
User
Order
Product
Message
```

业务模型应表达业务含义，不应该直接使用：

- `@Entity`
- Retrofit DTO 注解
- Compose UI 类型

#### `domain/repository/`

Repository 接口。

定义业务层需要哪些数据能力，例如：

```kotlin
interface UserRepository {
    suspend fun getUser(id: Long): User
}
```

这里只定义能力，不关心数据具体来自：

- HTTP
- Room
- DataStore
- 文件
- 缓存

#### `domain/usecase/`

复杂业务操作。

例如：

```text
LoginUseCase
CreateOrderUseCase
SyncMessagesUseCase
```

简单 CRUD 不要求创建 UseCase，ViewModel 可以直接调用 Repository。

### `data/`

数据实现层。

负责数据获取、保存、转换以及 Repository 实现。

#### `data/repository/`

实现 `domain/repository` 中定义的接口。

例如：

```text
UserRepositoryImpl
OrderRepositoryImpl
```

Repository 实现负责协调：

```text
Remote
Local
Cache
```

并向上层暴露 Domain Model。

#### `data/remote/`

远程数据源。

负责与服务器通信。

常见结构：

```text
data/remote/
    api/
    dto/
```

`api/`：

- Retrofit API Interface

`dto/`：

- Request DTO
- Response DTO

DTO 只表示网络数据格式，不应直接作为业务模型传给 UI。

#### `data/local/`

本地数据源。

负责 Room、文件等本地持久化。

常见结构：

```text
data/local/
    dao/
    entity/
```

`dao/`：

- Room DAO

`entity/`：

- Room Entity

Entity 表示数据库结构，不应直接暴露给 UI。

#### `data/mapper/`

负责模型转换，例如：

```text
UserDto -> User
UserEntity -> User
User -> UserEntity
```

用于隔离：

```text
Network Model
Database Model
Domain Model
```

## 模型边界

不同层的模型不要随意混用。

推荐：

```text
UserDto
    ↓
Mapper
    ↓
User
    ↑
Mapper
    ↑
UserEntity
```

含义：

- `UserDto`：网络模型
- `UserEntity`：数据库模型
- `User`：Domain 业务模型

UI 优先使用 Domain Model 或专门的 UiModel。

## Compose 页面

复杂页面按职责拆分：

```text
Route
↓
Screen
↓
Section / Component
```

- `Route`：连接 ViewModel、Navigation、Side Effect。
- `Screen`：页面整体布局。
- `Component`：独立 UI 区块。
- 页面状态使用 `UiState`。
- 状态向下传递，事件向上传递。
- 业务状态放 ViewModel。
- 纯 UI 临时状态可使用 `remember` / `rememberSaveable`。
- 不要在 Composable 中直接执行网络或数据库操作。

### 打开页面时自动聚焦输入框

页面需要打开后自动聚焦输入框时：

- 使用 `remember { FocusRequester() }` 创建请求器，并通过 `Modifier.focusRequester(focusRequester)` 绑定到目标输入框。
- 不要在父级 Composable 或 `Scaffold` 内容尚未完成组合时立即调用 `requestFocus()`；此时目标节点可能尚未挂载，导致 `FocusRequester is not initialized` 崩溃。
- 将 `LaunchedEffect` 放在目标输入框之后、同一个内容插槽中；先等待一帧，再请求焦点并显示软键盘。
- 焦点请求必须在 `LaunchedEffect`、点击等副作用或事件中执行，不能在组合阶段直接执行；输入框不可用时不要请求焦点。

示例：

```kotlin
val focusRequester = remember { FocusRequester() }
val keyboard = LocalSoftwareKeyboardController.current

TextField(
    value = value,
    onValueChange = onValueChange,
    enabled = enabled,
    modifier = Modifier.focusRequester(focusRequester),
)

LaunchedEffect(focusRequester, enabled) {
    if (enabled) {
        withFrameNanos { }
        focusRequester.requestFocus()
        keyboard?.show()
    }
}
```

## 页面导航

### 多 Activity

Activity 之间使用：

```kotlin
startActivity(Intent(...))
```

参数通过 Intent Extra 传递。

多 Activity 不影响使用 Compose。

### Navigation Compose

使用 Navigation Compose 时：

- 优先使用类型安全 Route。
- Screen 不直接依赖 `NavController`。
- Screen 暴露 `onBack`、`onUserClick` 等回调。
- 导航参数只传 ID、Key 等小型数据。
- 不通过导航参数传完整业务对象。


## 旧多 Activity 向 Navigation Compose 的渐进式迁移

旧项目无需一次性改造成 Single Activity。

可以优先选择一组业务关系紧密、跳转频繁的 Activity，例如：

```text
UserListActivity
UserDetailActivity
EditUserActivity
```

将它们重构为：

```text
UserActivity
    ↓
UserNavHost
    ├── UserListRoute
    │   └── UserListScreen
    ├── UserDetailRoute
    │   └── UserDetailScreen
    └── EditUserRoute
        └── EditUserScreen
```

其他尚未迁移的 Activity 可以继续保留：

```text
LoginActivity
HomeActivity
UserActivity        ← 内部使用 Navigation Compose
SettingsActivity
PaymentActivity
```

这种“旧 Activity + 新 Navigation Compose Feature”的混合模式允许长期存在。

### 适合合并的页面

优先合并同一业务流程中的页面，例如列表、详情、编辑、创建、选择器、子设置页。

例如：

```text
OrderListActivity
OrderDetailActivity
OrderEditActivity
```

可以重构为：

```text
OrderActivity
    ↓
OrderNavHost
```

登录、支付、第三方授权、相机、独立任务流等独立性较强的 Activity 不要求强制合并。

### 迁移后的职责

推荐：

```text
Activity
    ↓
NavHost
    ↓
Route
    ↓
Screen
    ↓
ViewModel
```

- Activity：Compose 容器和 Feature 入口。
- NavHost：定义该 Feature 内页面、导航关系和返回栈。
- Route：连接 Navigation、ViewModel、UiState 和 Side Effect。
- Screen：负责 UI 和用户事件回调。
- ViewModel：负责页面状态和业务操作。

不要把原 Activity 中的复杂业务逻辑重新堆到新的容器 Activity 中。

### 对应目录

以 `user` Feature 为例：

```text
feature/
    user/
        UserActivity.kt

        navigation/
            UserNavHost.kt
            UserRoute.kt

        list/
            UserListRoute.kt
            UserListScreen.kt
            UserListViewModel.kt
            UserListUiState.kt

        detail/
            UserDetailRoute.kt
            UserDetailScreen.kt
            UserDetailViewModel.kt
            UserDetailUiState.kt

        edit/
            EditUserRoute.kt
            EditUserScreen.kt
            EditUserViewModel.kt
            EditUserUiState.kt

        component/
            ...
```

约定：

- Feature 容器 Activity 放在 `feature/<feature>/`。
- Feature 内 Navigation Compose 代码放在 `feature/<feature>/navigation/`。
- 页面较多时，每个页面使用独立子目录。
- 页面专属 Component 放在对应页面目录；多个页面共享的 UI 放 `feature/<feature>/component/`。
- Domain、Repository、Remote、Local 仍放项目根目录的 `domain/` 和 `data/`，不要放回 Feature。

例如：

```text
feature/user/UserActivity.kt
feature/user/navigation/UserNavHost.kt
feature/user/detail/UserDetailScreen.kt
feature/user/detail/UserDetailViewModel.kt

domain/model/User.kt
domain/repository/UserRepository.kt

data/repository/UserRepositoryImpl.kt
data/remote/api/UserApi.kt
data/remote/dto/UserDto.kt
data/local/dao/UserDao.kt
data/local/entity/UserEntity.kt
```

### 示例

`feature/user/UserActivity.kt`：

```kotlin
class UserActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            UserNavHost()
        }
    }
}
```

`feature/user/navigation/UserNavHost.kt`：

```kotlin
@Composable
fun UserNavHost() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = UserList
    ) {
        composable<UserList> {
            UserListRoute(
                onUserClick = { id ->
                    navController.navigate(UserDetail(id))
                }
            )
        }

        composable<UserDetail> { entry ->
            val route = entry.toRoute<UserDetail>()

            UserDetailRoute(
                userId = route.userId,
                onBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
```

迁移过程中允许同时存在：

```text
传统多 Activity + XML
        +
部分 Feature 使用 Compose
        +
部分 Feature 使用 Navigation Compose
```

不要为了统一形式进行一次性大规模重写。

## 数据存储

### Room

用于：

- 业务数据
- 列表数据
- 聊天、订单、商品等结构化数据
- 需要查询、排序、关联的数据

### DataStore

用于：

- 用户设置
- 主题
- 语言
- 首次启动状态
- 简单偏好

不要把 DataStore 当成关系型数据库。


## 编码要求

- 优先简单、清晰、可维护的实现。
- 生成或修改的 Kotlin / Java 代码必须按常规格式分行：一个语句一行；函数参数、数据类字段、链式调用和回调在较长时分行并缩进；不要为压缩篇幅把多个语句、分支或回调写在同一行。
- 不为了“架构完整”增加无意义抽象。
- 避免超大 Activity、ViewModel、Composable。
- 公共基础能力放 `core`。
- 页面/UI 放对应 `feature`。
- 业务规则放 `domain`。
- 数据实现放 `data`。
- 新代码优先 Kotlin。
