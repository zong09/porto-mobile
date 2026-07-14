import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/liability_dao.dart';
import '../state/providers.dart';

const _ccy = {'THB', 'USD'};

class LiabilityRepo {
  final LiabilityDao dao;
  LiabilityRepo(this.dao);

  Future<Liability> create({
    required String name,
    required double amount,
    required String currency,
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('name');
    if (amount <= 0) throw ArgumentError('amount');
    if (!_ccy.contains(currency)) throw ArgumentError('currency');

    final id = const Uuid().v4();
    final trimmed = name.trim();

    await dao.upsert(
      LiabilitiesCompanion.insert(
        id: id,
        name: trimmed,
        amount: amount,
        currency: Value(currency),
      ),
    );

    return Liability(id: id, name: trimmed, amount: amount, currency: currency);
  }

  Future<void> save(Liability l) async {
    if (l.name.trim().isEmpty) throw ArgumentError('name');
    if (l.amount < 0) throw ArgumentError('amount');
    if (!_ccy.contains(l.currency)) throw ArgumentError('currency');
    await dao.upsert(l.toCompanion(true));
  }

  Future<void> remove(String id) => dao.deleteLiability(id);

  /// Port of liabilities.service.ts#adjust:
  ///   pay → amount - amount, add → amount + amount, clamped to >= 0.
  Future<void> adjust({
    required String liabilityId,
    required String type,
    required double amount,
    required String date,
  }) async {
    if (amount <= 0) throw ArgumentError('amount');
    if (type != 'pay' && type != 'add') throw ArgumentError('type');

    await dao.db.transaction(() async {
      final current = (await dao.all()).where((x) => x.id == liabilityId).firstOrNull;
      if (current == null) throw ArgumentError('liability not found');

      final next = type == 'pay' ? current.amount - amount : current.amount + amount;
      final clamped = next < 0 ? 0.0 : next;

      await dao.addTx(
        LiabilityTransactionsCompanion.insert(
          id: const Uuid().v4(),
          liabilityId: liabilityId,
          type: type,
          amount: amount,
          date: date,
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );

      await dao.upsert(
        current.copyWith(amount: clamped).toCompanion(true),
      );
    });
  }

  Future<List<Liability>> all() => dao.all();

  Future<List<LiabilityTransaction>> txsFor(String id) => dao.txsFor(id);
}

final liabilityRepoProvider =
    Provider((ref) => LiabilityRepo(ref.watch(liabilityDaoProvider)));
