import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/transaction_dao.dart';
import 'package:porto_mobile/src/repos/transaction_repo.dart';

void main() {
  late AppDatabase db;
  late TransactionRepo repo;

  // Fresh in-memory DB per test. Transactions.assetId is a FK -> assets.id (CASCADE)
  // with foreign_keys ON, so seed a parent portfolio + assets 'a1'/'a2' first.
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = TransactionRepo(TransactionDao(db));
    await db
        .into(db.portfolios)
        .insert(PortfoliosCompanion.insert(id: 'p1', name: 'P', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1', portfolioId: 'p1', type: 'crypto', symbol: 'BTC', name: 'Bitcoin'));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a2', portfolioId: 'p1', type: 'crypto', symbol: 'ETH', name: 'Ether'));
  });

  tearDown(() => db.close());

  test('add inserts a transaction and byAsset returns it', () async {
    final tx = await repo.add(
      assetId: 'a1',
      side: 'buy',
      quantity: 0.5,
      price: 100,
      fee: 1,
      date: '2026-01-01',
    );
    expect(tx.id.isNotEmpty, isTrue);
    expect(tx.createdAt.isNotEmpty, isTrue);
    expect(tx.quantity, 0.5);
    expect(tx.fee, 1);

    final byAsset = await repo.byAsset('a1');
    expect(byAsset.length, 1);
  });

  test('add rejects invalid side, quantity, price, date', () async {
    expect(
      () => repo.add(assetId: 'a1', side: 'bogus', quantity: 1, price: 1, date: '2026-01-01'),
      throwsArgumentError,
    );
    expect(
      () => repo.add(assetId: 'a1', side: 'buy', quantity: 0, price: 1, date: '2026-01-01'),
      throwsArgumentError,
    );
    expect(
      () => repo.add(assetId: 'a1', side: 'buy', quantity: 1, price: -1, date: '2026-01-01'),
      throwsArgumentError,
    );
    expect(
      () => repo.add(assetId: 'a1', side: 'buy', quantity: 1, price: 1, date: ''),
      throwsArgumentError,
    );
  });

  test('fee defaults to 0 when omitted', () async {
    final tx = await repo.add(
      assetId: 'a1',
      side: 'sell',
      quantity: 1,
      price: 2,
      date: '2026-01-02',
    );
    expect(tx.fee, 0);
  });

  test('save updates an existing transaction (one row, not two)', () async {
    final tx = await repo.add(
      assetId: 'a1',
      side: 'buy',
      quantity: 0.5,
      price: 100,
      date: '2026-01-01',
    );
    final updated = tx.copyWith(quantity: 2);
    await repo.save(updated);

    final rows = await repo.byAsset('a1');
    expect(rows.length, 1);
    expect(rows.first.quantity, 2);
  });

  test('remove deletes a transaction', () async {
    final tx = await repo.add(
      assetId: 'a1',
      side: 'buy',
      quantity: 0.5,
      price: 100,
      date: '2026-01-01',
    );
    final id = tx.id;
    await repo.remove(id);

    final rows = await repo.byAsset('a1');
    expect(rows.any((r) => r.id == id), isFalse);
  });

  test('all returns rows across different assetIds', () async {
    await repo.add(assetId: 'a1', side: 'buy', quantity: 1, price: 10, date: '2026-01-01');
    await repo.add(assetId: 'a2', side: 'sell', quantity: 2, price: 20, date: '2026-01-02');

    final all = await repo.all();
    expect(all.length, 2);
  });
}
