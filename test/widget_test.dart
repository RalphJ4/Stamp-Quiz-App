import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/main.dart';

void main() {
  testWidgets('App shows Firebase error screen when not initialized',
      (WidgetTester tester) async {
    await tester.pumpWidget(const QuizApp(firebaseInitialized: false));

    expect(find.text('Firebase not configured for this platform'), findsOneWidget);
  });
}
