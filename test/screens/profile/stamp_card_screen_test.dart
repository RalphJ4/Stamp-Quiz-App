import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/stamp_card_screen.dart';
import '../../test_helpers.dart';

void main() {
  setUpAll(() async => setupFirebase());

  testWidgets('renders stamp card screen', (tester) async {
    await tester.pumpWidget(ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: Scaffold(body: StampCardScreen(earnedStamps: 3, totalStamps: 8)),
        );
      },
    ));

    expect(find.byType(StampCardScreen), findsOneWidget);
  });
}
