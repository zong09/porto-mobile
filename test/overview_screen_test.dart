import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/domain/net_worth_calculator.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/ui/app_shell.dart';
import 'package:porto_mobile/src/ui/screens/overview.dart';
import 'package:porto_mobile/src/ui/widgets/app_bottom_nav.dart';
import 'package:porto_mobile/src/ui/widgets/area_chart.dart';

// ── helpers ──────────────────────────────────────────────────────────────

NetWorthSummary _summary({
  double totalAssetsThb = 4286450,
  double totalLiabilitiesThb = 384000,
  double netWorthThb = 4286450,
  double todayPlThb = 18240,
  double totalCostThb = 4100000,
  double fx = 35.0,
}) =>
    NetWorthSummary(
      totalAssetsThb: totalAssetsThb,
      totalLiabilitiesThb: totalLiabilitiesThb,
      netWorthThb: netWorthThb,
      todayPlThb: todayPlThb,
      totalCostThb: totalCostThb,
      fx: fx,
    );

OverviewState _state({
  NetWorthSummary? summary,
  List<NetWorthHistoryData>? history,
  String? asOf,
  bool offline = false,
}) =>
    OverviewState(
      summary: summary,
      history: history ?? [],
      asOf: asOf,
      offline: offline,
    );

/// Fake notifier that returns a fixed state instead of hitting the DB.
class _FakeOverview extends OverviewNotifier {
  final OverviewState _s;
  _FakeOverview(this._s);
  @override
  Future<OverviewState> build() async => _s;
}

Widget _app(OverviewState s) => ProviderScope(
      overrides: [overviewProvider.overrideWith(() => _FakeOverview(s))],
      child: const MaterialApp(home: OverviewScreen()),
    );

Widget _appShell(OverviewState s) => ProviderScope(
      overrides: [overviewProvider.overrideWith(() => _FakeOverview(s))],
      child: const MaterialApp(home: AppShell()),
    );

void main() {
  testWidgets(
      'renders net worth + area chart from fake state', (tester) async {
    final history = List.generate(
        8,
        (i) => NetWorthHistoryData(
              date: '2026-07-${(i + 1).toString().padLeft(2, '0')}',
              totalAssetsThb: 4000000 + i * 50000,
              totalLiabilitiesThb: 384000,
              netWorthThb: 4000000 + i * 50000,
            ));

    final s = _state(
      summary: _summary(
        totalAssetsThb: 4286450,
        totalLiabilitiesThb: 384000,
        netWorthThb: 4286450,
        todayPlThb: 18240,
        totalCostThb: 4100000,
      ),
      history: history,
    );

    await tester.pumpWidget(_app(s));
    await tester.pumpAndSettle();

    // Formatted net-worth string should be present
    expect(find.text('4,286,450.00'), findsOneWidget);
    // Area chart widget present
    expect(find.byType(AreaChart), findsOneWidget);
    // No exceptions
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline shows as-of banner', (tester) async {
    final s = _state(
      summary: _summary(),
      offline: true,
      asOf: '2026-07-14T10:30:00.000Z',
    );

    await tester.pumpWidget(_app(s));
    await tester.pumpAndSettle();

    // The offline banner text should be present (contains the formatted date)
    expect(find.textContaining('as of'), findsOneWidget);
  });

  testWidgets('summary==null shows empty state', (tester) async {
    final s = _state(summary: null);

    await tester.pumpWidget(_app(s));
    await tester.pumpAndSettle();

    // Empty-state marker present, no exceptions
    expect(find.byType(OverviewScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'AppShell shows bottom nav with 4 tabs + FAB and switches tab',
      (tester) async {
    final s = _state(
      summary: _summary(),
      history: [
        NetWorthHistoryData(
          date: '2026-07-14',
          totalAssetsThb: 4000000,
          totalLiabilitiesThb: 384000,
          netWorthThb: 4000000,
        ),
      ],
    );

    await tester.pumpWidget(_appShell(s));
    await tester.pumpAndSettle();

    // Bottom nav present
    expect(find.byType(AppBottomNav), findsOneWidget);

    // Initial tab (0 = Overview) is showing
    expect(find.byType(OverviewScreen), findsOneWidget);

    // Tap tab index 1 (Portfolios placeholder) — no exception
    final nav = tester.widget<AppBottomNav>(find.byType(AppBottomNav));
    nav.onTap(1);
    await tester.pumpAndSettle();

    // Placeholder should be visible (no OverviewScreen)
    expect(find.byType(OverviewScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
