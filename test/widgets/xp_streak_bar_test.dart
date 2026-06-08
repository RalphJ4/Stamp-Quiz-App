import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/widgets/xp_streak_bar.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_state.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  testWidgets('renders stamps and streak info', (tester) async {
    final quizBloc = FakeQuizBloc(initialState: const QuizState(
      stamps: 50,
      bestStreak: 5,
      totalCorrect: 20,
      totalAnswered: 30,
    ));

    await tester.pumpWidget(
      ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: FakeAuthBloc()),
              BlocProvider<QuizBloc>.value(value: quizBloc),
              BlocProvider<PowerUpBloc>.value(value: FakePowerUpBloc()),
            ],
            child: const MaterialApp(home: XpStreakBar()),
          );
        },
      ),
    );
    await tester.pump();

    expect(find.text('Total Stamps'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Best Streak'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
  });
}
