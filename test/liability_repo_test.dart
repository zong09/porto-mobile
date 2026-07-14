import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/liability_dao.dart';
import 'package:porto_mobile/src/repos/liability_repo.dart';

void main() {
  late AppDatabase db;
  late LiabilityRepo repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LiabilityRepo(LiabilityDao(db));
  });

  tearDown(() => db.close());

  test('create inserts a liability and all() returns it', () async {
    final l = await repo.create(name: 'Card', amount: 1000, currency: 'THB');
    expect(l.id.isNotEmpty, isTrue);
    expect(l.name, 'Card');
    expect(l.amount, 1000);
    expect(l.currency, 'THB');

    final all = await repo.all();
    expect(all.length, 1);
    expect(all.first.amount, 1000);
    expect(all.first.currency, 'THB');
  });

  test('create rejects empty name, zero amount, invalid currency', () async {
    expect(
      () => repo.create(name: '', amount: 1, currency: 'THB'),
      throwsArgumentError,
    );
    expect(
      () => repo.create(name: 'X', amount: 0, currency: 'THB'),
      throwsArgumentError,
    );
    expect(
      () => repo.create(name: 'X', amount: 1, currency: 'EUR'),
      throwsArgumentError,
    );
  });

  test('adjust pay reduces amount and creates a transaction', () async {
    final l = await repo.create(name: 'Loan', amount: 1000, currency: 'THB');
    final id = l.id;

    await repo.adjust(liabilityId: id, type: 'pay', amount: 300, date: '2026-01-05');

    final all = await repo.all();
    expect(all.first.amount, 700);

    final txs = await repo.txsFor(id);
    expect(txs.length, 1);
    expect(txs.first.type, 'pay');
    expect(txs.first.amount, 300);
  });

  test('adjust add increases amount and creates a second transaction', () async {
    final l = await repo.create(name: 'Loan', amount: 1000, currency: 'THB');
    final id = l.id;

    await repo.adjust(liabilityId: id, type: 'pay', amount: 300, date: '2026-01-05');
    await repo.adjust(liabilityId: id, type: 'add', amount: 200, date: '2026-01-06');

    final all = await repo.all();
    expect(all.first.amount, 900);

    final txs = await repo.txsFor(id);
    expect(txs.length, 2);
  });

  test('adjust clamps to zero when pay exceeds amount', () async {
    final l = await repo.create(name: 'Loan', amount: 100, currency: 'THB');
    final id = l.id;

    await repo.adjust(liabilityId: id, type: 'pay', amount: 500, date: '2026-01-07');

    final all = await repo.all();
    expect(all.first.amount, 0);
  });

  test('adjust rejects invalid type and zero amount', () async {
    final l = await repo.create(name: 'Loan', amount: 100, currency: 'THB');
    final id = l.id;

    expect(
      () => repo.adjust(liabilityId: id, type: 'bogus', amount: 10, date: '2026-01-01'),
      throwsArgumentError,
    );
    expect(
      () => repo.adjust(liabilityId: id, type: 'pay', amount: 0, date: '2026-01-01'),
      throwsArgumentError,
    );
  });

  test('remove deletes liability and cascades to transactions', () async {
    final l = await repo.create(name: 'Loan', amount: 500, currency: 'THB');
    final id = l.id;

    await repo.adjust(liabilityId: id, type: 'pay', amount: 100, date: '2026-01-01');

    await repo.remove(id);

    expect(await repo.all(), isEmpty);
    expect(await repo.txsFor(id), isEmpty);
  });
}
