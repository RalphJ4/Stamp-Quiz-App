import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/widgets/hint_button.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import '../test_helpers.dart';

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
            ],
            child: const HintButton(),
          ),
        );
      },
    );
  }

  testWidgets('renders hint button with lightbulb icon', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });
}
