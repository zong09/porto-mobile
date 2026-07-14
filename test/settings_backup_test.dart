import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/misc_dao.dart';
import 'package:porto_mobile/src/repos/settings_repo.dart';
import 'package:porto_mobile/src/repos/backup_repo.dart';
import 'package:porto_mobile/src/state/providers.dart';
import 'package:porto_mobile/src/state/settings_notifier.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  // ── 1. SettingsRepo defaults ──────────────────────────────────────

  test('SettingsRepo defaults on fresh db', () async {
    final repo = SettingsRepo(MiscDao(db));
    expect(await repo.getDisplayCurrency(), 'USD');
    expect(await repo.getLanguage(), 'th');
  });

  // ── 2. SettingsRepo validation ────────────────────────────────────

  test('SettingsRepo setDisplayCurrency / validation', () async {
    final repo = SettingsRepo(MiscDao(db));
    await repo.setDisplayCurrency('THB');
    expect(await repo.getDisplayCurrency(), 'THB');
    expect(() => repo.setDisplayCurrency('EUR'), throwsArgumentError);
  });

  test('SettingsRepo setLanguage / validation', () async {
    final repo = SettingsRepo(MiscDao(db));
    await repo.setLanguage('en');
    expect(await repo.getLanguage(), 'en');
    expect(() => repo.setLanguage('fr'), throwsArgumentError);
  });

  // ── 3. Backup round-trip ──────────────────────────────────────────

  test('BackupRepo export / import round-trip', () async {
    final db1 = AppDatabase(NativeDatabase.memory());

    // insert a portfolio
    await db1.into(db1.portfolios).insert(
      PortfoliosCompanion.insert(id: 'p1', name: 'Main', color: 1),
    );
    // insert an asset under it
    await db1.into(db1.assets).insert(
      AssetsCompanion.insert(
        id: 'a1',
        portfolioId: 'p1',
        type: 'crypto',
        symbol: 'BTC',
        name: 'Bitcoin',
      ),
    );
    // set a setting
    final misc = MiscDao(db1);
    await misc.setSetting('displayCurrency', 'THB');

    // export from db1
    final json = await BackupRepo(db1).exportJson();
    expect(json['version'], 1);
    expect((json['portfolios'] as List).length, 1);
    expect((json['assets'] as List).length, 1);
    expect((json['settings'] as List).length, 1);

    // build a second fresh db and import
    final db2 = AppDatabase(NativeDatabase.memory());
    await BackupRepo(db2).importJson(json);

    // verify data survived round-trip
    final portfolios =
        await db2.select(db2.portfolios).get();
    expect(portfolios, hasLength(1));
    expect(portfolios.first.name, 'Main');

    final assets = await db2.select(db2.assets).get();
    expect(assets, hasLength(1));
    expect(assets.first.symbol, 'BTC');

    db1.close();
  });

  // ── 4. SettingsNotifier (§10.4 harness) ──────────────────────────

  test('SettingsNotifier build + setCurrency', () async {
    final n = container.read(settingsProvider.notifier);
    final state = await container.read(settingsProvider.future);
    expect(state.displayCurrency, 'USD');

    await n.setCurrency('THB');
    final updated = await container.read(settingsProvider.future);
    expect(updated.displayCurrency, 'THB');
  });
}
