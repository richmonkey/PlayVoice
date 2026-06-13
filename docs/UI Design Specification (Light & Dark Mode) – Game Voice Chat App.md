# UI Design Specification \(Light \& Dark Mode\) – Game Voice Chat App

## 1\. Overview

This document defines the official global UI visual specification for the game voice chat application, including overall visual style, color system \(base color, primary accent color, icon color, gradient color\), typography system, icon style, and standardized color rules for Light Mode and Dark Mode\.

The overall visual orientation is**Modern Sci\-Fi / Minimal Tech Style**, matching gaming social and real\-time voice interaction scenarios, adapting to US market aesthetic preferences, supporting dual\-mode dynamic switching, and providing unified visual standards for UI development, design iteration and App Store release\.

## 2\. Overall Visual Style Positioning

### 2\.1 General Style

**Style Orientation**: Clean Minimalist \+ Light Sci\-Fi Tech Style

**Style Features**

- Flat \& lightweight layout with subtle layered shadow and blur effects, avoiding overly heavy metal texture

- Low\-saturation main tone \+ high\-brightness accent color, highlighting gaming technology sense without visual fatigue

- Highly rounded card components, unified minimalist stroke icons, consistent modern interactive feeling

- Low\-delay transparent gradient and soft ambient light effect, fitting real\-time voice online status and active social atmosphere

**Applicable Scenarios**: Game team voice chat, online room socialization, user subscription \& channel management tool product attributes

### 2\.2 Design Principles

- **High Recognizability**: Core functions \(voice room, microphone control, follow\) have fixed visual identification

- **High Readability**: Text contrast meets WCAG international accessibility standard

- **Low Distraction**: Minimal decoration, focus on voice function and user list information

- **Mode Consistency**: Light/Dark mode maintains unified visual hierarchy and component logic

## 3\. Global Color System Specification

All color values adopt Hex standard, unified for iOS client development; two complete color systems for Light Mode and Dark Mode\.

### 3\.1 Light Mode Color System \(Day Mode\)

#### 3\.1\.1 Base Color \(Global Background \& Neutral\)

- **Primary Background**: \#F6F7FA \(Ultra\-light gray, main page background, clean and soft\)

- **Card Background**: \#FFFFFF \(Pure white, all card/list item background\)

- **Page Blank Background**: \#F2F4F8

- **Divider Line**: \#E8EBF2 \(Low saturation, non\-intrusive separation\)

- **Disabled Background**: \#E2E5EC

#### 3\.1\.2 Core Brand Primary Color

Tech blue as the main brand tone, representing stability, communication and technology, suitable for voice social tool positioning\.

- **Primary Brand Color**: \#2570FF

- **Primary Light Shade**: \#E8F0FF \(Card hover, tag background\)

- **Primary Dark Shade**: \#1E5FE8 \(Button press effect\)

#### 3\.1\.3 Key Accent Color \(Focus \& Interactive\)

Used for core interactive buttons, online status, voice active state, highlight prompts\.

- **Active Green \(Online/Voice On\)**: \#00C48C

- **Warning Orange**: \#FF9500

- **Danger Red \(Mute/Offline/Error\)**: \#F53F3F

- **Info Blue**: \#4080FF

#### 3\.1\.4 Text Color System

- **Primary Text**: \#1D2129 \(Main title, core information, highest contrast\)

- **Secondary Text**: \#4E5969 \(Subtitle, descriptive text\)

- **Tertiary Text**: \#86909C \(Auxiliary text, time, status, empty hint\)

- **Placeholder Text**: \#B4BCCC

#### 3\.1\.5 Icon Color System

- **Primary Icon**: \#1D2129 \(Functional icon on navigation bar\)

- **Secondary Icon**: \#4E5969 \(Auxiliary function icon\)

- **Light Icon**: \#86909C \(Inactive icon\)

- **Brand Icon Highlight**: \#2570FF \(Selected/active icon state\)

#### 3\.1\.6 Gradient Color Specification \(Light Mode\)

Applied for main button, voice room card, functional highlight module\.

- **Main Brand Gradient**: Linear\-gradient\(135deg, \#2570FF 0%, \#4096FF 100%\)

- **Voice Active Gradient**: Linear\-gradient\(135deg, \#00C48C 0%, \#36D3AA 100%\)

- **Card Shadow Gradient**: 0px 4px 12px rgba\(37, 112, 255, 0\.08\)

### 3\.2 Dark Mode Color System \(Night Mode\)

Dark mode adopts deep dark blue\-gray system, reducing screen glare, adapting to night game scenarios, maintaining tech sense and hierarchical clarity\.

#### 3\.2\.1 Base Color

- **Primary Background**: \#0F1118 \(Global main background\)

- **Card Background**: \#1C1F2E \(All rounded card components\)

- **Page Blank Background**: \#0B0D14

- **Divider Line**: \#2E3142

- **Disabled Background**: \#252836

#### 3\.2\.2 Core Brand Primary Color

- **Primary Brand Color**: \#3B82FF \(Brighter than light mode to ensure dark field recognition\)

- **Primary Light Shade**: \#1A2847

- **Primary Dark Shade**: \#2568E5

#### 3\.2\.3 Key Accent Color

- **Active Green \(Online/Voice On\)**: \#0ECC96

- **Warning Orange**: \#FFAB40

- **Danger Red \(Mute/Offline/Error\)**: \#F75656

- **Info Blue**: \#5895FF

#### 3\.2\.4 Text Color System

- **Primary Text**: \#F2F3F5 \(Core title, high brightness\)

- **Secondary Text**: \#C9CDD4 \(Subtitle, description\)

- **Tertiary Text**: \#86909C \(Auxiliary text, status hint\)

- **Placeholder Text**: \#5C6370

#### 3\.2\.5 Icon Color System

- **Primary Icon**: \#F2F3F5

- **Secondary Icon**: \#C9CDD4

- **Light Icon**: \#5C6370

- **Brand Highlight Icon**: \#3B82FF

#### 3\.2\.6 Gradient Color Specification \(Dark Mode\)

- **Main Brand Gradient**: Linear\-gradient\(135deg, \#3B82FF 0%, \#539DFF 100%\)

- **Voice Active Gradient**: Linear\-gradient\(135deg, \#0ECC96 0%, \#40D8B2 100%\)

- **Card Shadow Gradient**: 0px 4px 16px rgba\(0, 0, 0, 0\.3\)

## 4\. Icon Style Unified Specification

### 4\.1 Overall Icon Style

**Style**: Minimalist Linear Tech Icon

**Features**: Uniform stroke thickness, no complex decoration, neat outline, strong modern tech sense, suitable for voice tool lightweight positioning\.

### 4\.2 Unified Rules

- **Stroke Width**: 2px unified stroke \(standard for all functional icons\)

- **Corner Processing**: Unified rounded corner 2px, no sharp right angle

- **Style Uniformity**: All navigation icons, function icons, status icons adopt linear style; no mixed flat solid icon

- **Active State**: Selected icon filled with brand primary color or gradient

- **Status Icon Rule**: Online/voice\-on uses green gradient, mute/offline uses gray/red system

### 4\.3 Common Icon Color Application

- Navigation bar default icon: secondary icon color

- Navigation bar selected icon: brand primary color

- Microphone on / speaker on: active green

- Microphone mute / leave room: danger red

- Search, edit, setting auxiliary icons: tertiary icon color

## 5\. Global Font System Specification

The app uses **English\-only modern system font**, follows iOS native font logic, realizes hierarchical unified text display\.

### 5\.1 Font Family

- iOS System: San Francisco \(default system font, highest readability\)

- Unified rule: All pages, buttons, hints, titles use the same font family, no fancy artistic font

### 5\.2 Font Size Hierarchy \(Unified for Light/Dark Mode\)

- **Large Title**: 24pt / Bold \(Page main title, empty state title\)

- **Page Title**: 20pt / Semibold \(Navigation bar title, module title\)

- **Card Title**: 17pt / Semibold \(Channel name, user nickname, room name\)

- **Body Text**: 15pt / Regular \(Main descriptive text, list content\)

- **Auxiliary Text**: 13pt / Regular \(Time, status, prompt description\)

- **Small Tip Text**: 11pt / Regular \(Footnote, empty guide, tag text\)

### 5\.3 Font Color Matching Rule

- Large Title / Page Title: Primary text color

- Card Title: Primary text color

- Body Text: Secondary text color

- Auxiliary \& Tip Text: Tertiary text color

- Button text: Always white \(\#FFFFFF\) on gradient/primary button

## 6\. Component Universal Visual Rules

### 6\.1 Card Radius

- Global card unified rounded corner: 12px

- Button rounded corner: 8px

- Input box rounded corner: 10px

### 6\.2 Shadow Rule

- Light Mode: Soft low\-transparency brand shadow

- Dark Mode: Deep black shadow to enhance card hierarchy

### 6\.3 Gradient Usage Restriction

- Gradient only applies to core buttons, voice active status, highlight cards

- Auxiliary modules use solid color uniformly to avoid visual noise

## 7\. Light \& Dark Mode Switching Logic

- Follow system default mode automatically

- Support manual independent switching in app settings

- After switching, all colors, text, icons, gradients and shadows switch synchronously without style disorder

- Visual hierarchy completely consistent in dual modes, only color depth and background difference

## 8\. Final Style Summary

This product adopts **minimalist light sci\-fi tech style**, takes low\-saturation tech blue as the main brand color, matches green voice active state recognition, forms a set of high\-recognition, low\-fatigue, game\-scene\-adaptive UI visual system\. Dual\-mode color matching meets day and night use scenarios, unified icon, font and gradient specifications ensure consistent and professional visual performance of the whole app, matching US App Store high\-standard visual review requirements\.

> （注：文档部分内容可能由 AI 生成）
