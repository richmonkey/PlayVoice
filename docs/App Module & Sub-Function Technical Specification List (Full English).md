# App Module \& Sub\-Function Technical Specification List \(Full English\)

## 1\. Document Introduction

This document systematically splits all functional and technical modules of the game voice chat application, covering account authentication, user channel system, social relationship, voice chat engine, UI system, payment permission, page routing, exception monitoring, and local cache modules\. Each module includes **core function description, detailed sub\-module breakdown, technical implementation rules, and underlying logic constraints**\. It serves as the unified technical standard for client development, server docking, function testing, and US App Store review compliance verification\.

## 2\. Global Basic Technical Rules \(Universal for All Modules\)

- Full English interface and prompt output, no multi\-language adaptation in this version

- Dual\-mode adaptive rendering \(Light/Dark Mode\), automatic system follow \+ manual switch override

- All interface requests carry login token authentication; anonymous access is completely prohibited

- All user input fields adopt front\-end \& server dual verification mechanism

- All network requests support retry mechanism and network anomaly state monitoring

- Comply with Apple iOS sandbox mechanism, no unauthorized private data collection

## 3\. Core Technical \& Business Module Detailed Specification

### 3\.1 Google Account Authentication Module

**Module Core Function**: Implement exclusive Google identity authentication, automatic account registration for new users, persistent login state management, and secure token verification, providing unified identity credentials for all business modules\.

#### Sub\-Module \& Technical Function Details

- **Google OAuth 2\.0 Authorization Sub\-Module**

    - Adopt standard Google OAuth 2\.0 authorization process, only support official Google Sign\-In SDK invocation

    - Obtain openid \(sub\), user name, avatar URL, and email authorized by users

    - Prohibit third\-party login, guest mode, and anonymous access

- **New User Automatic Registration Sub\-Module**

    - After Google authorization succeeds, client submits authorization credentials to the server

    - Server uses google\_sub as the unique user primary key to judge new/old users

    - New users: automatically generate user data \& create default exclusive channel data in one transaction

    - Default channel name is automatically generated based on Google user display name

- **Persistent Login Token Management Sub\-Module**

    - Server issues JWT token after successful login, client locally persists token in keychain

    - Keychain storage ensures login state retention after app reinstallation \(within token validity period\)

    - Automatic token expiration detection: local verification first, server secondary signature verification

    - Invalid/expired token automatically clears local state and jumps back to login page

- **Login State Global Interception Sub\-Module**

    - Global route interception for all core business pages

    - Unlogged\-in users are prohibited from accessing homepage, voice room, personal center, search page

    - Uniform login interception popup and jump logic

### 3\.2 Exclusive User Channel Module \(One User One Channel\)

**Module Core Function**: Take user exclusive channel as the core business carrier, realize channel data creation, real\-time modification, global synchronization and data uniqueness constraint, and provide room entry credentials for voice chat module\.

#### Sub\-Module \& Technical Function Details

- **Channel Unique Constraint Sub\-Module**

    - Database unique index constraint based on owner\_user\_id, one user corresponds to exactly one channel

    - Prohibit manual creation/ deletion of channels; channel lifecycle is bound to user account

- **Channel Name Edit \& Verification Sub\-Module**

    - Front\-end real\-time verification: length 2–30 characters, pure space interception, special character filtering

    - Server sensitive word dictionary verification \+ reserved word interception \(admin/official/system\)

    - Atomic update of channel name data to avoid concurrent modification conflicts

- **Channel Information Global Synchronization Sub\-Module**

    - After channel name modification, push real\-time update to homepage channel card, personal center, and voice room header

    - Local cache active refresh mechanism to avoid dirty data display

### 3\.3 User Search \& Follow Relationship Module

**Module Core Function**: Implement user fuzzy search capability and follow/unfollow social relationship management, realize homepage channel subscription aggregation, and ensure relationship data uniqueness and data consistency\.

#### Sub\-Module \& Technical Function Details

- **Fuzzy Search Engine Sub\-Module**

    - Support dual\-dimensional fuzzy matching: user nickname \+ channel name

    - Search result filtering rule: filter current logged\-in user to avoid self\-search and self\-follow

    - Search result field return: avatar\_url, user\_name, channel\_name, follow\_status

- **Follow Relationship CRUD Sub\-Module**

    - Database joint unique index \(follower\_user\_id \+ followee\_user\_id\) to prevent duplicate follow data

    - Interface idempotent design: repeated follow requests return success directly without data duplication

    - Support unilateral unfollow, no mutual follow constraint

- **Follow Data Aggregation Synchronization Sub\-Module**

    - After follow/unfollow operation, actively trigger homepage list refresh

    - Followed channel automatically joins homepage aggregation list; unfollowed channel is removed in real time

    - Homepage sorting rule: priority by channel recent active timestamp

### 3\.4 Homepage Data Aggregation \& Route Module

**Module Core Function**: Aggregate user subscription channel data, provide fixed function entrance routing, implement page empty state processing and pull\-down refresh logic, and serve as the core app business entrance\.

#### Sub\-Module \& Technical Function Details

- **Fixed Entrance Routing Sub\-Module**

    - Top fixed "My Channel" entrance: directly route to current user’s exclusive channel voice room

    - Top fixed "Search User" entrance: fixed jump to search page

    - Fixed entrance does not participate in list data sorting

- **Channel List Rendering Sub\-Module**

    - Batch pull followed channel list data asynchronously

    - Single card rendering field: channel name, owner nickname, avatar, last active time

    - Empty state judgment: reserve fixed entrances \+ display standardized English empty guide component

- **Pull\-Down Refresh Sub\-Module**

    - Trigger full data re\-request and local cache coverage update

    - Loading state animation and loading timeout failure retry mechanism

### 3\.5 Low\-Latency Multi\-Player Voice Chat Core Module

**Module Core Function**: The core technical module of the product, realizing voice room entry, real\-time audio streaming transmission, member status synchronization, audio device control, and abnormal reconnection, ensuring low\-latency and stable multi\-person voice interaction\.

#### Sub\-Module \& Technical Function Details

- **Room Entry \& Connection Handshake Sub\-Module**

    - Click channel card to carry channel\_id for room entry authentication

    - Complete WebSocket/real\-time voice channel handshake within 2s

    - Server verify user channel access permission before entering the room

- **Real\-Time Audio Streaming Transmission Sub\-Module**

    - Adopt low\-latency audio encoding algorithm, optimize game voice real\-time transmission

    - Support multi\-user concurrent voice streaming upload and distribution

    - Automatic audio noise reduction and gain balance processing

- **Audio Device Control Sub\-Module**

    - Microphone default closed state, support one\-click mute/unmute switch

    - Speaker/earphone proximity sensing automatic switching \+ manual switching

    - First\-time microphone permission application \& permission state persistent judgment

- **In\-Room Member State Synchronization Sub\-Module**

    - Real\-time push of user online/offline, mute state change events

    - Client local list real\-time diff update, no full list refresh stutter

- **Network Abnormal Reconnection Sub\-Module**

    - Real\-time monitoring of network heartbeat packet timeout

    - Automatic exponential backoff reconnection strategy after disconnection

    - Visual reconnection status prompt and manual retry entrance

- **Room Exit \& Resource Release Sub\-Module**

    - Active exit/ page back/ app background trigger room quit logic

    - Real\-time release of audio stream resources, socket connection, and device occupation

### 3\.6 Personal Information Management Module

**Module Core Function**: Realize user personal data display and editable field modification, complete data verification and server synchronization, and ensure data consistency and operation permission isolation\.

#### Sub\-Module \& Technical Function Details

- **User Data Synchronization Sub\-Module**

    - Synchronize Google basic information \(avatar, nickname, email\) to local display

    - Local cache user basic data to reduce repeated interface requests

- **Information Edit \& Verification Sub\-Module**

    - Editable fields: user nickname, channel name

    - Front\-end real\-time format verification \+ server security verification

    - Save failure retains user input and returns detailed error code \& English description

- **Permission Isolation Sub\-Module**

    - Server strictly verifies user identity, prohibits editing other users’ information

    - All edit interfaces carry token identity authentication

### 3\.7 App Store One\-Time Purchase \& Permission Module

**Module Core Function**: Based on Apple IAP official specification, realize one\-time purchase activation, purchase verification, permission persistence and purchase restoration, comply with US App Store monetization review rules\.

#### Sub\-Module \& Technical Function Details

- **IAP Official Payment Invocation Sub\-Module**

    - Invoke official US App Store one\-time purchase product ID

    - No subscription products, no auto\-renewal rules, compliant with Apple review

- **Purchase Receipt Verification Sub\-Module**

    - Client obtains transaction receipt, server verifies with Apple official verification interface

    - Prevent local fake purchase crack, ensure permission authenticity

- **Permanent Permission Binding Sub\-Module**

    - Purchase permission is bound to App Store account, permanent valid

    - Unpaid users lock core voice room entry function

- **Restore Purchase Sub\-Module**

    - Call Apple official restore transaction interface

    - Automatically identify historical purchase records and recover full function permissions

### 3\.8 Global UI Style \& Dual\-Mode Rendering Module

**Module Core Function**: Unify global UI color, font, gradient, icon, shadow specification, realize Light/Dark Mode global synchronous rendering and component style consistency\.

#### Sub\-Module \& Technical Function Details

- **Color Matching Rendering Sub\-Module**

    - Global color variable management, dual\-mode independent color value mapping

    - Real\-time style refresh after mode switching, no page reloading required

- **Font Hierarchy Management Sub\-Module**

    - Unified San Francisco system font, fixed font size hierarchy and weight rules

    - Automatic text color adaptation with dual\-mode background

- **Component Style Unified Sub\-Module**

    - Unified card rounded corner, button rounded corner, shadow and gradient rules

    - Linear icon unified stroke width and active/inactive state color switching

### 3\.9 App Public Basic Function Module

**Module Core Function**: Undertake app basic auxiliary functions, including system setting, about information, user manual, sharing, scoring, cache management and exception prompt processing\.

#### Sub\-Module \& Technical Function Details

- **System Setting Sub\-Module**: Dark/light mode switch, voice parameter setting, permission management, cache cleaning, version detection

- **Official Information Sub\-Module**: Version display, developer information, protocol link aggregation

- **User Guide Sub\-Module**: First startup welcome guide, functional mask guide, built\-in English user manual

- **Share \& Score Sub\-Module**: Official App Store link sharing, native system sharing panel docking, official store scoring jump

### 3\.10 Global Exception Capture \& Monitoring Module

**Module Core Function**: Capture global network exceptions, operation boundary exceptions, permission exceptions and business errors, standardize English prompt output, and avoid page crash and data disorder\.

#### Sub\-Module \& Technical Function Details

- **Network Exception Processing**: Network timeout, disconnection, request failure unified retry and prompt logic

- **Business Boundary Exception**: Repeat follow, self\-follow, illegal name, empty search result interception

- **Permission Exception Processing**: Microphone permission denial, login failure, unauthorized access interception

- **Global Crash Prevention**: Abnormal data filtering, empty field protection, component error isolation

## 4\. Module Overall Architecture Logic

All modules adopt **hierarchical decoupling design**: basic technical modules support business modules, public modules undertake global general capabilities, core voice and account modules serve as the business core, realizing low coupling, high scalability, and convenient subsequent function iteration and version upgrade\.

> （注：文档部分内容可能由 AI 生成）
