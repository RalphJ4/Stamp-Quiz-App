import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/duel/duel_screen.dart';
import 'package:quiz_app/presentation/screens/duel/bloc/duel_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget _buildTestApp() {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: FakeAuthBloc()),
              BlocProvider<QuizBloc>.value(value: FakeQuizBloc()),
              BlocProvider<DuelBloc>.value(value: FakeDuelBloc()),
              BlocProvider<LeaderboardBloc>.value(value: FakeLeaderboardBloc()),
            ],
            child: const DuelScreen(),
          ),
        );
      },
    );
  }

  testWidgets('renders lobby entry screen', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.text('Duel Mode'), findsOneWidget);
    expect(find.text('Create Duel'), findsOneWidget);
    expect(find.text('Challenge a friend in real-time!'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
  });
}
