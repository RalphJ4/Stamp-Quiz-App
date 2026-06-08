import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/onboarding/gamified_onboarding_screen.dart';
import 'package:quiz_app/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  Widget _wrapApp(Widget child) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: BlocProvider<OnboardingBloc>.value(
            value: FakeOnboardingBloc(initialState: const OnboardingState(loading: false, completed: false)),
            child: child,
          ),
        );
      },
    );
  }

  testWidgets('renders welcome step initially', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(_wrapApp(GamifiedOnboardingScreen(onComplete: () {})));
    await tester.pump();

    expect(find.text('Stamp Quiz'), findsOneWidget);
    expect(find.text("Let's Start!"), findsOneWidget);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
