import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    as firebase_core_test;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_state.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_state.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/bloc/daily_challenge_bloc.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/bloc/daily_challenge_state.dart';
import 'package:quiz_app/presentation/screens/duel/bloc/duel_bloc.dart';
import 'package:quiz_app/presentation/screens/duel/bloc/duel_state.dart';
import 'package:quiz_app/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:quiz_app/presentation/screens/onboarding/bloc/onboarding_state.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_state.dart';
import 'package:quiz_app/domain/entities/question.dart';

/// Initialize Firebase for tests before any test runs.
Future<void> setupFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  firebase_core_test.setupFirebaseCoreMocks();
  SharedPreferences.setMockInitialValues({});
  await Firebase.initializeApp();
}

class FakeAuthBloc extends AuthBloc {
  FakeAuthBloc({AuthState? initialState}) : super(skipInit: true) {
    if (initialState != null) emit(initialState);
  }

  @override
  void add(AuthEvent event) {
    if (event is AuthStartGuestSession) {
      emit(state.copyWith(
        mode: AuthMode.guest,
        user: AppUser(id: 'test-guest', isGuest: true),
      ));
    } else if (event is AuthSignInWithEmail) {
      emit(state.copyWith(
        mode: AuthMode.loggedIn,
        user: AppUser(id: 'test-user', email: event.email, isGuest: false),
      ));
    } else if (event is AuthSignOut) {
      emit(const AuthState(mode: AuthMode.none, initialized: true));
    }
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}

class FakeQuizBloc extends QuizBloc {
  FakeQuizBloc({QuizState? initialState, AuthBloc? authBloc})
      : super(authBloc ?? FakeAuthBloc(), skipLoad: true) {
    if (initialState != null) emit(initialState);
  }

  @override
  Future<void> close() async {
    await super.close();
  }

  @override
  int questionCountForCategory(QuestionCategory category) => 10;
}

class FakePowerUpBloc extends PowerUpBloc {
  FakePowerUpBloc({PowerUpState? initialState, AuthBloc? authBloc, QuizBloc? quizBloc})
      : super(authBloc ?? FakeAuthBloc(), quizBloc ?? FakeQuizBloc()) {
    if (initialState != null) emit(initialState);
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}

class FakeDailyChallengeBloc extends DailyChallengeBloc {
  FakeDailyChallengeBloc({DailyChallengeState? initialState, AuthBloc? authBloc})
      : super(authBloc ?? FakeAuthBloc(), skipTimer: true) {
    if (initialState != null) emit(initialState);
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}

class FakeDuelBloc extends DuelBloc {
  FakeDuelBloc({DuelBlocState? initialState, AuthBloc? authBloc, QuizBloc? quizBloc})
      : super(authBloc ?? FakeAuthBloc(), quizBloc ?? FakeQuizBloc()) {
    if (initialState != null) emit(initialState);
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}

class FakeOnboardingBloc extends OnboardingBloc {
  FakeOnboardingBloc({OnboardingState? initialState}) : super() {
    if (initialState != null) emit(initialState);
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}

class FakeLeaderboardBloc extends LeaderboardBloc {
  FakeLeaderboardBloc({LeaderboardState? initialState, AuthBloc? authBloc, QuizBloc? quizBloc})
      : super(authBloc ?? FakeAuthBloc(), quizBloc ?? FakeQuizBloc()) {
    if (initialState != null) emit(initialState);
  }

  @override
  Future<void> close() async {
    await super.close();
  }

  @override
  void forceSync() {}
}
