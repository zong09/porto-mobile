import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/misc_dao.dart';

void main() {
  late AppDatabase db;
  late MiscDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = MiscDao(db);
  });
  tearDown(() => db.close());

  test('1. snapshot upsert by date PK keeps one row (latest)', () async {
    await dao.upsertSnapshot(const NetWorthHistoryData(
        date: '2026-01-01',
        totalAssetsThb: 100,
        totalLiabilitiesThb: 0,
        netWorthThb: 100));
    await dao.upsertSnapshot(const NetWorthHistoryData(
        date: '2026-01-01',
        totalAssetsThb: 200,
        totalLiabilitiesThb: 0,
        netWorthThb: 200));
    final rows = await dao.history();
    expect(rows.length, 1);
    expect(rows.single.netWorthThb, 200);
  });

  test('2. price cache put/get', () async {
    await dao.putPrice(PriceCacheCompanion.insert(
        key: 'crypto:BTC',
        price: 100,
        currency: 'USD',
        fetchedAt: '2026-01-01T00:00:00Z'));
    expect((await dao.getPrice('crypto:BTC'))!.price, 100);
  });

  test('3. settings kv set/get/overwrite', () async {
    await dao.setSetting('displayCurrency', 'USD');
    expect(await dao.getSetting('displayCurrency'), 'USD');
    await dao.setSetting('displayCurrency', 'THB');
    expect(await dao.getSetting('displayCurrency'), 'THB');
  });
}
