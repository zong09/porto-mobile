import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/prices/price_history_client.dart';
import 'package:porto_mobile/src/state/settings_notifier.dart';
import 'package:porto_mobile/src/ui/screens/settings.dart';
import 'package:porto_mobile/src/ui/widgets/area_chart.dart';
import 'package:porto_mobile/src/ui/widgets/chart_sheet.dart';

// ---------------------------------------------------------------------------
// Fake notifier — provider-override pattern per T3.09 brief
// ---------------------------------------------------------------------------

class _FakeSettings extends SettingsNotifier {
  final SettingsState _s;
  String? lastCurrency;
  String? lastLanguage;

  _FakeSettings(this._s);

  @override
  Future<SettingsState> build() async => _s;

  @override
  Future<void> setCurrency(String v) async {
    lastCurrency = v;
  }

  @override
  Future<void> setLanguage(String v) async {
    lastLanguage = v;
  }

  @override
  Future<Map<String, dynamic>> exportToJson() async => {};

  @override
  Future<void> importFromJson(Map<String, dynamic> d) async {}
}

Widget _app({
  required SettingsState state,
  VoidCallback? onExport,
  VoidCallback? onImport,
}) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => _FakeSettings(state)),
    ],
    child: MaterialApp(
      home: SettingsScreen(onExport: onExport, onImport: onImport),
    ),
  );
}

void main() {
  testWidgets(
      'shows current currency + language',
      (tester) async {
        await tester.pumpWidget(
          _app(
            state: SettingsState(
              displayCurrency: 'THB',
              language: 'th',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('ตั้้งค่า'), findsOneWidget);
        expect(find.text('฿ THB'), findsOneWidget);
        expect(find.text('ไทย'), findsOneWidget);
      });

  testWidgets(
      'tapping currency row toggles THB <-> USD',
      (tester) async {
        final fake = _FakeSettings(
          SettingsState(displayCurrency: 'THB', language: 'th'),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsProvider.overrideWith(() => fake),
            ],
            child: MaterialApp(
              home: SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial display
        expect(find.text('฿ THB'), findsOneWidget);

        // Tap the currency row
        await tester.tap(find.text('฿ THB'));
        await tester.pump();

        // Verify the fake notifier received the call
        expect(fake.lastCurrency, equals('USD'));
      });

  testWidgets(
      'export/import rows invoke callbacks',
      (tester) async {
        var exportFired = false;
        var importFired = false;

        await tester.pumpWidget(
          _app(
            state: SettingsState(
              displayCurrency: 'USD',
              language: 'en',
            ),
            onExport: () => exportFired = true,
            onImport: () => importFired = true,
          ),
        );
        await tester.pumpAndSettle();

        // Tap export row
        await tester.ensureVisible(find.text('สำรองข้อมูลลงไฟล'));
        await tester.tap(find.text('สำรองข้อมูลลงไฟล'));
        await tester.pump();
        expect(exportFired, isTrue);

        // Tap import row
        await tester.ensureVisible(find.text('นำเข้าข้อมูล'));
        await tester.tap(find.text('นำเข้าข้อมูล'));
        await tester.pump();
        expect(importFired, isTrue);
      });

  testWidgets(
      'ChartSheet renders AreaChart from history',
      (tester) async {
        String? lastRange;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChartSheet(
                title: 'Bitcoin · BTC',
                history: const [
                  PricePoint(1, 10),
                  PricePoint(2, 12),
                  PricePoint(3, 11),
                  PricePoint(4, 14),
                ],
                ranges: ['7D', '30D'],
                onRangeChange: (r) => lastRange = r,
              ),
            ),
          ),
        );

        expect(find.byType(AreaChart), findsOneWidget);
        expect(find.text('Bitcoin · BTC'), findsOneWidget);

        // Tap a range pill
        await tester.tap(find.text('30D'));
        await tester.pump();
        expect(lastRange, equals('30D'));
      });

  testWidgets(
      'ChartSheet empty history shows no-data note',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChartSheet(
                title: 'Empty',
                history: const [],
                ranges: ['7D'],
              ),
            ),
          ),
        );

        expect(find.text('ไมมมีข้อมลราคายอนหลง'), findsOneWidget);
        expect(find.byType(AreaChart), findsNothing);
      });
}
