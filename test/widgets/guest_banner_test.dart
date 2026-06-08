import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/widgets/guest_banner.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  testWidgets('shows nothing when not guest', (tester) async {
    await tester.pumpWidget(ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: FakeAuthBloc(),
            child: const GuestBanner(),
          ),
        );
      },
    ));
    await tester.pump();

    expect(find.text('Guest Mode — Sign in to save your progress!'), findsNothing);
  });
}
