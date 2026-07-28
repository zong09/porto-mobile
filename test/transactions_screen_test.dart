import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/domain/formatters.dart';
import 'package:porto_mobile/src/state/display_money.dart';
import 'package:porto_mobile/src/state/portfolios_notifier.dart';
import 'package:porto_mobile/src/state/transactions_notifier.dart';
import 'package:porto_mobile/src/ui/screens/transactions.dart';
import 'package:porto_mobile/src/ui/widgets/transaction_sheet.dart';

// ── helpers ────────────────────────────────────────────────────────────────

Transaction _tx({
  String id = 't1',
  String assetId = 'a1',
  String side = 'buy',
  double quantity = 1.0,
  double price = 100.0,
  double fee = 0,
  String date = '2026-07-10',
  String createdAt = '2026-07-10T10:00:00.000Z',
}) =>
    Transaction(
      id: id,
      assetId: assetId,
      side: side,
      quantity: quantity,
      price: price,
      fee: fee,
      date: date,
      createdAt: createdAt,
    );

Asset _asset({
  String id = 'a1',
  String symbol = 'BTC',
  String name = 'Bitcoin',
  String currency = 'USD',
  String type = 'crypto',
  String direction = 'long',
  int sortOrder = 0,
}) =>
    Asset(
      id: id,
      portfolioId: 'p1',
      type: type,
      symbol: symbol,
      name: name,
      currency: currency,
      direction: direction,
      sortOrder: sortOrder,
    );

TxRow _row({Transaction? tx, Asset? asset}) => TxRow(
      tx: tx ?? _tx(),
      asset: asset ?? _asset(),
    );

TxGroup _group({
  String date = '2026-07-10',
  List<TxRow>? rows,
}) =>
    TxGroup(date: date, rows: rows ?? [_row()]);

/// Fake notifier that returns a fixed state instead of hitting the DB.
class _FakeTx extends TransactionsNotifier {
  final TransactionsState _s;
  _FakeTx(this._s);
  @override
  Future<TransactionsState> build() async => _s;
}

Widget _app(TransactionsState s, {DisplayMoney? money}) => ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(() => _FakeTx(s)),
        if (money != null)
          displayMoneyProvider.overrideWith((ref) async => money),
      ],
      child: const MaterialApp(home: TransactionsScreen()),
    );

// ── tests ──────────────────────────────────────────────────────────────────

void main() {
  // ── Hero summary line: Thai labels + THB-normalised totals ────────────
  testWidgets('hero summary labels totals in Thai and normalises USD to THB',
      (tester) async {
    // Regression: the fold seeded the map with Thai labels but wrote keys by the
    // raw side ('buy'/'sell'), so the summary rendered "buy ฿…" in English. It
    // also summed native amounts raw, counting this USD trade as THB.
    await tester.pumpWidget(_app(
      TransactionsState(groups: [
        _group(rows: [
          // 2 × $50 USD = $100 → 3,600 THB at fx 36
          _row(
            tx: _tx(side: 'buy', quantity: 2, price: 50),
            asset: _asset(currency: 'USD'),
          ),
        ]),
      ]),
      money: const DisplayMoney(currency: 'THB', fx: 36),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('ซื้อ ฿3,600.00'), findsOneWidget);
    expect(find.textContaining('buy '), findsNothing);
  });

  testWidgets('hero summary follows the display currency', (tester) async {
    await tester.pumpWidget(_app(
      TransactionsState(groups: [
        _group(rows: [
          // 10 × ฿360 = 3,600 THB → $100 at fx 36
          _row(
            tx: _tx(side: 'buy', quantity: 10, price: 360),
            asset: _asset(currency: 'THB'),
          ),
        ]),
      ]),
      money: const DisplayMoney(currency: 'USD', fx: 36),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining(r'ซื้อ $100.00'), findsOneWidget);
  });

  // ── Test 1: rows grouped under date headers in order ──────────────────

  testWidgets(
      'rows grouped under date headers in order', (tester) async {
    final d1 = '2026-07-12';
    final d2 = '2026-07-10';

    final groups = [
      _group(
        date: d1,
        rows: [
          _row(tx: _tx(date: d1, id: 't1'), asset: _asset(symbol: 'BTC')),
        ],
      ),
      _group(
        date: d2,
        rows: [
          _row(tx: _tx(date: d2, id: 't2'), asset: _asset(symbol: 'ETH')),
        ],
      ),
    ];

    await tester.pumpWidget(_app(TransactionsState(groups: groups)));
    await tester.pumpAndSettle();

    // Both date labels found
    expect(find.text(d1), findsOneWidget);
    expect(find.text(d2), findsOneWidget);

    // First group's row appears before the second's
    final d1Top = tester.getTopLeft(find.text(d1));
    final d2Top = tester.getTopLeft(find.text(d2));
    expect(d1Top.dy < d2Top.dy, isTrue);

    // No exceptions
    expect(tester.takeException(), isNull);
  });

  // ── Test 2: filter pill ซื้อ shows only buys ──────────────────────────

  testWidgets('filter pill ซื้อ shows only buys', (tester) async {
    final groups = [
      _group(
        date: '2026-07-10',
        rows: [
          _row(tx: _tx(side: 'buy', id: 'b1'), asset: _asset(symbol: 'BTC')),
          _row(tx: _tx(side: 'sell', id: 's1'), asset: _asset(symbol: 'ETH')),
        ],
      ),
    ];

    await tester.pumpWidget(_app(TransactionsState(groups: groups)));
    await tester.pumpAndSettle();

    // Both buy and sell rows visible initially
    expect(find.textContaining('ซื้อ BTC'), findsOneWidget);
    expect(find.textContaining('ขาย ETH'), findsOneWidget);

    // Tap the "ซื้อ" pill (second pill)
    final pillFinder = find.text('ซื้อ');
    expect(pillFinder, findsOneWidget);
    await tester.tap(pillFinder);
    await tester.pumpAndSettle();

    // Buy row still present
    expect(find.textContaining('ซื้อ BTC'), findsOneWidget);
    // Sell row gone
    expect(find.textContaining('ขาย ETH'), findsNothing);
  });

  // ── Test 3: form computes มูลค่ารวม = qty*price+fee ──────────────────

  testWidgets('form computes มูลค่ารวม = qty*price+fee', (tester) async {
    final a = _asset(symbol: 'BTC', name: 'Bitcoin');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(() =>
            _FakeTx(const TransactionsState(groups: []))),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TransactionSheet(
            side: 'buy',
            assets: [a],
            initialAsset: a,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Enter qty=2, price=100, fee=5
    await tester.enterText(find.byType(TextField).at(0), '2'); // qty
    await tester.enterText(find.byType(TextField).at(1), '100'); // price
    await tester.enterText(find.byType(TextField).at(2), '5'); // fee
    await tester.pumpAndSettle();

    // Expect text containing '205' (2*100+5)
    expect(find.textContaining('205'), findsOneWidget);
  });

  // ── Test 4: save calls addTransaction ─────────────────────────────────

  testWidgets('save calls addTransaction', (tester) async {
    final a = _asset(id: 'a1', symbol: 'BTC', name: 'Bitcoin');

    // Use a recording fake notifier
    final recorder = _RecordingTx();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(() => recorder),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TransactionSheet(
            side: 'buy',
            assets: [a],
            initialAsset: a,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Enter qty=2, price=100, fee=0
    await tester.enterText(find.byType(TextField).at(0), '2'); // qty
    await tester.enterText(find.byType(TextField).at(1), '100'); // price
    await tester.enterText(find.byType(TextField).at(2), '0'); // fee
    await tester.pumpAndSettle();

    // Tap save
    final saveFinder = find.text('บันทึกรายการ');
    expect(saveFinder, findsOneWidget);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();

    // Verify recorded call
    expect(recorder.lastCall, isNotNull);
    expect(recorder.lastCall!['assetId'], 'a1');
    expect(recorder.lastCall!['side'], 'buy');
    expect(recorder.lastCall!['quantity'], 2.0);
    expect(recorder.lastCall!['price'], 100.0);
  });

  // ── Test 5: price/fee suffixes follow the asset's native currency ──────

  testWidgets('price + fee suffixes follow the asset native currency',
      (tester) async {
    Future<void> pumpFor(Asset a) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TransactionSheet(
              // Distinct key per asset — without it the second pump reuses the
              // existing State and initState never re-picks _selected.
              key: ValueKey(a.id),
              side: 'buy',
              assets: [a],
              initialAsset: a,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    // USD asset — price + fee are entered in USD, so both suffixes show $.
    await pumpFor(_asset(id: 'a1', symbol: 'BTC', currency: 'USD'));
    expect(find.text(r'$'), findsNWidgets(2));
    expect(find.text('฿'), findsNothing);

    // THB asset — both suffixes show ฿.
    await pumpFor(
        _asset(id: 'a2', symbol: 'PTT', currency: 'THB', type: 'th'));
    expect(find.text('฿'), findsNWidgets(2));
    expect(find.text(r'$'), findsNothing);
  });

  // ── Test 6: asset selector actually selects ───────────────────────────

  testWidgets('asset selector opens a picker and switches the asset',
      (tester) async {
    final btc = _asset(id: 'a1', symbol: 'BTC', name: 'Bitcoin');
    final ptt =
        _asset(id: 'a2', symbol: 'PTT', name: 'PTT', currency: 'THB', type: 'th');

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: TransactionSheet(
            side: 'buy',
            assets: [btc, ptt],
            initialAsset: btc,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bitcoin BTC'), findsOneWidget);
    expect(find.text(r'$'), findsNWidgets(2));

    await tester.tap(find.text('เปลี่ยน \u{203A}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PTT PTT'));
    await tester.pumpAndSettle();

    // Selector swapped, and the native-currency suffixes followed it.
    expect(find.text('PTT PTT'), findsOneWidget);
    expect(find.text('Bitcoin BTC'), findsNothing);
    expect(find.text('฿'), findsNWidgets(2));
  });

  // ── Test 7: tapping a row edits the transaction ───────────────────────

  testWidgets('tapping a tx row opens the sheet in edit mode', (tester) async {
    final asset = _asset(id: 'a1', symbol: 'BTC', name: 'Bitcoin');
    final tx = _tx(id: 't9', assetId: 'a1', side: 'buy', quantity: 3, price: 70);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(() => _FakeTx(
              TransactionsState(
                  groups: [_group(rows: [_row(tx: tx, asset: asset)])]),
            )),
        portfoliosProvider.overrideWith(() => _FakeEmptyPortfolios()),
      ],
      child: const MaterialApp(home: TransactionsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ซื้อ BTC'));
    await tester.pumpAndSettle();

    // Edit mode is titled for what it does, and prefills from the tx.
    expect(find.text('แก้ไขรายการ'), findsOneWidget);
    expect(find.text('Bitcoin BTC'), findsOneWidget);
    // Whole amounts prefill as "3", not double.toString()'s "3.0".
    expect(find.widgetWithText(TextField, '3'), findsOneWidget);
    expect(find.widgetWithText(TextField, '70'), findsOneWidget);
  });

  testWidgets('edit prefill keeps fractional amounts intact', (tester) async {
    final asset = _asset(id: 'a1', symbol: 'BTC', name: 'Bitcoin');
    final tx = _tx(id: 't10', assetId: 'a1', quantity: 0.5, price: 12.25);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: TransactionSheet(
            side: 'buy',
            assets: [asset],
            initialAsset: asset,
            existing: tx,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '0.5'), findsOneWidget);
    expect(find.widgetWithText(TextField, '12.25'), findsOneWidget);
  });
}

/// Portfolios never resolve here — _editTransaction must still offer the row's
/// own asset so the sheet can open.
class _FakeEmptyPortfolios extends PortfoliosNotifier {
  @override
  Future<PortfoliosState> build() async => const PortfoliosState(nodes: []);
}

// ── Recording fake notifier ───────────────────────────────────────────────

/// Fake notifier that records addTransaction calls for test assertions.
class _RecordingTx extends TransactionsNotifier {
  Map<String, dynamic>? lastCall;

  @override
  Future<TransactionsState> build() async =>
      const TransactionsState(groups: []);

  @override
  Future<void> addTransaction({
    required String assetId,
    required String side,
    required double quantity,
    required double price,
    double fee = 0,
    required String date,
  }) async {
    lastCall = {
      'assetId': assetId,
      'side': side,
      'quantity': quantity,
      'price': price,
      'fee': fee,
      'date': date,
    };
  }
}
