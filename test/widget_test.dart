// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:convergence_application/main.dart' as app;

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Launch the real application entry point.
    app.main();
    await tester.pumpAndSettle();

    // Verify that the app starts without throwing.
    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
