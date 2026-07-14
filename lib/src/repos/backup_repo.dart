import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database.dart';
import '../state/providers.dart';

class BackupRepo {
  final AppDatabase db;
  BackupRepo(this.db);

  Future<Map<String, dynamic>> exportJson() async => {
        'version': 1,
        'portfolios':
            (await db.select(db.portfolios).get()).map((e) => e.toJson()).toList(),
        'assets':
            (await db.select(db.assets).get()).map((e) => e.toJson()).toList(),
        'transactions': (await db.select(db.transactions).get())
            .map((e) => e.toJson())
            .toList(),
        'liabilities':
            (await db.select(db.liabilities).get()).map((e) => e.toJson()).toList(),
        'liabilityTransactions': (await db.select(db.liabilityTransactions).get())
            .map((e) => e.toJson())
            .toList(),
        'netWorthHistory':
            (await db.select(db.netWorthHistory).get()).map((e) => e.toJson()).toList(),
        'settings':
            (await db.select(db.settings).get()).map((e) => e.toJson()).toList(),
      };

  Future<void> importJson(Map<String, dynamic> data) async {
    List<Map<String, dynamic>> rows(String k) =>
        ((data[k] as List?) ?? const []).cast<Map<String, dynamic>>();

    await db.transaction(() async {
      // wipe children first
      await db.delete(db.transactions).go();
      await db.delete(db.assets).go();
      await db.delete(db.liabilityTransactions).go();
      await db.delete(db.liabilities).go();
      await db.delete(db.portfolios).go();
      await db.delete(db.netWorthHistory).go();
      await db.delete(db.settings).go();
      // insert in FK order
      for (final m in rows('portfolios')) {
        await db.into(db.portfolios).insert(Portfolio.fromJson(m).toCompanion(true));
      }
      for (final m in rows('assets')) {
        await db.into(db.assets).insert(Asset.fromJson(m).toCompanion(true));
      }
      for (final m in rows('transactions')) {
        await db.into(db.transactions).insert(Transaction.fromJson(m).toCompanion(true));
      }
      for (final m in rows('liabilities')) {
        await db.into(db.liabilities).insert(Liability.fromJson(m).toCompanion(true));
      }
      for (final m in rows('liabilityTransactions')) {
        await db.into(db.liabilityTransactions)
            .insert(LiabilityTransaction.fromJson(m).toCompanion(true));
      }
      for (final m in rows('netWorthHistory')) {
        await db.into(db.netWorthHistory)
            .insert(NetWorthHistoryData.fromJson(m).toCompanion(true));
      }
      for (final m in rows('settings')) {
        await db.into(db.settings).insert(Setting.fromJson(m).toCompanion(true));
      }
    });
  }
}

final backupRepoProvider =
    Provider((ref) => BackupRepo(ref.watch(appDatabaseProvider)));
