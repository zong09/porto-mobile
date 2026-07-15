import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
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

Widget _app(TransactionsState s) => ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(() => _FakeTx(s)),
      ],
      child: const MaterialApp(home: TransactionsScreen()),
    );

// ── tests ──────────────────────────────────────────────────────────────────

void main() {
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

  // ── Test 2: filter pill ซื้้่อ shows only buys ──────────────────────────

  testWidgets('filter pill ซื้้่อ shows only buys', (tester) async {
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
    expect(find.textContaining('ซื้้่อ BTC'), findsOneWidget);
    expect(find.textContaining('ขาย ETH'), findsOneWidget);

    // Tap the "ซื้้่อ" pill (second pill)
    final pillFinder = find.text('ซื้้่อ');
    expect(pillFinder, findsOneWidget);
    await tester.tap(pillFinder);
    await tester.pumpAndSettle();

    // Buy row still present
    expect(find.textContaining('ซื้้่อ BTC'), findsOneWidget);
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
