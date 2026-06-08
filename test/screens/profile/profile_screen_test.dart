import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/profile/profile_screen.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget buildTestApp() {
    final authBloc = FakeAuthBloc()..emit(AuthState(
      initialized: true,
      mode: AuthMode.loggedIn,
      user: AppUser(id: 'test', isGuest: false, email: 'test@test.com', name: 'TestPlayer'),
    ));
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<QuizBloc>.value(value: FakeQuizBloc()),
            ],
            child: const ProfileScreen(),
          ),
        );
      },
    );
  }

  testWidgets('renders profile screen with sections', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('TestPlayer'), findsAtLeastNWidgets(1));
    expect(find.text('Stamp Collector'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Avatar'), findsOneWidget);
  });
}
