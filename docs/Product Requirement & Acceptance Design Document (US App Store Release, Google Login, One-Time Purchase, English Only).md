# Product Requirement \& Acceptance Design Document \(US App Store Release, Google Login, One\-Time Purchase, English Only\)

## Revision History

|Version|Revision Date|Revision Content|
|---|---|---|
|V1\.1|2026\-06\-13|Cancel anonymous no\-account mode; restore official Google Account login system; restore user exclusive channel, follow relationship, personal profile management capabilities; fully adapt US App Store compliance and one\-time purchase monetization rules; update all functional and page acceptance criteria|
|V1\.0|2026\-06\-13|Initial document: US App Store oriented, no account, one\-time purchase, English only|

## 1\. Product Overview

This product is a gaming\-focused multi\-player real\-time voice chat application optimized for the US market and compliant with US App Store review policies\. The app adopts **Google Account exclusive login** for identity authentication, supports one user one independent voice channel, user search \& follow, followed channel aggregation display, low\-latency team voice chat, and personal profile \& channel information management\.

Different from the anonymous version, this version builds a complete user identity system based on Google login, retains social subscription capabilities centered on user channels, and applies a **one\-time purchase permanent activation** model \(no subscription, no in\-app ads, no secondary consumption\)\. The entire product supports **English\-only UI and content**, fully adapting to US local user habits and App Store review standards\.

## 2\. Core Product Positioning \& Version Scope

### 2\.1 Core Positioning \(US App Store Target\)

- **Google Account Login Only**: Unified identity authentication via Google Sign\-In, persistent login status, standard user account system, meeting US mainstream user login habits\.

- **One\-Time Purchase Monetization**: Full\-feature permanent activation after single App Store payment, no auto\-renew subscriptions, no hidden charges, compliant with Apple IAP rules\.

- **English\-Only Global Adaptation**: All UI text, system prompts, error messages and policy content are pure English, no multi\-language switching\.

- **Channel\-Centric Social Voice Tool**: Take independent user channel as the core, realize subscription aggregation and stable low\-latency game voice chat\.

### 2\.2 In\-Scope Features \(V1\.1 US Release\)

- Google Account one\-click login \& persistent login status management

- Automatic creation of exclusive personal channel for new Google users \(one user one channel\)

- User nickname \& channel name custom editing and information management

- User fuzzy search, follow \& unfollow relationship management

- Homepage aggregation display of followed user channels \& personal channel quick entrance

- Full\-feature multi\-player voice chat room \(join room, member display, mute control, leave room\)

- US App Store one\-time purchase activation \& purchase restore mechanism

- Full English interface \& US privacy compliance data management

### 2\.3 Out\-of\-Scope Features \(Excluded in This Version\)

- Anonymous visitor mode \& no\-login usage

- Multi\-channel system \(each user owns only one exclusive channel\)

- Complex content recommendation algorithm \& official operation content

- Private message, comment, like and other interactive social functions

- Background operation management system \& user background management tools

- Subscription payment, interstitial ads, banner ads and in\-app secondary consumption

## 3\. Target Users \& Core Usage Scenarios

### 3\.1 Target Users \(US Market\)

- US game players who need stable low\-latency voice chat for team battles and open\-world game teaming

- Content creators who need independent exclusive voice channels to gather fans and team members

- US users who are used to Google Account login and pursue lightweight and pure voice social tools

- Users who accept one\-time purchase permanent activation and reject subscription recurring charges

### 3\.2 Core Usage Scenarios

- New user downloads the app, completes one\-time purchase activation, logs in via Google Account, and automatically generates an exclusive personal voice channel

- Users search for other players/creators by nickname or channel name, follow favorite users, and subscribe to their channel dynamics

- Users view all followed channel lists on the homepage, sorted by activity priority

- Users quickly enter their own exclusive channel or followed user channels to start multi\-player real\-time voice communication

- Users enter personal homepage to edit nickname and custom channel name to build personal voice identity

- Users restore purchase permissions and persistent Google login status after device replacement or app reinstallation

## 4\. Detailed Functional Requirements \& Function Acceptance Criteria

### 4\.1 Google Account Login Function

#### Function Description

The app takes Google Account as the only login method\. Users complete identity authentication through Google Sign\-In\. New users automatically create app account and exclusive channel after successful login; returning users realize persistent free login based on valid token\.

#### Core Business Rules

- Only support Google Account login, no other login or anonymous visitor mode

- First\-time Google login: automatically create user account and generate default exclusive channel

- Non\-first\-time login: verify local \& server token, directly enter homepage with valid login status

- Login status persistent storage, support free login within valid token period

- Server verifies Google token signature and validity to ensure login security

- Core fields obtained from Google: unique sub ID, user name, avatar URL, email \(optional privacy display\)

#### Function Acceptance Points

- The login page displays standard English Google login entrance, no other login options

- Click Google login to correctly invoke official Google authorization panel, support normal account authorization

- New user first login successfully creates app user account and default personal channel

- Returning users can log in automatically with valid token and jump to homepage normally

- Login failure \(authorization rejection, network error\) displays clear English error prompts without page crash

- Server effectively verifies Google token, no invalid token fake login risk

- User Google basic information \(nickname, avatar\) is normally synchronized to personal homepage

### 4\.2 One\-Time Purchase \& Permanent Activation Function

#### Function Description

Adapt to US App Store IAP rules\. The app is free to download, and all core voice chat and social channel functions are locked by default\. Users complete one\-time official payment to permanently unlock full functions, with lifelong valid permissions and no subsequent fees\.

#### Core Business Rules

- Only support US App Store official one\-time purchase, no subscription, no auto\-renewal

- Purchase permission is bound to App Store account, permanent validity

- Support purchase restoration after app reinstallation or device replacement

- Unpaid logged\-in users can only access personal homepage and search page, and cannot enter voice chat room

#### Function Acceptance Points

- Unpaid Google logged\-in users are restricted from entering voice rooms, with standard English purchase prompts

- Click purchase button to correctly invoke US App Store official payment panel

- Successful payment permanently unlocks all channel and voice chat functions

- Restore Purchase function correctly identifies historical purchase records and recovers permissions

- No subscription entrance or auto\-renewal prompt in the whole app, compliant with App Store review

### 4\.3 Exclusive User Channel \(One User One Channel\)

#### Function Description

Each Google authenticated user corresponds to one and only one exclusive voice channel\. Users can customize and modify the channel name, and the channel information is synchronously updated on the homepage and personal homepage in real time\.

#### Core Business Rules

- One user corresponds to one exclusive channel permanently, no multiple channels

- Channel name supports custom modification, with front\-end and back\-end double verification

- Verification rules: 2\-30 characters, no pure spaces, no sensitive words and system reserved words \(admin/official etc\.\)

- Modified channel name takes effect in real time and synchronizes all display positions

#### Function Acceptance Points

- New Google users automatically generate default channels after first login

- Channel name modification function is normal, compliant with length and character rules

- Illegal channel name input triggers accurate English error prompts

- Modified channel name is synchronously displayed on homepage and personal homepage in real time

### 4\.4 User Search \& Follow Management

#### Function Description

Logged\-in users can search other valid users by nickname or channel name, and perform follow/unfollow operations\. Followed user channels will be automatically aggregated on the homepage\.

#### Core Business Rules

- Support fuzzy search by user nickname and channel name

- Search results display avatar, nickname, channel name and follow status

- Prohibit searching and following own account, no self\-follow relationship

- Follow relationship is unique, no repeated follow data

- Follow success: target channel is added to homepage list; unfollow: channel is removed from list

#### Function Acceptance Points

- Search function matches keywords accurately, no missing or wrong matching

- Self\-account will not appear in search results, prohibit self\-follow

- Follow/unfollow operation responds normally, no repeated follow anomalies

- Follow status is updated in real time, homepage channel list synchronizes changes

- No search result displays standard English empty state guide

### 4\.5 Homepage Followed Channel Aggregation

#### Function Description

The homepage takes channel subscription aggregation as the core, fixedly displays personal channel entrance and user search entrance, and dynamically displays all followed user channels, supporting quick entry to voice chat rooms\.

#### Core Business Rules

- Top fixed entrances: My Channel, Search User, not involved in list sorting

- Followed channel list is sorted by recent activity priority

- Single channel card displays channel name, owner nickname, avatar and latest active time

- Empty follow status retains fixed top entrances and displays English empty guide text

- Support homepage pull\-down refresh to synchronize latest follow data and channel status

#### Function Acceptance Points

- Homepage top fixed entrances are displayed normally, no layout dislocation

- Click My Channel to jump to personal exclusive channel voice room normally

- Click Search User to jump to search page accurately

- Followed channel list is sorted correctly, card information is complete and accurate

- Empty state displays standard English guide without blank page anomaly

- Pull\-down refresh updates list data normally

### 4\.6 Multi\-Player Voice Chat Core Function

#### Function Description

Users can enter personal channels or followed user channels to join voice rooms, realize low\-latency multi\-player real\-time voice communication, support member status viewing and voice control operations\.

#### Core Business Rules

- Entering the page automatically initiates joining the corresponding channel voice room

- Single channel supports unlimited multi\-player online voice interaction

- Microphone is closed by default, need manual enable and system permission authorization

- Support mute/unmute, speaker/earphone switching, active leave room

- Exit page or click leave button to automatically quit voice room

- Network exception triggers automatic reconnection with status prompt

#### Function Acceptance Points

- Successfully join the voice room within 2s under normal network, connection status is normal

- Online member list displays all in\-room users in real time, microphone status is synchronized accurately

- Mute and sound switching operations are sensitive and effective, status is synchronized for all members

- Multi\-player voice communication is stable with low latency, no stuttering, distortion or noise

- Leave room function takes effect normally, voice connection is completely terminated

- Abnormal network reconnection mechanism works normally, with clear English status prompts

### 4\.7 Personal Homepage Display \& Editing

#### Function Description

Personal homepage displays user Google basic information and exclusive channel information, supports user editing nickname and channel name, with real\-time data synchronization after saving\.

#### Core Business Rules

- Display content: avatar, nickname, optional email display, exclusive channel name

- Support manual editing of nickname and channel name, with data verification before saving

- Successful editing prompts and refreshes page data in real time

- Editing failure displays specific English error reasons and retains user input

- Users can only edit their own personal information and channel data

#### Function Acceptance Points

- Personal homepage correctly loads Google user information and exclusive channel information

- Editing entrance is normal, modified content verification rules take effect

- Successful saving synchronizes data to homepage and channel list in real time

- Failed saving returns accurate English error prompts without data loss

- No permission to edit other users' information, with effective permission interception

### 4\.8 Exception \& Boundary Processing

#### Function Acceptance Points

- Google login failure displays clear English retry prompt, no page stuck

- Search empty state, repeated follow, self\-follow and other boundary scenarios have standardized English prompts

- Illegal channel name/nickname modification returns specific error reasons

- Network error triggers exception prompt and supports manual retry

- All abnormal scenarios do not cause data confusion, page flashback or functional paralysis

## 5\. Page Structure \& Page\-Level Must\-Have Acceptance Points

All app pages adopt **100% English UI**, comply with iOS design specifications and US regional visual habits, no Chinese or other language characters\.

### 5\.1 Login Page

#### Page Core Functions

Provide exclusive Google Account login entrance, display app product introduction and purchase activation instructions\.

#### Page Must\-Have Acceptance Points

- Full English interface, all buttons, prompts and descriptive text are standard English

- Only Google login entrance is displayed, no other login modes

- Google authorization pop\-up invokes normally, login process is smooth

- Page adapts to all US mainstream iPhone models, no UI dislocation

### 5\.2 Purchase Activation Page

#### Page Core Functions

Display one\-time purchase rules, official payment entrance and purchase restore entrance, unlock full voice chat functions\.

#### Page Must\-Have Acceptance Points

- Clear English one\-time purchase description, no misleading subscription text

- Payment and restore buttons function normally, compliant with Apple IAP rules

- Purchase status is updated in real time, function unlocking takes effect immediately

### 5\.3 Homepage

#### Page Core Functions

Fixed top function entrances, aggregated display of followed user channels, quick entry to voice rooms\.

#### Page Must\-Have Acceptance Points

- Top My Channel and Search User entrances are fixed and displayed normally

- Followed channel list is sorted accurately with complete card information

- Empty state guide is standard English, no abnormal blank interface

- Pull\-down refresh data is synchronized normally

### 5\.4 User Search Page

#### Page Core Functions

Provide user keyword search, display matching user list, support follow/unfollow operation\.

#### Page Must\-Have Acceptance Points

- Search box prompt text and operation buttons are pure English

- Search result filtering and matching are accurate

- Follow status switching is sensitive, real\-time update

- Empty search result displays standard English empty state

### 5\.5 Multi\-Player Voice Chat Page

#### Page Core Functions

Display channel information, online member list, voice control panel and connection status\.

#### Page Must\-Have Acceptance Points

- Channel name and room status are displayed in real time and accurately

- Online member list and microphone status are synchronized in real time

- Voice control buttons \(mute, switch sound, leave room\) work normally

- Network reconnection status visual display, all prompt texts are English

### 5\.6 Personal Homepage

#### Page Core Functions

Display user Google information and channel information, support information editing and saving\.

#### Page Must\-Have Acceptance Points

- Personal information and channel data are loaded completely and accurately

- Editing and saving functions are normal, verification rules take effect

- Successful/failed saving prompts are standard English

- Data modification is synchronized to the whole app in real time

## 6\. Data Model \& Permission Security Rules

### 6\.1 Core Data Model

#### User

user\_id, google\_sub \(unique\), name, avatar\_url, email, created\_at, updated\_at

#### Channel

channel\_id, owner\_user\_id \(unique\), channel\_name, created\_at, updated\_at

#### Follow

follow\_id, follower\_user\_id, followee\_user\_id, created\_at; unique index: follower\_user\_id \+ followee\_user\_id

### 6\.2 Permission \& Security Requirements

- All business interfaces must verify Google login token status

- Users can only edit their own personal information and channel data

- Follow relationship operation only takes effect for the current logged\-in user

- Server strictly verifies Google token signature and validity to prevent fake login

- No sensitive keys and private data exposed on the client side

## 7\. US App Store Compliance \& UAT Final Acceptance Standards

### 7\.1 Compliance Standards

- Comply with US user privacy policy, clearly declare Google information acquisition scope

- One\-time purchase fully complies with Apple IAP review rules, no illegal charging mode

- Full English interface, no non\-English text residue

- Complete and standard English privacy policy page

### 7\.2 Full Version UAT Acceptance Standards

- The app can be installed and run normally on US regional iOS devices without crash or flashback

- Google login, automatic channel creation, persistent login are fully normal

- One\-time purchase and restore purchase functions are effective permanently

- User search, follow relationship and homepage channel aggregation are closed\-loop normal

- Multi\-player voice chat is stable and low\-latency, all control functions are effective

- Personal information and channel editing functions are normal with real\-time synchronization

- All abnormal scenarios have clear English prompts without data confusion

- Fully compliant with US App Store review and privacy specifications

> （注：文档部分内容可能由 AI 生成）
