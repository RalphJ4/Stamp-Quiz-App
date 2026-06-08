import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/login_screen.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget wrapApp(Widget child) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return BlocProvider<AuthBloc>.value(
          value: FakeAuthBloc(),
          child: MaterialApp(home: child),
        );
      },
    );
  }

  testWidgets('renders email and password fields and sign-in buttons',
      (tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));
    await tester.pump();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
