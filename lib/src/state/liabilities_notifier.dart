import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/database.dart';
import '../repos/liability_repo.dart';

part 'liabilities_notifier.freezed.dart';
part 'liabilities_notifier.g.dart';

@freezed
abstract class LiabilitiesState with _$LiabilitiesState {
  const factory LiabilitiesState({required List<Liability> liabilities}) =
      _LiabilitiesState;
}

@riverpod
class LiabilitiesNotifier extends _$LiabilitiesNotifier {
  LiabilityRepo get _repo => ref.read(liabilityRepoProvider);

  @override
  Future<LiabilitiesState> build() async =>
      LiabilitiesState(liabilities: await _repo.all());

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addLiability({
    required String name,
    required double amount,
    required String currency,
  }) async {
    await _repo.create(name: name, amount: amount, currency: currency);
    await _reload();
  }

  Future<void> saveLiability(Liability l) async {
    await _repo.save(l);
    await _reload();
  }

  Future<void> deleteLiability(String id) async {
    await _repo.remove(id);
    await _reload();
  }

  Future<void> adjust({
    required String liabilityId,
    required String type,
    required double amount,
    required String date,
  }) async {
    await _repo.adjust(
      liabilityId: liabilityId,
      type: type,
      amount: amount,
      date: date,
    );
    await _reload();
  }
}
