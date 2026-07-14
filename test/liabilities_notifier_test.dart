import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/state/liabilities_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';

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

  LiabilitiesNotifier notifier() => container.read(liabilitiesProvider.notifier);
  Future<List<Liability>> read() async =>
      (await container.read(liabilitiesProvider.future)).liabilities;

  test('build() — empty liabilities', () async {
    expect(await read(), isEmpty);
  });

  test('addLiability', () async {
    await notifier().addLiability(name: 'Card', amount: 1000, currency: 'THB');
    final ls = await read();
    expect(ls, hasLength(1));
    expect(ls.first.amount, 1000);
  });

  test('adjust (pay) reduces amount', () async {
    await notifier().addLiability(name: 'Loan', amount: 1000, currency: 'THB');
    final id = (await read()).first.id;
    await notifier().adjust(liabilityId: id, type: 'pay', amount: 400, date: '2026-02-01');
    expect((await read()).first.amount, 600);
  });

  test('saveLiability renames (one row)', () async {
    await notifier().addLiability(name: 'Card', amount: 500, currency: 'THB');
    final l = (await read()).first.copyWith(name: 'Renamed');
    await notifier().saveLiability(l);
    final ls = await read();
    expect(ls, hasLength(1));
    expect(ls.first.name, 'Renamed');
  });

  test('deleteLiability', () async {
    await notifier().addLiability(name: 'Card', amount: 200, currency: 'THB');
    final id = (await read()).first.id;
    await notifier().deleteLiability(id);
    expect(await read(), isEmpty);
  });
}
