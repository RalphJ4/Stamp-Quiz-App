import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
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

  testWidgets('renders registration form fields', (tester) async {
    await tester.pumpWidget(_wrapApp(const RegisterScreen()));
    await tester.pump();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Register'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows error when passwords do not match', (tester) async {
    await tester.pumpWidget(_wrapApp(const RegisterScreen()));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('shows error when password is too short', (tester) async {
    await tester.pumpWidget(_wrapApp(const RegisterScreen()));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(1), '12345');
    await tester.enterText(find.byType(TextFormField).at(2), '12345');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}
