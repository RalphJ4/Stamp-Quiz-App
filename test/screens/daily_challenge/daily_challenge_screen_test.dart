import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/bloc/daily_challenge_bloc.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/bloc/daily_challenge_state.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/daily_challenge_screen.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
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
              BlocProvider<DailyChallengeBloc>.value(
                value: FakeDailyChallengeBloc(initialState: const DailyChallengeState(loading: true)),
              ),
            ],
            child: const DailyChallengeScreen(),
          ),
        );
      },
    );
  }

  testWidgets('shows loading indicator initially', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders daily challenge title', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.text('Daily Challenge'), findsOneWidget);
  });
}
