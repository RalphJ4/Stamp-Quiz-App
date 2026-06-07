# Stamp Quiz App

A gamified Flutter quiz app with a dark fantasy palette, power-up shop, multiplayer duels, daily challenges, and a leaderboard. Supports email/password registration, Google Sign-In, and anonymous guest sessions via Firebase Auth + Firestore.

Built with Clean Architecture, **BLoC** for state management, and `responsive_sizer` for adaptive layouts.

---

## Features

### Core Quiz
- **5 categories:** Space, Animals, History, Science, Geography — **332 questions** across 3 difficulty levels (easy / medium / hard)
- **Randomized selection:** Each quiz draws a fixed question count (8 for Space, 6 for others) randomly from the full pool — every quiz feels different
- **Per-question countdown timer** (30s) — auto-advances on expiry, auto-finishes on last question
- **Time Freeze** power-up pauses the timer for the current question (consumed on answer)
- **Stamp rewards:** 1–3 stamps per correct answer based on difficulty; penalty when using hint (reward halved)
- **Streak tracking:** Current and best streak persisted across sessions
- **Confetti animation** on correct answer with stamp-earning dialog

### Hint System
- 3 free hints per quiz session; each eliminates 2 wrong options
- **Extra Hint** power-up restores a hint mid-quiz

### Power-Up Shop
- 4 power-ups purchased with stamps — inventory persisted in Firestore:

| Power-Up | Cost | Effect |
|---|---|---|
| Double XP | 50 | Next correct answer gives 2× stamps |
| Extra Hint | 20 | +1 hint for the current session |
| Skip Question | 40 | Wrong answer keeps your streak alive |
| Time Freeze | 30 | Pauses the timer for the current question |

- Activate power-ups from the in-quiz power-up bar (horizontal scroll below options)
- Active effects shown as coloured badges in the app bar
- Effects consumed on use (one-time per question)

### Daily Challenges
- Fresh 5-question set every day (date-keyed in Firestore)
- Completion tracked per user; daily streak persisted in SharedPreferences

### Multiplayer Duel Mode
- Create or join a real-time duel via **6-character shareable code**
- Both players answer the same 5 questions against a **60-second countdown**
- Auto-finishes when timer expires — higher score wins
- XP awarded before duel data is cleaned up (prevents leaderboard sync issues)
- Winner gets +50 XP, loser gets +20 XP participation reward
- Confetti celebration for the winner

### Leaderboard (3 tabs)
- **All-Time / This Week / This Month** — top 100 ranked by XP
- **Force sync** on tap — resets the sync tracker and re-fetches fresh data from Firestore
- XP auto-syncs to Firestore on every stamp change (immediate write, debounced full refresh)
- Auto-detects quiz stamp changes via Bloc subscription
- Guest users are excluded from leaderboard writes
- Sticky "Your Rank" footer with medal icons for top 3

### Gamified Onboarding
- 5-step PageView: Welcome → Name Entry → Avatar Colour → Tutorial Question → Congratulations
- Name validation, 6 preset avatar colours, shake-on-wrong tutorial question
- Completion stored in SharedPreferences; skipped in subsequent launches

### Profile & Achievements
- **8 avatar presets:** Hero, Wizard, Archer, Knight, Dragon, Fox, Eagle, Wolf — each with a unique emoji + colour
- **Dynamic title tiers** based on XP: Stamp Collector → Quiz Apprentice → Stamp Enthusiast → Quiz Master → Stamp Virtuoso → Quiz Legend → Grand Sage
- **Level system:** `floor(sqrt(XP / 100)) + 1` with animated progress bar
- **10 achievement badges:** 1st Quiz, 10 Quizzes, 100% Accuracy, 10 Streak, 50 Streak, 100 Stamps, 500 Stamps, Hint User, Daily Player, Duelist — unlocked against stats
- **Settings toggle:** Switch between showcase view (avatar, level, stats, badges, streak) and settings view (avatar picker, name edit, password change, sign out)
- **Sign out** with confirmation dialog

### Authentication
- 3 modes: Email/password, Google Sign-In, or anonymous guest
- **Human-friendly error messages:** Firebase auth errors (wrong password, user not found, etc.) mapped to clear, user-facing copy
- **Blank field validation:** Client-side check for empty email/password before Firebase call
- Per-user stat isolation in SharedPreferences via storage prefix

### Visual Theme
- Dark palette: backgrounds `#0D0D1A` / `#1A1A2E` / `#16213E`
- Gold accent `#E8B86D`, purple `#7B2FBE`
- All sizing via `responsive_sizer` (`.w`, `.h`, `.sp`)
- **Animations:** Correct answer pulse, wrong answer shake, stamp counter bounce, rank change highlight on leaderboard

---

## Project Structure

```
lib/
  main.dart                                   # Entry point, Firebase init, MultiBlocProvider, onboarding gate
  firebase_options.dart                       # Auto-generated FlutterFire config

  domain/
    entities/
      daily_challenge.dart                    # DailyChallenge entity
      duel.dart                               # DuelState, DuelStatus enum
      leaderboard_entry.dart                  # LeaderboardEntry entity
      leaderboard_period.dart                 # LeaderboardPeriod enum
      power_up.dart                           # PowerUpType enum with label/cost/icon/color/firestoreKey
      question.dart                           # Question entity, QuestionCategory & QuestionDifficulty enums
    repositories/
      question_repository.dart                # Abstract repository contract
    usecases/
      get_questions.dart                      # Use case: fetch questions from repository

  data/
    models/
      daily_challenge_model.dart              # DailyChallengeModel Firestore serialization
      question_model.dart                     # QuestionModel JSON serialization
    datasources/
      daily_challenge_datasource.dart         # Firestore CRUD + local streak
      duel_datasource.dart                    # Firestore create/join/stream/submit/finish/delete
      leaderboard_datasource.dart             # Firestore period-ordered queries + syncXp
      local_question_datasource.dart          # 332 questions across 5 categories (hardcoded)
      power_up_shop_datasource.dart           # Firestore inventory fetch/purchase/decrement (transactional)
    repositories/
      question_repository_impl.dart           # Repository impl delegating to local datasource

  presentation/
    screens/
      auth/
        bloc/                                 # AuthBloc — login/register/guest state machine
        login_screen.dart                     # Email/password + Google sign-in form
        register_screen.dart                  # Registration form with validation
      daily_challenge/
        bloc/                                 # DailyChallengeBloc — daily set loading/completion
        daily_challenge_screen.dart           # Daily challenge card list with countdown
      duel/
        bloc/                                 # DuelBloc — create/join/stream/submit/finish + XP reward
        duel_screen.dart                      # Lobby entry, waiting lobby, active duel with HUD
      home/
        bloc/                                 # OnboardingBloc — wizard state, shared prefs persistence
        home_screen.dart                      # Main hub: stats, daily challenge, duel, category grid, XpStreakBar
      leaderboard/
        bloc/                                 # LeaderboardBloc — 3-tab lazy loading, auto-XP sync, forceSync
        leaderboard_screen.dart               # TabBar with 3 periods, ranked list, sticky "Your Rank"
      onboarding/
        gamified_onboarding_screen.dart       # 5-step PageView (Welcome/Name/Avatar/Tutorial/Congratulations)
        onboarding_screen.dart                # Legacy landing page: Sign In / Register / Guest
      power_up/
        bloc/                                 # PowerUpBloc — inventory, activate/consume lifecycle
        shop_screen.dart                      # 2x2 power-up grid with purchase/owned/locked states
      profile/
        profile_screen.dart                   # Full profile: 8 avatars, level, stats, badges, streak
        badges_screen.dart                    # Badge collection
        stamp_card_screen.dart                # Stamp collection grid (earned vs total)
      quiz/
        bloc/                                 # QuizBloc — questions, stamps, streaks, timer, hints, pause/resume
        category_selection_screen.dart        # Grid of 5 coloured category tiles
        quiz_screen.dart                      # Quiz UI: timer, progress bar, options, hints, power-ups, confetti
    widgets/
      guest_banner.dart                       # Amber banner for guest mode users
      stamp_widget.dart                       # Single stamp circle with entrance animation
      hint_button.dart                        # Animated hint button
      xp_streak_bar.dart                      # Stats bar: stamps, accuracy, best streak + power-up pills
      level_up_overlay.dart                   # Level-up modal overlay
      badge_unlock_sheet.dart                 # Badge unlock bottom sheet

  services/
    auth_service.dart                         # Firebase Auth wrapper (email, Google, sign-out, reset)
    guest_session_service.dart                # Guest session UUID persistence via SharedPreferences
    local_storage_service.dart                # Hive abstraction for quiz cache & score history

functions/
  index.js                                    # Cloud Functions: scheduled weekly/monthly XP reset
  src/index.ts                                # TypeScript source for Cloud Functions

firestore.rules                               # Firestore security rules
```

---

## Setup Instructions

### Prerequisites

- Flutter SDK >=3.7.2
- A Firebase project with Authentication (Email/Password + Google), Cloud Firestore, and Cloud Functions enabled

### 1. Clone & install

```sh
git clone https://github.com/RalphJ4/Stamp-Quiz-App.git
cd stamp_quiz_app
flutter pub get
```

### 2. Configure Firebase

```sh
# Install the FlutterFire CLI if you haven't already
dart pub global activate flutterfire_cli

# Configure Firebase for your platforms
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This regenerates `lib/firebase_options.dart` with your project's credentials.

### 3. Deploy Firestore rules & Cloud Functions

```sh
firebase deploy --only firestore:rules
firebase deploy --only functions
```

### 4. Generate launcher icon (optional)

```sh
flutter pub run flutter_launcher_icons:main
```

---

## Running the App

```sh
flutter run
```

Supports Android, iOS, and Web.

---

## Usage

| Screen | Action |
|--------|--------|
| **Onboarding** | 5-step intro (Welcome → Name → Avatar → Tutorial → Congrats) |
| **Auth** | Sign In, Register, or Continue as Guest |
| **Home** | View stamps/streaks, daily challenge card, duel card, shop/leaderboard buttons, category grid |
| **Category Selection** | Pick a category to begin |
| **Quiz** | Tap an answer within the 30s timer; correct = stamp + confetti. Use hints (top-right) or activate power-ups (bottom bar) |
| **Daily Challenge** | Complete the 5-question daily set for bonus stamps |
| **Shop** | Buy power-ups with stamps |
| **Duel** | Create a lobby or join with a code — 60s real-time duel |
| **Leaderboard** | Tap the leaderboard icon to force-refresh; switch between All-Time / This Week / This Month tabs |
| **Profile** | 8 avatar presets, level bar, stats cards, achievement badges, streak display |
| **Stamp Card** | View all stamps earned per category |
| **Guest Banner** | Tap to sign in and save guest progress |

- **Sign Out:** Tap the profile avatar (top-right) → Profile → gear icon → Sign Out
- **Reset Progress:** Tap "Reset Progress" at the bottom of Home

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.0.0 | State management |
| `equatable` | ^2.0.7 | Value equality for BLoC states |
| `responsive_sizer` | ^3.3.1 | Responsive `.w` / `.h` / `.sp` units |
| `firebase_core` | ^3.13.0 | Firebase initialization |
| `firebase_auth` | ^5.5.1 | Authentication (email + Google) |
| `cloud_firestore` | ^5.6.5 | User profiles, duels, leaderboard, daily challenges, inventory |
| `google_sign_in` | ^6.3.0 | Google Sign-In native plugin |
| `shared_preferences` | ^2.5.3 | Guest sessions, stats, onboarding completion |
| `hive` / `hive_flutter` | ^2.2.3 | Local quiz cache & score history |
| `confetti` | ^0.8.0 | Stamp-earning celebration animation |
| `logger` | ^2.5.0 | Structured logging for navigation & errors |
| `uuid` | ^4.5.1 | Guest session ID generation |
| `connectivity_plus` | ^6.1.4 | Network connectivity monitoring |

---

## Architecture

The project follows **Clean Architecture** with three layers:

- **`domain/`** — Entities, repository contracts, and use cases (no Flutter dependency)
- **`data/`** — Models (serialization), datasources (local + Firestore), repository implementations
- **`presentation/`** — BLoC-driven state management, screens, widgets

Cross-cutting **services** handle Firebase Auth, guest sessions, and Hive storage.

### Firestore Collections

| Collection | Reads | Writes | Purpose |
|---|---|---|---|
| `users/{uid}` | authenticated | owner only | Profile (displayName, email) + inventory map |
| `leaderboard/{uid}` | authenticated | owner only | Lightweight XP snapshot (allTime/weekly/monthly) |
| `dailyChallenges/{dateKey}` | authenticated | admin only (Cloud Function) | Daily question set + `completedBy` array |
| `duels/{duelId}` | authenticated | host/guest only | Real-time duel state; auto-deleted after finish |

### Cloud Functions

- **`resetWeeklyXp`** — Runs every Sunday midnight; sets `weeklyXp = 0` on all leaderboard entries
- **`resetMonthlyXp`** — Runs on the 1st of every month; sets `monthlyXp = 0` on all leaderboard entries
