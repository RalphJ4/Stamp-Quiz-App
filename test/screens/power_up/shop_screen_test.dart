import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/power_up/shop_screen.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  testWidgets('renders shop with power-up grid', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(
      ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: FakeAuthBloc()),
              BlocProvider<QuizBloc>.value(
                value: FakeQuizBloc(initialState: const QuizState(stamps: 100)),
              ),
              BlocProvider<PowerUpBloc>.value(value: FakePowerUpBloc()),
            ],
            child: const MaterialApp(home: ShopScreen()),
          );
        },
      ),
    );
    await tester.pump();

    expect(find.text('Power-Up Shop'), findsOneWidget);
    expect(find.text('Balance: '), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Time Freeze'), findsOneWidget);
    expect(find.text('Double XP'), findsOneWidget);
    expect(find.text('Extra Hint'), findsOneWidget);
    expect(find.text('Skip Question'), findsOneWidget);
  });
}
