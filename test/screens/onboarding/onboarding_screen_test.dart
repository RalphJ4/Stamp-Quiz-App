import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:quiz_app/presentation/screens/auth/login_screen.dart';
import 'package:quiz_app/presentation/screens/auth/register_screen.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget _wrapApp(Widget child) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return BlocProvider<AuthBloc>.value(
          value: FakeAuthBloc(),
          child: MaterialApp(home: child),
        );
      },
    );
  }

  testWidgets('renders title and auth buttons', (tester) async {
    await tester.pumpWidget(_wrapApp(const OnboardingScreen()));
    await tester.pump();

    expect(find.text('Stamp Quiz'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });

  testWidgets('tap Sign In navigates to LoginScreen', (tester) async {
    await tester.pumpWidget(_wrapApp(const OnboardingScreen()));
    await tester.pump();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('tap Register navigates to RegisterScreen', (tester) async {
    await tester.pumpWidget(_wrapApp(const OnboardingScreen()));
    await tester.pump();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
