import 'package:drift/drift.dart';
import 'database.dart';

/// Plain data-access wrapper for transactions.
class TransactionDao {
  final AppDatabase db;
  TransactionDao(this.db);

  Future<void> upsert(TransactionsCompanion c) =>
      db.into(db.transactions).insertOnConflictUpdate(c);

  Future<void> delete(String id) =>
      (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();

  Future<List<Transaction>> byAsset(String assetId) =>
      (db.select(db.transactions)
            ..where((t) => t.assetId.equals(assetId))
            ..orderBy([(t) => OrderingTerm(expression: t.date)]))
          .get();

  Stream<List<Transaction>> watchByAsset(String assetId) =>
      (db.select(db.transactions)
            ..where((t) => t.assetId.equals(assetId))
            ..orderBy([(t) => OrderingTerm(expression: t.date)]))
          .watch();

  Future<List<Transaction>> all() => db.select(db.transactions).get();
}
