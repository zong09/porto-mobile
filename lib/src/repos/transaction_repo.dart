import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/transaction_dao.dart';
import '../state/providers.dart';

const _sides = {'buy', 'sell', 'deposit', 'withdraw'};

class TransactionRepo {
  final TransactionDao dao;
  TransactionRepo(this.dao);

  void _validate(String side, double quantity, double price, double fee, String date) {
    if (!_sides.contains(side)) throw ArgumentError('side');
    if (quantity <= 0) throw ArgumentError('quantity');
    if (price < 0) throw ArgumentError('price');
    if (fee < 0) throw ArgumentError('fee');
    if (date.trim().isEmpty) throw ArgumentError('date');
  }

  Future<Transaction> add({
    required String assetId,
    required String side,
    required double quantity,
    required double price,
    double fee = 0,
    required String date,
  }) async {
    _validate(side, quantity, price, fee, date);
    final id = const Uuid().v4();
    final createdAt = DateTime.now().toUtc().toIso8601String();

    await dao.upsert(
      TransactionsCompanion.insert(
        id: id,
        assetId: assetId,
        side: side,
        quantity: quantity,
        price: price,
        date: date,
        createdAt: createdAt,
        fee: Value(fee),
      ),
    );
    return Transaction(
      id: id,
      assetId: assetId,
      side: side,
      quantity: quantity,
      price: price,
      fee: fee,
      date: date,
      createdAt: createdAt,
    );
  }

  Future<void> save(Transaction t) async {
    _validate(t.side, t.quantity, t.price, t.fee, t.date);
    await dao.upsert(t.toCompanion(true));
  }

  Future<void> remove(String id) => dao.delete(id);

  Future<List<Transaction>> byAsset(String assetId) => dao.byAsset(assetId);

  Future<List<Transaction>> all() => dao.all();
}

final transactionRepoProvider =
    Provider((ref) => TransactionRepo(ref.watch(transactionDaoProvider)));
