// T4.3 — offline FX hardening: fetchFxCached persists the rate and falls back
// to the last cached value so the app stays usable offline.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/misc_dao.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';

void main() {
  late AppDatabase db;
  late MiscDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = MiscDao(db);
  });
  tearDown(() => db.close());

  test('success caches the fx rate and returns it', () async {
    final r = await fetchFxCached(dao, () async => 35.0);
    expect(r, 35.0);
    final cached = await dao.getPrice('fx');
    expect(cached, isNotNull);
    expect(cached!.price, 35.0);
  });

  test('offline falls back to the last cached fx rate', () async {
    await fetchFxCached(dao, () async => 33.0); // seed a prior success
    final r = await fetchFxCached(dao, () async => throw Exception('offline'));
    expect(r, 33.0);
  });

  test('offline with no cached fx rethrows', () async {
    expect(
      () => fetchFxCached(dao, () async => throw Exception('offline')),
      throwsA(isA<Exception>()),
    );
  });
}
