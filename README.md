# Stamp Quiz App

A gamified Flutter quiz app where users answer questions, earn digital stamps, and track streaks. Supports email/password registration, Google Sign-In, and anonymous guest sessions with Firebase Authentication and Firestore.

Built with Clean Architecture, Provider for state management, and `responsive_sizer` for adaptive layouts.

---

## Features

- **3 auth modes:** Email/password, Google Sign-In, or anonymous guest
- **5 categories:** Space, Animals, History, Science, Geography — 30 total questions
- **Stamp rewards:** 1–3 stamps per correct answer based on difficulty (Easy/Medium/Hard)
- **Streak tracking:** Current and best streak per user (guest and logged-in data stored separately)
- **Confetti animation:** Celebratory particle burst when earning a stamp
- **Responsive layout:** All screens use `responsive_sizer` (`.w`, `.h`, `.sp`) for any screen size
- **Persistent stats:** Stamps, streaks, and scores saved per user via `SharedPreferences`
- **Guest sessions:** Anonymous play with UUID-based session persistence

---

## Project Structure

```
lib/
  main.dart                                  # Entry point, Firebase init, root Provider + Consumer
  firebase_options.dart                      # Auto-generated FlutterFire config

  domain/
    entities/
      question.dart                          # Question entity, QuestionCategory & QuestionDifficulty enums
    repositories/
      question_repository.dart               # Abstract repository contract
    usecases/
      get_questions.dart                     # Use case: fetch questions from repository

  data/
    models/
      question_model.dart                    # QuestionModel with JSON serialization (extends Question)
    datasources/
      local_question_datasource.dart         # 30 hardcoded questions across 5 categories
    repositories/
      question_repository_impl.dart          # Repository impl delegating to local datasource

  presentation/
    provider/
      quiz_provider.dart                     # Central quiz state (questions, stamps, streaks, stats)
    screens/
      onboarding_screen.dart                 # Landing page: Sign In / Register / Continue as Guest
      login_screen.dart                      # Email/password + Google sign-in form
      register_screen.dart                   # Registration form with validation
      home_screen.dart                       # Main hub: stats, category cards, Start Quiz, sign-out
      category_selection_screen.dart         # Grid of 5 colored category tiles
      quiz_screen.dart                       # Quiz UI: progress bar, options, stamp dialog, confetti
      stamp_card_screen.dart                 # Stamp collection grid (earned vs total)
    widgets/
      guest_banner.dart                      # Amber banner for guest mode users
      stamp_widget.dart                      # Single stamp circle with entrance animation

  services/
    auth_service.dart                        # Firebase Auth wrapper (email, Google, sign-out, reset)
    auth_mode_manager.dart                   # Auth state machine (ChangeNotifier: loggedIn/guest/none)
    guest_session_service.dart               # Guest session UUID persistence via SharedPreferences
    local_storage_service.dart               # Hive abstraction for quiz cache & score history

assets/
  images/
    stamp.png                                # Stamp icon used in animations and launcher icon
```

---

## Setup Instructions

### Prerequisites

- Flutter SDK >=3.7.2
- A Firebase project with Authentication (Email/Password + Google) and Cloud Firestore enabled

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

### 3. Generate launcher icon (optional)

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
| **Onboarding** | Sign In, Register, or Continue as Guest |
| **Home** | View stamps/streaks, tap a category card or Start Quiz |
| **Category Selection** | Pick a category to begin |
| **Quiz** | Tap an answer; correct = stamp + confetti. Finish or tap Next |
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
| `cloud_firestore` | ^5.6.5 | User profile storage |
| `google_sign_in` | ^6.3.0 | Google Sign-In native plugin |
| `shared_preferences` | ^2.5.3 | Guest sessions & stats persistence |
| `hive` / `hive_flutter` | ^2.2.3 | Local quiz cache & score history |
| `confetti` | ^0.8.0 | Stamp-earning celebration animation |
| `logger` | ^2.5.0 | Structured logging for navigation & errors |
| `uuid` | ^4.5.1 | Guest session ID generation |
| `connectivity_plus` | ^6.1.4 | Network connectivity monitoring |

---

## Architecture

The project follows **Clean Architecture** with three layers:

- **`domain/`** — Entities, repository contracts, and use cases (no Flutter dependency)
- **`data/`** — Models (JSON serialization), datasource (30 hardcoded questions), repository implementation
- **`presentation/`** — Provider-driven state, 7 screens, 2 reusable widgets

Cross-cutting **services** handle Firebase Auth, guest sessions, Hive storage, and the auth state machine that bridges authentication mode with the UI.
