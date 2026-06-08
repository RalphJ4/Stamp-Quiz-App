import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/presentation/widgets/stamp_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  testWidgets('renders earned stamp', (tester) async {
    await tester.pumpWidget(ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: Scaffold(body: StampWidget(isEarned: true)),
        );
      },
    ));
    await tester.pump();

    expect(find.byType(StampWidget), findsOneWidget);
  });

  testWidgets('renders unearned stamp as transparent', (tester) async {
    await tester.pumpWidget(ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          home: Scaffold(body: StampWidget(isEarned: false)),
        );
      },
    ));

    expect(find.byType(StampWidget), findsOneWidget);
  });
}
