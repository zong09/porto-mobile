import 'package:drift/drift.dart';
import 'database.dart';

/// Plain data-access wrapper for liabilities and their transactions.
class LiabilityDao {
  final AppDatabase db;
  LiabilityDao(this.db);

  Future<void> upsert(LiabilitiesCompanion c) =>
      db.into(db.liabilities).insertOnConflictUpdate(c);

  Future<void> deleteLiability(String id) =>
      (db.delete(db.liabilities)..where((t) => t.id.equals(id))).go();

  Future<List<Liability>> all() =>
      (db.select(db.liabilities)
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .get();

  Stream<List<Liability>> watchAll() =>
      (db.select(db.liabilities)
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .watch();

  Future<void> addTx(LiabilityTransactionsCompanion c) =>
      db.into(db.liabilityTransactions).insert(c);

  Future<List<LiabilityTransaction>> txsFor(String liabilityId) =>
      (db.select(db.liabilityTransactions)
            ..where((t) => t.liabilityId.equals(liabilityId)))
          .get();
}
