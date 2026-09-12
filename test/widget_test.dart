import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_tree/main.dart';

void main() {
  testWidgets('앱이 크래시 없이 첫 프레임을 그린다', (WidgetTester tester) async {
    await tester.pumpWidget(const PrayerTreeApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
