import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/liability_dao.dart';

void main() {
  late AppDatabase db;
  late LiabilityDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = LiabilityDao(db);
  });
  tearDown(() => db.close());

  test('1. insert + list', () async {
    await dao.upsert(LiabilitiesCompanion.insert(id: 'L1', name: 'Loan', amount: 100));
    expect((await dao.all()).length, 1);
  });

  test('2. FK cascade removes liability_tx', () async {
    await dao.upsert(LiabilitiesCompanion.insert(id: 'L1', name: 'Loan', amount: 100));
    await dao.addTx(LiabilityTransactionsCompanion.insert(
        id: 't1',
        liabilityId: 'L1',
        type: 'pay',
        amount: 10,
        date: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z'));
    await dao.deleteLiability('L1');
    expect(await dao.txsFor('L1'), isEmpty);
  });

  test('3. watchAll emits after insert', () async {
    final future = dao.watchAll().firstWhere((l) => l.isNotEmpty);
    await dao.upsert(LiabilitiesCompanion.insert(id: 'L1', name: 'Loan', amount: 100));
    expect((await future).single.id, 'L1');
  });
}
