import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/home/home_screen.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/bloc/daily_challenge_bloc.dart';
import 'package:quiz_app/presentation/screens/duel/bloc/duel_bloc.dart';
import 'package:quiz_app/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget buildTestApp() {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: FakeAuthBloc()),
            BlocProvider<QuizBloc>.value(value: FakeQuizBloc()),
            BlocProvider<PowerUpBloc>.value(value: FakePowerUpBloc()),
            BlocProvider<DailyChallengeBloc>.value(
              value: FakeDailyChallengeBloc(initialState: const DailyChallengeState(loading: false)),
            ),
            BlocProvider<DuelBloc>.value(value: FakeDuelBloc()),
            BlocProvider<OnboardingBloc>.value(
              value: FakeOnboardingBloc(initialState: const OnboardingState(loading: false, completed: true)),
            ),
            BlocProvider<LeaderboardBloc>.value(value: FakeLeaderboardBloc()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        );
      },
    );
  }

  testWidgets('renders home screen with title and categories', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Stamp Quiz'), findsOneWidget);
    expect(find.text('Welcome, Challenger!'), findsOneWidget);
    expect(find.text('Duel Mode'), findsOneWidget);
    expect(find.text('Daily Challenge'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Space'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('Geography'), findsOneWidget);
    expect(find.text('Start Quiz'), findsOneWidget);
    expect(find.text('Reset Progress'), findsOneWidget);
  });
}
