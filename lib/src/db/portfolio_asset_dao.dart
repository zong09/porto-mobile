import 'package:drift/drift.dart';
import 'database.dart';

/// Plain data-access wrapper for portfolios and assets (not a @DriftAccessor).
class PortfolioAssetDao {
  final AppDatabase db;
  PortfolioAssetDao(this.db);

  // portfolios
  Future<void> upsertPortfolio(PortfoliosCompanion c) =>
      db.into(db.portfolios).insertOnConflictUpdate(c);

  Future<List<Portfolio>> allPortfolios() =>
      (db.select(db.portfolios)
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Stream<List<Portfolio>> watchPortfolios() =>
      (db.select(db.portfolios)
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Future<void> deletePortfolio(String id) =>
      (db.delete(db.portfolios)..where((t) => t.id.equals(id))).go();

  /// Set sortOrder = index for each id, in one batch.
  Future<void> reorderPortfolios(List<String> idsInOrder) async {
    await db.batch((b) {
      for (var i = 0; i < idsInOrder.length; i++) {
        b.update(
          db.portfolios,
          PortfoliosCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(idsInOrder[i]),
        );
      }
    });
  }

  // assets
  Future<void> upsertAsset(AssetsCompanion c) =>
      db.into(db.assets).insertOnConflictUpdate(c);

  Future<List<Asset>> assetsFor(String portfolioId) =>
      (db.select(db.assets)
            ..where((t) => t.portfolioId.equals(portfolioId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Stream<List<Asset>> watchAssetsFor(String portfolioId) =>
      (db.select(db.assets)
            ..where((t) => t.portfolioId.equals(portfolioId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Future<void> deleteAsset(String id) =>
      (db.delete(db.assets)..where((t) => t.id.equals(id))).go();
}
