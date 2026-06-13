# PlayVoice — App Store Metadata (English)

---

## App Name (Max 30 characters)

```
PlayVoice - Game Voice Chat
```
**Character count: 27**

---

## Subtitle (Max 30 characters)

```
Real-Time Squad Voice Rooms
```
**Character count: 27**

---

## Primary Category

```
Social Networking
```

## Secondary Category

```
Entertainment
```

---

## Keywords (Max 100 characters total, comma-separated)

```
voice chat,gaming,squad,team talk,game voice,voice room,channel,follow,walkie,voice party
```
**Character count: 89**

> Keyword strategy: covers core use case (voice chat, gaming), user intent (squad, team talk, follow), and alternative terms (walkie, voice party) to expand search surface without redundancy.

---

## Promotional Text (Max 170 characters)
> Promotional Text can be updated any time without a new app version submission.

```
Low-latency voice rooms for your gaming squad. Follow players, join their channels, and talk in real time — one purchase, no subscriptions.
```
**Character count: 139**

---

## Description (Max 4000 characters)

```
PlayVoice is the no-fuss voice chat app built for gamers who need crystal-clear, low-latency communication while playing together.

No lobby setup. No subscription. One tap and you're talking.

──────────────────────────────────────
 HOW IT WORKS
──────────────────────────────────────

Every user gets their own exclusive voice channel. Share it with your squad, follow your teammates' channels, and jump in whenever a session starts — all from a single, clean home screen.

1. Sign in with Google or Apple — zero extra registration steps.
2. Your personal voice channel is created automatically.
3. Search for players by name or channel, then tap Follow.
4. Their channel appears on your Home screen sorted by activity.
5. Tap any channel to enter the live voice room instantly.

──────────────────────────────────────
 FEATURES
──────────────────────────────────────

🎙 Crystal-Clear Voice Chat
Powered by WebRTC for low-latency, high-quality audio — the same technology trusted by professional communication tools.

📡 Personal Voice Channel
One account, one channel. Fully yours. Customize your channel name to build your gaming identity.

👥 Follow System
Follow the players you team up with most. Their channels live on your Home screen so you can join with one tap.

🔍 Search & Discover
Search players by username or channel name. Follow, unfollow, and manage your squad list anytime.

🔇 Full Mic Controls
Mute/unmute yourself in one tap. Switch between speaker and earpiece without leaving the room.

🌗 Light & Dark Mode
Automatically follows your system appearance. A clean, minimal interface that stays out of your way.

🔒 One-Time Purchase
Pay once, use forever. No subscriptions. No recurring charges. No in-app ads. Everything is unlocked permanently after a single purchase.

──────────────────────────────────────
 PRIVACY & PERMISSIONS
──────────────────────────────────────

PlayVoice requests only what it needs:
• Microphone — required for voice chat (requested when you first enter a voice room)
• No location access
• No contacts access
• No camera access

Your Google or Apple account name and profile photo are used solely to display your identity within the app. No data is sold to third parties.

──────────────────────────────────────
 PERFECT FOR
──────────────────────────────────────

• Battle royale squads who need quick, reliable comms
• Tabletop & co-op gamers coordinating in real time
• Friends who just want to hang out over voice without the bloat
• Streamers building a tight-knit community channel

──────────────────────────────────────

Download PlayVoice, claim your channel, and never miss a squad session again.
```
**Character count: ~2,850** *(well within the 4,000-character limit)*

---

## 上线备注 / App Review Notes

> Submitted to Apple App Review for Version 1.0

### 1. 当前版本主要内容 (What's New / Version Highlights)

This is the initial release of PlayVoice (Version 1.0). Core features included:

- **Sign-In**: Google Sign-In and Apple Sign-In. New users auto-create an account and a personal voice channel on first login.
- **Home Screen**: Displays the user's own channel card and a list of channels they follow, sorted by most recently active.
- **Voice Rooms**: Users tap any channel to enter a live WebRTC-powered voice room. Supports multiple simultaneous participants, mute/unmute, and speaker/earpiece toggle.
- **Search & Follow**: Full-text fuzzy search of users by display name or channel name; follow/unfollow with one tap.
- **Profile Editing**: Users can update their display name and channel name from the Profile screen.
- **Settings**: Appearance (Light/Dark/System), Help Center, Contact Support, Privacy Policy, and app version info.
- **Onboarding**: First-launch carousel (3 slides) and a home-screen usage guide overlay (step-by-step spotlight tutorial).
- **Monetization**: One-time purchase activation (Apple IAP, non-consumable). No subscriptions. No ads.

---

### 2. 隐私情况 (Privacy)

| Permission | Reason | When Requested |
|---|---|---|
| Microphone | Real-time voice chat in voice rooms | First time user enters a voice room |

- **No location data** is collected.
- **No contacts** are accessed.
- **No camera** is used.
- Sign-In data (name, email, avatar URL) is used solely for in-app identity display and stored on the app's backend. Not shared with or sold to third parties.
- Apple Sign-In: email is requested as optional; the app functions fully with the "Hide My Email" relay address.
- All API traffic is transmitted over HTTPS/TLS.
- Privacy Policy URL: `https://playvoice.app/privacy`

**App Privacy Nutrition Label (AppStore Connect)**:
- Data Used to Track You: None
- Data Linked to You: Name, Email Address, User ID (used for account management)
- Data Not Linked to You: None additional

---

### 3. 基础功能和如何测试 (How to Test)

**Test Accounts**: Reviewers may use any valid Google account or Apple ID.

**Step-by-Step Test Flow**:

1. **Launch** — Splash screen plays (1.5 s), then the onboarding carousel appears (3 slides, swipeable). Tap "Get Started."
2. **Sign In** — Tap "Continue with Google" or the Apple Sign-In button. Complete OAuth flow.
3. **Home Screen** — After login, the Home screen shows your personal channel card at the top and an empty followed-channels list (with empty-state guidance).
4. **Overlay Guide** — On first load, a semi-transparent step-by-step guide highlights: (a) My Channel card, (b) Search button, (c) Channel list area.
5. **Search & Follow** — Tap "Search," type any query. Tap "Follow" next to a result. Return to Home — the followed channel appears in the list.
6. **Enter Voice Room** — Tap your own channel card or any followed channel. The voice room opens, connects via WebRTC, and displays online members. Grant microphone permission when prompted.
7. **Controls** — Test Mute / Unmute, Speaker / Earpiece toggle, and the Leave button.
8. **Profile** — Tap the person icon (top-right) → Profile. View display name and channel name. Tap Channel Name → edit and save.
9. **Settings** — Tap the gear icon (top-right) → Settings. Test Appearance toggle (Light / Dark / System). Verify Help Center and Privacy Policy links open Safari.
10. **Sign Out / Re-login** — Close and relaunch the app. Token persistence means the user goes directly to Home without re-authentication.

**Voice Room Testing with Two Accounts**:
For reviewer convenience, a demo video showing two-user voice communication is attached in the App Review Information section (upload via App Store Connect).

---

### 4. 产品亮点 (Product Highlights)

- **WebRTC-powered audio** — uses a native `WebRTC.xcframework` for sub-200 ms audio latency, identical stack to professional voice tools.
- **No subscription fatigue** — single one-time IAP unlocks everything permanently; no upsells, no trial expiry.
- **Minimal permission footprint** — only microphone, only when needed.
- **Apple Sign-In support** — fully compliant with Apple's requirement that apps offering third-party login must also offer Apple Sign-In.
- **Light/Dark theme engine** — dynamic `UIColor` providers respect system appearance automatically; user can also override per-preference in Settings.

---

### 5. 是否涉及外部版权内容 (Third-Party IP / Copyright)

**No third-party copyrighted content** is used in the app:

- All icons are from Apple's SF Symbols system library (licensed for use in Apple platform apps).
- The app logo/icon is original artwork created for PlayVoice.
- Audio processing uses WebRTC open-source library (BSD license). No music, no stock imagery, no licensed characters.

---

### 6. 是否有儿童风险 (Child Safety)

- The app is rated **17+** (Frequent/Intense — social interactions with strangers via live voice).
- The app does **not target children under 13** and is not positioned in any child-directed category.
- No COPPA compliance posture is needed as the app explicitly excludes underage users in its Terms of Service.
- Apple Kids Category: **Not applicable**.
- Made for Kids setting in App Store Connect: **No**.
