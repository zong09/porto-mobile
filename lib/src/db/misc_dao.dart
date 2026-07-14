import 'package:drift/drift.dart';
import 'database.dart';

/// Plain data-access wrapper for net-worth history, price cache, and settings.
class MiscDao {
  final AppDatabase db;
  MiscDao(this.db);

  // net_worth_history — date is PK; upsert by date
  Future<void> upsertSnapshot(NetWorthHistoryData row) =>
      db.into(db.netWorthHistory).insertOnConflictUpdate(row.toCompanion(true));

  Future<List<NetWorthHistoryData>> history() =>
      (db.select(db.netWorthHistory)
            ..orderBy([(t) => OrderingTerm(expression: t.date)]))
          .get();

  // price_cache — key is PK
  Future<void> putPrice(PriceCacheCompanion c) =>
      db.into(db.priceCache).insertOnConflictUpdate(c);

  Future<PriceCacheData?> getPrice(String key) =>
      (db.select(db.priceCache)..where((t) => t.key.equals(key)))
          .getSingleOrNull();

  // settings — key/value kv
  Future<void> setSetting(String key, String value) => db
      .into(db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<String?> getSetting(String key) async =>
      (await (db.select(db.settings)..where((t) => t.key.equals(key)))
              .getSingleOrNull())
          ?.value;
}
