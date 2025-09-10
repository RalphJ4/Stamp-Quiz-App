# Stamp Quiz App


A gamified Stamp Quiz App where users answer quiz questions and earn a digital stamp for each correct answer. Stamps are saved across sessions using SharedPreferences. The app is built with Clean Architecture principles and uses Provider for state management. Developed using Flutter version 3.29.0.

---

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Running the App](#running-the-app)
- [Usage](#usage)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Android Release Setup](#Android-Release-Signing-Setup)
- [Dependencies](#dependencies)

---

## Features

- Multiple-choice quiz with progress tracking
- Earn a digital stamp for each correct answer
- Animated, glowing stamp popup with confetti
- Responsive UI using `responsive_sizer`
- Progress bar and motivational messages
- Reset progress at any time

---

## Project Structure

```
lib/
 ├── data/
 │    ├── datasources/
 │    │    └── local_question_datasource.dart
 │    ├── models/
 │    │    └── question_model.dart
 │    ├── repositories/
 │    │    └── question_repository_impl.dart
 ├── domain/
 │    ├── entities/
 │    │    └── question.dart
 │    ├── repositories/
 │    │    └── question_repository.dart
 │    └── usecases/
 │         └── get_questions.dart
 ├── presentation/
 │    ├── provider/
 │    │    └── quiz_provider.dart
 │    ├── screens/
 │    │    ├── home_screen.dart
 │    │    ├── quiz_screen.dart
 │    │    └── stamp_card_screen.dart
 │    └── widgets/
 │         └── stamp_widget.dart
 └── main.dart
assets/
 └── images/
      └── stamp.png
pubspec.yaml
```

---

## Setup Instructions

### 1. **Clone the repository**

```sh
git clone https://github.com/RalphJ4/stamp_quiz_app.git
cd stamp_quiz_app
```

### 2. **Install dependencies**

```sh
flutter pub get
```

### 3. **Add assets**

- Make sure `assets/images/stamp.png` exists.
- The `pubspec.yaml` already includes:
  ```yaml
  assets:
    - assets/images/
  ```

### 4. **Set up launcher icon**

- The `pubspec.yaml` is configured for `flutter_launcher_icons`:
  ```yaml
  flutter_icons:
    android: true
    ios: true
    image_path: "assets/images/stamp.png"
  ```
- Generate the launcher icon:
  ```sh
  flutter pub run flutter_launcher_icons:main
  ```

---

## Running the App

```sh
flutter run
```

---

## Usage

- **Start Quiz:** Tap "Start Quiz" on the home screen.
- **Answer Questions:** Select an answer. Correct answers trigger a stamp popup with confetti.
- **Track Progress:** View your earned stamps and progress bar on the home screen.
- **Reset Progress:** Tap "Reset Progress" to clear your stamps and start over.

---

## Customization

### Change App Name

- **Android:** Edit `android/app/src/main/AndroidManifest.xml`  
  Change `android:label="Your App Name"`
- **iOS:** Edit `ios/Runner/Info.plist`  
  Change `<key>CFBundleDisplayName</key>`

### Change Launcher Icon

- Replace `assets/images/stamp.png` image.
- Run:
  ```sh
  flutter pub run flutter_launcher_icons:main
  ```

### Add/Change Questions

- Edit your quiz data in `quiz_provider.dart` or wherever your questions are defined.

### Responsive Design

- All screens use `.h`, `.w`, and `.sp` from `responsive_sizer` for adaptive layouts.

---

## Troubleshooting

- **ResponsiveSizer Error:**  
  Ensure your app is wrapped with `ResponsiveSizer` in `main.dart`:
  ```dart
  void main() {
    runApp(
      ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return const MaterialApp(
            home: HomeScreen(),
          );
        },
      ),
    );
  }
  ```

- **Uninstall App via ADB:**  
  ```sh
  adb uninstall com.example.quiz_app
  ```

---

## Android Release Signing Setup
Link: https://docs.flutter.dev/deployment/android

To sign your Android release build with a custom keystore:

1. **Generate a Keystore (if you haven't already):**

   ```powershell
   keytool -genkey -v -keystore "$env:USERPROFILE\Downloads\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   Move the generated `upload-keystore.jks` file into your project’s `android` folder.

2. **Configure `key.properties`:**

   In `android/key.properties`, use the following (assuming your keystore is in the `android` folder):

   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

   > **Note:**  
   > If your keystore is in the `android/app` folder, use `storeFile=upload-keystore.jks`.

3. **Clean and Rebuild:**

   ```sh
   flutter clean
   flutter build apk --release
   ```

---

## Dependencies

See [`pubspec.yaml`](pubspec.yaml):

- [provider](https://pub.dev/packages/provider)
- [responsive_sizer](https://pub.dev/packages/responsive_sizer)
- [confetti](https://pub.dev/packages/confetti)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

---
