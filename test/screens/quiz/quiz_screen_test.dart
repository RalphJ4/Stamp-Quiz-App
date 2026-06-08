import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/quiz_screen.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget buildTestApp(QuizState? quizState) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: FakeAuthBloc()),
            BlocProvider<QuizBloc>.value(
              value: FakeQuizBloc(initialState: quizState ?? const QuizState(quizStarted: true)),
            ),
            BlocProvider<PowerUpBloc>.value(value: FakePowerUpBloc()),
          ],
          child: const MaterialApp(home: QuizScreen()),
        );
      },
    );
  }

  testWidgets('shows loading when questions empty', (tester) async {
    await tester.pumpWidget(buildTestApp(const QuizState()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders question and options when data loaded', (tester) async {
    final sampleQuestions = [
      Question(
        id: 'q1',
        question: 'What is the capital of France?',
        options: ['Paris', 'London', 'Berlin', 'Madrid'],
        correctIndex: 0,
        category: QuestionCategory.geography,
        difficulty: QuestionDifficulty.easy,
      ),
    ];

    await tester.pumpWidget(buildTestApp(QuizState(
      questions: sampleQuestions,
      allQuestions: sampleQuestions,
      quizStarted: true,
      remainingSeconds: 30,
    )));
    await tester.pump();

    expect(find.text('What is the capital of France?'), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
    expect(find.text('Berlin'), findsOneWidget);
    expect(find.text('Madrid'), findsOneWidget);
  });
}
