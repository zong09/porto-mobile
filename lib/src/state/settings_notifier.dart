import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repos/settings_repo.dart';
import '../repos/backup_repo.dart';
import 'liabilities_notifier.dart';
import 'overview_notifier.dart';
import 'portfolios_notifier.dart';
import 'transactions_notifier.dart';

part 'settings_notifier.freezed.dart';
part 'settings_notifier.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required String displayCurrency,
    required String language,
  }) = _SettingsState;
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  SettingsRepo get _repo => ref.read(settingsRepoProvider);

  @override
  Future<SettingsState> build() async => SettingsState(
        displayCurrency: await _repo.getDisplayCurrency(),
        language: await _repo.getLanguage(),
      );

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setCurrency(String v) async {
    await _repo.setDisplayCurrency(v);
    await _reload();
  }

  Future<void> setLanguage(String v) async {
    await _repo.setLanguage(v);
    await _reload();
  }

  Future<Map<String, dynamic>> exportToJson() =>
      ref.read(backupRepoProvider).exportJson();

  /// Replaces the whole database with [d].
  ///
  /// Passing `const {}` wipes everything — `BackupRepo.importJson` deletes every
  /// table before inserting, so an empty payload inserts nothing. That is how
  /// Settings › ลบข้อมูลทั้งหมด is implemented.
  ///
  /// Every other notifier caches rows that no longer exist, so they must be
  /// invalidated too — without this, import and delete-all both appear to do
  /// nothing until the app is restarted.
  Future<void> importFromJson(Map<String, dynamic> d) async {
    await ref.read(backupRepoProvider).importJson(d);
    ref.invalidate(portfoliosProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(liabilitiesProvider);
    ref.invalidate(overviewProvider);
    await _reload();
  }
}
