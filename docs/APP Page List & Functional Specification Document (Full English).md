# APP Page List \& Functional Specification Document \(Full English\)

## 1\. Document Overview

This document comprehensively sorts out all page modules of the game voice chat App, covers mandatory specification pages and core business functional pages\. It defines the standard functional configuration, core interactions and page rules for each page, adapts to US App Store review standards, supports Light/Dark dual\-mode adaptation, and matches Google login, channel management, voice chat, user follow core business logic\. All content is based on the actual usage scenarios and functional architecture of the product\.

## 2\. Global Page General Rules

- All pages support Light Mode \& Dark Mode automatic/manual switching

- All page UI text, prompts, buttons and descriptions are 100% English, no other languages

- All pages follow the unified UI design specification \(color, font, icon, gradient, rounded corner\)

- All core functional pages verify Google login status; unlogged\-in users are intercepted and guided to log in

- All abnormal states \(empty data, network error, operation failure\) have standardized English prompts

## 3\. Mandatory Public Specification Pages \(Full Coverage\)

### 3\.1 App Icon \(System Level Page Identification\)

**Page Attribute**: System desktop icon, app exclusive visual identification

**Core Functional Setting**

- Adopt minimalist sci\-fi tech style, match the overall voice chat product positioning

- Support iOS multi\-size adaptation, compatible with all iPhone device desktop display specifications

- Dual\-mode adaptive recognition: the icon tone automatically fits system Light/Dark mode

- Click the desktop icon to trigger app startup and jump to the startup page normally

- No distorted display, no blurring, fully compliant with US App Store icon review standards

### 3\.2 Splash Launch Page

**Page Attribute**: App cold start mandatory loading page

**Core Functional Setting**

- Display official brand logo and pure English product slogan, with unified tech\-style gradient background

- Automatically load app basic configuration, verify local login status and purchase permission

- Fixed 1\.5s display duration, automatically jump to the next page after loading completed

- First\-time startup jumps to welcome guide page; non\-first\-time startup jumps directly to homepage

- No click jump, no advertisement popup, pure loading and brand display function

- Support dual\-mode color adaptation, no screen flickering or blank screen during startup

### 3\.3 Welcome Guide Page \(First Launch Only\)

**Page Attribute**: First\-time app startup exclusive guide page, not displayed for secondary startup

**Core Functional Setting**

- Consist of 3\-4 sci\-fi style guide carousel pages, fully introducing core product capabilities: Google login, exclusive personal channel, user follow, low\-latency voice chat

- Each page matches English functional subtitle and minimalist icon illustration

- Support left and right sliding switching, bottom dot progress indicator

- The last page displays a fixed "Start Using" button

- Click the button to mark the guide as completed locally, permanently skip the guide page for subsequent startup, and jump to login page

- No skip button in the middle process, ensure users complete full product cognition

### 3\.4 App Usage Overlay Guide Page \(Functional Mask Guide\)

**Page Attribute**: Functional floating mask guide, triggered after first entering core pages

**Core Functional Setting**

- After users log in and enter the homepage/voice room page for the first time, automatically pop up a translucent mask guide

- Accurately highlight core functional entrances: My Channel, Search User, Voice Control Button

- Display concise English operation tips corresponding to functional areas

- Support one\-click "Got it" to close the mask, permanently record the viewing state, no repeated popup

- Mask adopts frosted transparent tech style, does not block core page layout, clear hierarchy

- Adapt to all core business pages, guide new users to complete basic operation quickly

### 3\.5 Settings Page

**Page Attribute**: Global app configuration management core page

**Core Functional Setting**

- **Appearance Setting**: Support Light Mode/Dark Mode/System Auto Mode switching, real\-time page style synchronization

- **Voice Function Setting**: Microphone default state setting, speaker/earphone default mode, voice volume adjustment

- **Account Setting**: Google account binding status display, logout function, local login cache clearing

- **Purchase Management**: Display one\-time purchase activation status, provide Restore Purchase entrance

- **Privacy \& Permission**: Microphone permission management entrance, privacy policy quick entry

- **General Functions**: App version check, cache cleaning, feedback \& support entrance

- All setting items switch and save in real time, take effect immediately without restarting the app

### 3\.6 About Page

**Page Attribute**: App official information display page

**Core Functional Setting**

- Display official app logo, full English product name and version number

- Show one\-time purchase permanent authorization description, English product introduction

- Provide quick links: Privacy Policy, Terms of Service, EULA Agreement

- Display developer official information and regional service description \(US region\)

- Support version update detection popup reminder

- No editable items, all content is static official display

### 3\.7 App Share Page

**Page Attribute**: One\-click app official sharing functional page

**Core Functional Setting**

- Provide official App Store sharing link, support sharing to mainstream US social platforms

- Display exclusive app sharing poster \(tech style, full English introduction\)

- Support one\-click copy App Store download link

- Sharing copy is fixed official English copy, highlighting game voice chat core advantages

- No custom sharing content, ensure official brand standardization

- Adapt to iOS system native sharing panel, compliant with Apple sharing specifications

### 3\.8 App Store Rating Page

**Page Attribute**: Official App Store scoring jump page

**Core Functional Setting**

- Built\-in official rating entrance, click to directly jump to US App Store product rating page

- Pop up English gentle reminder before jumping, guide users to score positively

- No in\-app fake scoring function, fully compliant with Apple review rules

- Control popup frequency intelligently, avoid frequent pop\-up interference with user operations

- Support manual active scoring entrance in settings page

### 3\.9 App User Manual Page

**Page Attribute**: Full English official usage instruction page

**Core Functional Setting**

- Sort out complete app usage tutorials: Google login guidance, personal channel creation, user follow operation, voice room joining, voice function control, personal information editing

- Classified display of beginner guidance, functional detailed explanation and common problem solving

- All text and picture tutorials are in English, matching US user reading habits

- Support sliding browsing, local fast loading, no network dependence

- Update synchronously with app version functions, ensure tutorial accuracy and timeliness

- Add common exception prompt solutions \(login failure, voice connection error, purchase restoration failure\)

## 4\. Core Business Functional Pages

### 4\.1 Google Login Page

**Page Attribute**: Core identity authentication page

**Core Functional Setting**

- Only retain Google Sign\-In official entrance, no other login or guest mode

- Display English login authorization description and privacy brief prompt

- First login automatically creates user account and exclusive personal channel

- Persistent login token management, support free login for secondary startup

- Login failure displays clear English error prompts and retry entrance

### 4\.2 Home Page

**Page Attribute**: App core entrance and data aggregation page

**Core Functional Setting**

- Fixed top entrances: My Channel, Search User

- Aggregate and display all followed user channel lists, sorted by recent activity priority

- Each channel card displays channel name, owner nickname, avatar and active time

- Support pull\-down refresh to synchronize the latest follow data and channel status

- Empty follow state displays standard English empty guide and operation prompt

- Click channel card to jump to corresponding voice chat room directly

### 4\.3 User Search Page

**Page Attribute**: User discovery and social relationship management page

**Core Functional Setting**

- Support fuzzy search by user nickname and channel name

- Search result displays avatar, nickname, channel name and follow status

- Prohibit displaying own account in search results, avoid self\-follow behavior

- Support one\-click follow/unfollow, real\-time status synchronization

- No search results display standardized English empty state prompt

### 4\.4 Multi\-Player Voice Chat Page

**Page Attribute**: Core functional scenario page of the product

**Core Functional Setting**

- Automatically join the voice room after entering the page, display real\-time room status and channel name

- Real\-time display of online member list, user nickname and microphone status

- Provide core voice controls: mute/unmute, speaker/earphone switching, leave room

- Support automatic reconnection for network exceptions, display reconnection status prompts

- Adapt to multi\-person simultaneous voice interaction, ensure low\-latency and stable communication

### 4\.5 Personal Profile Page

**Page Attribute**: User identity and channel information management page

**Core Functional Setting**

- Display Google synchronized avatar, nickname, optional email and exclusive channel name

- Support custom editing of nickname and channel name, with front and rear end double verification

- Channel name verification follows unified rules \(length, illegal character, sensitive word interception\)

- Editing success/failure displays accurate English prompts, data updates in real time

- Permission control: only support editing personal own information, no cross\-user operation

### 4\.6 One\-Time Purchase Activation Page

**Page Attribute**: Payment permission activation core page

**Core Functional Setting**

- Display full English one\-time purchase rule description, permanent authorization advantages

- Integrate official US App Store IAP payment entrance

- Provide Restore Purchase function to adapt to device replacement and app reinstallation

- Unpaid users are restricted from entering voice rooms, with clear functional lock prompts

- Purchase status is updated in real time, full functions are unlocked immediately after successful payment

## 5\. Page Full List Summary

**Mandatory Standard Pages**: App Icon, Splash Launch Page, Welcome Guide Page, App Usage Overlay Guide Page, Settings Page, About Page, App Share Page, App Store Rating Page, User Manual Page

**Core Business Pages**: Google Login Page, Home Page, User Search Page, Multi\-Player Voice Chat Page, Personal Profile Page, One\-Time Purchase Activation Page

## 6\. Page Unified Iteration Rule

- All pages follow the latest UI design specification \(Light/Dark dual mode, color gradient, font hierarchy\)

- All page functions match the product requirement document business logic, no redundant or missing functions

- All page interactions comply with iOS human\-computer interaction specifications and US App Store review policies

> （注：文档部分内容可能由 AI 生成）
