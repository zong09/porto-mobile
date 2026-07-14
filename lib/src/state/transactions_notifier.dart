import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../db/database.dart';
import '../repos/transaction_repo.dart';
import '../repos/asset_repo.dart';
part 'transactions_notifier.freezed.dart';
part 'transactions_notifier.g.dart';

@freezed
abstract class TxRow with _$TxRow {
  const factory TxRow({required Transaction tx, required Asset asset}) = _TxRow;
}

@freezed
abstract class TxGroup with _$TxGroup {
  const factory TxGroup({required String date, required List<TxRow> rows}) = _TxGroup;
}

@freezed
abstract class TransactionsState with _$TransactionsState {
  const factory TransactionsState({required List<TxGroup> groups}) = _TransactionsState;
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  TransactionRepo get _tRepo => ref.read(transactionRepoProvider);
  AssetRepo get _aRepo => ref.read(assetRepoProvider);

  @override
  Future<TransactionsState> build() async {
    final assets = {for (final a in await _aRepo.all()) a.id: a};
    final txs = await _tRepo.all();
    // sort: date DESC, then createdAt DESC
    txs.sort((a, b) {
      final d = b.date.compareTo(a.date);
      return d != 0 ? d : b.createdAt.compareTo(a.createdAt);
    });
    final groups = <TxGroup>[];
    for (final t in txs) {
      final asset = assets[t.assetId];
      if (asset == null) continue;
      if (groups.isNotEmpty && groups.last.date == t.date) {
        groups[groups.length - 1] =
            groups.last.copyWith(rows: [...groups.last.rows, TxRow(tx: t, asset: asset)]);
      } else {
        groups.add(TxGroup(date: t.date, rows: [TxRow(tx: t, asset: asset)]));
      }
    }
    return TransactionsState(groups: groups);
  }

  Future<void> _reload() async { ref.invalidateSelf(); await future; }

  Future<void> addTransaction({required String assetId, required String side,
      required double quantity, required double price, double fee = 0, required String date}) async {
    await _tRepo.add(assetId: assetId, side: side, quantity: quantity, price: price, fee: fee, date: date);
    await _reload();
  }

  Future<void> saveTransaction(Transaction t) async { await _tRepo.save(t); await _reload(); }

  Future<void> deleteTransaction(String id) async { await _tRepo.remove(id); await _reload(); }
}
