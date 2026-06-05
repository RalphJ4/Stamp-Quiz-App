# Stamp Quiz App

A gamified Flutter quiz app with a dark fantasy palette, power-up shop, multiplayer duels, daily challenges, and a leaderboard. Supports email/password registration, Google Sign-In, and anonymous guest sessions via Firebase Auth + Firestore.

Built with Clean Architecture, Provider for state management, and `responsive_sizer` for adaptive layouts.

---

## Features

### Core Quiz
- **5 categories:** Space, Animals, History, Science, Geography — 30+ questions with difficulty levels
- **Per-question countdown timer** (30s) — auto-advances on expiry, auto-finishes on last question
- **Stamp rewards:** 1–3 stamps per correct answer based on difficulty
- **Streak tracking:** Current and best streak; streak preserved on wrong answer if Skip Question is active
- **Confetti animation** on correct answer

### Hint System
- 3 free hints per quiz session; each eliminates 2 wrong options
- Shake/bounce animation on hint use, SnackBar penalty notification
- **Extra Hint** power-up restores a hint mid-quiz

### Power-Up Shop
- 4 power-ups purchased with stamps — inventory persisted in Firestore:

| Power-Up | Cost | Effect |
|---|---|---|
| Double XP | 50 | Next correct answer gives 2× stamps |
| Extra Hint | 20 | +1 hint for the current session |
| Skip Question | 40 | Wrong answer keeps your streak alive |
| Time Freeze | 30 | +10 seconds on timed questions |

- Activate power-ups from the in-quiz power-up bar (horizontal scroll below options)
- Active effects shown as coloured badges in the app bar

### Daily Challenges
- Fresh 5-question set every day (date-keyed in Firestore)
- Completion tracked per user; daily streak persisted in SharedPreferences

### Multiplayer Duel Mode
- Create or join a real-time duel via shareable code
- Both players answer the same 5 questions against a **60-second countdown**
- Auto-finishes when timer expires — higher score wins
- Auto-deletes the Firestore duel document 3 seconds after finish (no orphaned data)
- Winner gets +50 XP, loser gets +20 XP participation reward
- Confetti celebration for the winner

### Leaderboard (3 tabs)
- **All-Time / This Week / This Month** — top 100 ranked by XP
- XP auto-syncs to Firestore on every stamp change (immediate write, debounced full refresh)
- Guest users are excluded from leaderboard writes
- Sticky "Your Rank" footer with medal icons for top 3

### Gamified Onboarding
- 5-step PageView: Welcome → Name Entry → Avatar Colour → Tutorial Question → Congratulations
- Name validation, 6 preset avatar colours, shake-on-wrong tutorial question
- Completion stored in SharedPreferences; skipped in subsequent launches

### Authentication
- 3 modes: Email/password, Google Sign-In, or anonymous guest
- Seamless state machine (`AuthModeManager`) bridging guest UUID and Firebase UID
- Per-user stat isolation in SharedPreferences via storage prefix

### Visual Theme
- Dark palette: backgrounds `#0D0D1A` / `#1A1A2E` / `#16213E`
- Gold accent `#E8B86D`, purple `#7B2FBE`
- All sizing via `responsive_sizer` (`.w`, `.h`, `.sp`)

---

## Project Structure

```
lib/
  main.dart                                   # Entry point, Firebase init, MultiProvider, onboarding gate
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
      local_question_datasource.dart          # 30+ hardcoded questions across 5 categories
      power_up_shop_datasource.dart           # Firestore inventory fetch/purchase/decrement (transactional)
    repositories/
      question_repository_impl.dart           # Repository impl delegating to local datasource

  presentation/
    provider/
      daily_challenge_provider.dart           # Daily challenge state with auth change reload
      duel_provider.dart                      # Real-time Firestore stream, 60s countdown, auto-finish
      leaderboard_provider.dart               # 3-tab lazy loading, auto-XP sync (immediate write + debounced refresh)
      onboarding_provider.dart                # 5-step wizard state, SharedPreferences persistence
      power_up_provider.dart                  # Firestore inventory, activate/consume lifecycle
      quiz_provider.dart                      # Central quiz state (questions, stamps, streaks, timer, hints, power-up integration)
    screens/
      gamified_onboarding_screen.dart         # 5-step PageView (Welcome/Name/Avatar/Tutorial/Congratulations)
      onboarding_screen.dart                  # Legacy landing page: Sign In / Register / Continue as Guest
      login_screen.dart                       # Email/password + Google sign-in form
      register_screen.dart                    # Registration form with validation
      home_screen.dart                        # Main hub: stats, daily challenge card, duel card, shop/leaderboard buttons, category grid, XpStreakBar
      category_selection_screen.dart          # Grid of 5 coloured category tiles
      quiz_screen.dart                        # Quiz UI: timer, progress bar, options, hint button, power-up bar, stamp dialog, confetti
      daily_challenge_screen.dart             # Daily challenge card list with countdown
      shop_screen.dart                        # 2×2 power-up grid with purchase/owned/locked states
      duel_screen.dart                        # Lobby entry, waiting lobby, active duel with HUD, winner announcement + confetti
      leaderboard_screen.dart                 # TabBar with 3 periods, ranked list, sticky "Your Rank" footer
      stamp_card_screen.dart                  # Stamp collection grid (earned vs total)
      profile_screen.dart                     # User profile with stats
      badges_screen.dart                      # Badge collection
    widgets/
      guest_banner.dart                       # Amber banner for guest mode users
      stamp_widget.dart                       # Single stamp circle with entrance animation
      hint_button.dart                        # Shake/bounce animated hint button with SnackBar penalty
      xp_streak_bar.dart                      # Stats bar: stamps, accuracy, best streak + active power-up pills
      level_up_overlay.dart                   # Level-up modal overlay
      badge_unlock_sheet.dart                 # Badge unlock bottom sheet

  services/
    auth_service.dart                         # Firebase Auth wrapper (email, Google, sign-out, reset)
    auth_mode_manager.dart                    # Auth state machine (ChangeNotifier: loggedIn/guest/none)
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
| **Leaderboard** | Switch between All-Time / This Week / This Month tabs |
| **Stamp Card** | View all stamps earned per category |
| **Guest Banner** | Tap to sign in and save guest progress |

- **Sign Out:** Tap the profile avatar (top-right) → "Sign Out"
- **Reset Progress:** Tap "Reset Progress" at the bottom of Home

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.5 | State management |
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
- **`presentation/`** — Provider-driven state, screens, widgets

Cross-cutting **services** handle Firebase Auth, guest sessions, Hive storage, and the auth state machine.

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
