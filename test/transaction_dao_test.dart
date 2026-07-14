import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/transaction_dao.dart';

TransactionsCompanion _tx(String id, String assetId, String date) =>
    TransactionsCompanion.insert(
      id: id,
      assetId: assetId,
      side: 'buy',
      quantity: 1,
      price: 100,
      date: date,
      createdAt: '2026-01-01T00:00:00Z',
    );

void main() {
  late AppDatabase db;
  late TransactionDao dao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = TransactionDao(db);
    // FK parents
    await db.into(db.portfolios).insert(
        PortfoliosCompanion.insert(id: 'p1', name: 'Main', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1', portfolioId: 'p1', type: 'crypto', symbol: 'BTC', name: 'BTC'));
  });
  tearDown(() => db.close());

  test('1. byAsset returns oldest-first by date', () async {
    await dao.upsert(_tx('t2', 'a1', '2026-01-02'));
    await dao.upsert(_tx('t1', 'a1', '2026-01-01'));
    final rows = await dao.byAsset('a1');
    expect(rows.map((r) => r.id).toList(), ['t1', 't2']);
  });

  test('2. watchByAsset emits after insert', () async {
    final future = dao.watchByAsset('a1').firstWhere((l) => l.isNotEmpty);
    await dao.upsert(_tx('t1', 'a1', '2026-01-01'));
    expect((await future).single.id, 't1');
  });

  test('3. delete removes a tx', () async {
    await dao.upsert(_tx('t1', 'a1', '2026-01-01'));
    await dao.delete('t1');
    expect(await dao.byAsset('a1'), isEmpty);
  });
}
