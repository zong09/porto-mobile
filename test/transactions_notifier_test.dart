import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/state/providers.dart';
import 'package:porto_mobile/src/state/transactions_notifier.dart';

late AppDatabase db;
late ProviderContainer container;

void main() {
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('empty: no groups when no transactions', () async {
    final groups = (await container.read(transactionsProvider.future)).groups;
    expect(groups, isEmpty);
  });

  test('add one tx: single group with one row', () async {
    await db.into(db.portfolios).insert(PortfoliosCompanion.insert(id: 'p1', name: 'P', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1', portfolioId: 'p1', type: 'crypto', symbol: 'BTC', name: 'Bitcoin'));

    final notifier = container.read(transactionsProvider.notifier);
    await notifier.addTransaction(assetId: 'a1', side: 'buy', quantity: 1, price: 100, date: '2026-01-02');

    final groups = (await container.read(transactionsProvider.future)).groups;
    expect(groups.length, 1);
    expect(groups[0].date, '2026-01-02');
    expect(groups[0].rows.length, 1);
    expect(groups[0].rows[0].asset.symbol, 'BTC');
  });

  test('grouping: txs grouped by date, newest first', () async {
    await db.into(db.portfolios).insert(PortfoliosCompanion.insert(id: 'p1', name: 'P', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1', portfolioId: 'p1', type: 'crypto', symbol: 'BTC', name: 'Bitcoin'));

    final notifier = container.read(transactionsProvider.notifier);
    await notifier.addTransaction(assetId: 'a1', side: 'buy', quantity: 1, price: 100, date: '2026-01-02');
    await notifier.addTransaction(assetId: 'a1', side: 'sell', quantity: 0.5, price: 110, date: '2026-01-01');
    await notifier.addTransaction(assetId: 'a1', side: 'buy', quantity: 0.3, price: 105, date: '2026-01-02');

    final groups = (await container.read(transactionsProvider.future)).groups;
    expect(groups.length, 2);
    expect(groups[0].date, '2026-01-02');
    expect(groups[0].rows.length, 2);
    expect(groups[1].date, '2026-01-01');
    expect(groups[1].rows.length, 1);
  });

  test('deleteTransaction removes the tx from groups', () async {
    await db.into(db.portfolios).insert(PortfoliosCompanion.insert(id: 'p1', name: 'P', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1', portfolioId: 'p1', type: 'crypto', symbol: 'BTC', name: 'Bitcoin'));

    final notifier = container.read(transactionsProvider.notifier);
    await notifier.addTransaction(assetId: 'a1', side: 'buy', quantity: 1, price: 100, date: '2026-01-02');

    final state = await container.read(transactionsProvider.future);
    final id = state.groups[0].rows[0].tx.id;
    expect(id, isNotNull);

    await notifier.deleteTransaction(id);

    final groups = (await container.read(transactionsProvider.future)).groups;
    final remaining = groups.expand((g) => g.rows).toList();
    expect(remaining.every((r) => r.tx.id != id), isTrue);
  });
}
