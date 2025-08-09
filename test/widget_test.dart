// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:speech_translation_app/main.dart';

void main() {
  testWidgets('Speech Translation App loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpeechTranslationApp());

    // Verify that the app title is displayed.
    expect(find.text('Speech Translation'), findsOneWidget);
    
    // Verify that the main screen elements are present.
    expect(find.text('Target Language'), findsOneWidget);
    expect(find.text('Record Audio'), findsOneWidget);
  });
}
