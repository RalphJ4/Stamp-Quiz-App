import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/category_selection_screen.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import '../../test_helpers.dart';

Widget _buildTestApp() {
  return ResponsiveSizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: FakeAuthBloc()),
            BlocProvider<QuizBloc>.value(value: FakeQuizBloc()),
          ],
          child: const CategorySelectionScreen(),
        ),
      );
    },
  );
}

void main() {
  setUpAll(() async => setupFirebase());

  testWidgets('renders category grid with 5 categories', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.text('Choose a Category'), findsOneWidget);
    expect(find.text('Space'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('Geography'), findsOneWidget);
  });
}
