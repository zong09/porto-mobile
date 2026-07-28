// Task 1 coverage — creating an asset from the UI.
//
// Every other portfolios test drives a fake notifier over a FIXED state, which
// structurally cannot see this bug: against an immutable state, a screen that
// reads the snapshot captured at push time and one that re-reads the live node
// render identically. So this test runs the REAL provider graph over an
// in-memory SQLite DB (the seam `smoke_flow.dart` uses) — the only harness in
// which "the new asset appears without popping" can actually fail.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';
import 'package:porto_mobile/src/state/transactions_notifier.dart';
import 'package:porto_mobile/src/ui/screens/portfolios.dart';

void main() {
  testWidgets('create portfolio → add asset, entirely through the UI',
      (tester) async {
    // The default 800x600 surface is too short once a sheet is open.
    tester.view.physicalSize = const Size(2400, 3600); // 800x1200 logical
    addTearDown(tester.view.resetPhysicalSize);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        // displayMoneyProvider awaits this — pin it so no test hits the network.
        fxProvider.overrideWithValue(() async => 35.0),
      ],
      child: MaterialApp(
        // Keeps transactionsProvider alive, which the real app does implicitly:
        // AppShell is an IndexedStack, so TransactionsScreen is mounted (and
        // therefore watching) on every tab. Without a listener the provider is
        // autoDispose'd the instant TransactionSheet's `ref.read` returns, and
        // step 5's write is dropped before it reaches the repo. Pumping
        // PortfoliosScreen alone is the unrealistic part, not the app.
        home: Consumer(builder: (_, ref, _) {
          ref.watch(transactionsProvider);
          return const PortfoliosScreen();
        }),
      ),
    ));
    await tester.pumpAndSettle();

    // ── 1. Create a portfolio ────────────────────────────────────────────
    await tester.tap(find.text('+ สร้างพอร์ต'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'พอร์ตทดสอบ');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    expect(find.text('พอร์ตทดสอบ'), findsOneWidget);

    // ── 2. Open its detail screen ────────────────────────────────────────
    await tester.tap(find.text('พอร์ตทดสอบ'));
    await tester.pumpAndSettle();

    expect(find.byType(PortfolioDetailScreen), findsOneWidget);

    // ── 3. Add an asset from the dashed card ─────────────────────────────
    await tester.tap(find.text('+ เพิ่มสินทรัพย์'));
    await tester.pumpAndSettle();

    expect(find.text('เพิ่มสินทรัพย์'), findsOneWidget,
        reason: 'sheet chrome comes from showPortoSheet');

    await tester.enterText(find.byType(TextField).at(0), 'BTC');
    await tester.enterText(find.byType(TextField).at(1), 'Bitcoin');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    // ── 4. It shows up WITHOUT popping and re-entering ───────────────────
    expect(find.byType(PortfolioDetailScreen), findsOneWidget,
        reason: 'saving must not close the detail screen');
    expect(find.text('Bitcoin'), findsOneWidget,
        reason: 'detail must re-read the live node, not its push-time snapshot');

    // ── 5. Record a buy on it — the dead end task 1 opens up ─────────────
    await tester.tap(find.text('ซื้อเพิ่ม'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '2'); // qty
    await tester.enterText(find.byType(TextField).at(1), '100'); // price
    await tester.tap(find.text('บันทึกรายการ'));
    await tester.pumpAndSettle();

    expect(find.byType(PortfolioDetailScreen), findsOneWidget);
    expect(find.textContaining('qty 2.00'), findsOneWidget,
        reason: 'a saved tx must invalidate portfoliosProvider, or the screen '
            'the user is looking at shows the buy as having changed nothing');
  });
}
