import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/misc_dao.dart';
import '../state/providers.dart';

const _ccy = {'THB', 'USD'};
const _lang = {'th', 'en'};

class SettingsRepo {
  final MiscDao dao;
  SettingsRepo(this.dao);

  Future<String> getDisplayCurrency() async =>
      (await dao.getSetting('displayCurrency')) ?? 'USD';

  Future<void> setDisplayCurrency(String v) async {
    if (!_ccy.contains(v)) throw ArgumentError('currency');
    await dao.setSetting('displayCurrency', v);
  }

  Future<String> getLanguage() async =>
      (await dao.getSetting('language')) ?? 'th';

  Future<void> setLanguage(String v) async {
    if (!_lang.contains(v)) throw ArgumentError('language');
    await dao.setSetting('language', v);
  }
}

final settingsRepoProvider =
    Provider((ref) => SettingsRepo(ref.watch(miscDaoProvider)));
