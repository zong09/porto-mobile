// Sanity smoke test. The real end-to-end flow lives in
// integration_test/app_smoke_test.dart (T4.2); mounting PortoApp here would
// open the on-device SQLite DB, so this only checks the widget harness works.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('widget test harness builds a MaterialApp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
