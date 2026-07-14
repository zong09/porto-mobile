import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/portfolio_asset_dao.dart';

PortfoliosCompanion _pf(String id, {int sortOrder = 0}) =>
    PortfoliosCompanion.insert(
        id: id, name: 'P$id', color: 0, sortOrder: Value(sortOrder));

AssetsCompanion _asset(String id, String portfolioId) =>
    AssetsCompanion.insert(
      id: id,
      portfolioId: portfolioId,
      type: 'crypto',
      symbol: 'BTC',
      name: 'Bitcoin',
    );

void main() {
  late AppDatabase db;
  late PortfolioAssetDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = PortfolioAssetDao(db);
  });
  tearDown(() => db.close());

  test('1. insert + list portfolios', () async {
    await dao.upsertPortfolio(_pf('p1'));
    expect((await dao.allPortfolios()).length, 1);
  });

  test('2. reorder sets sortOrder by index order', () async {
    await dao.upsertPortfolio(_pf('a', sortOrder: 0));
    await dao.upsertPortfolio(_pf('b', sortOrder: 1));
    await dao.upsertPortfolio(_pf('c', sortOrder: 2));
    await dao.reorderPortfolios(['c', 'a', 'b']);
    final byId = {for (final p in await dao.allPortfolios()) p.id: p.sortOrder};
    expect(byId['c'], 0);
    expect(byId['a'], 1);
    expect(byId['b'], 2);
  });

  test('3. FK cascade: deleting portfolio removes its assets', () async {
    await dao.upsertPortfolio(_pf('p1'));
    await dao.upsertAsset(_asset('a1', 'p1'));
    await dao.deletePortfolio('p1');
    expect(await dao.assetsFor('p1'), isEmpty);
  });

  test('4. watchAssetsFor emits after insert', () async {
    await dao.upsertPortfolio(_pf('p1'));
    final future = dao.watchAssetsFor('p1').firstWhere((l) => l.isNotEmpty);
    await dao.upsertAsset(_asset('a1', 'p1'));
    expect((await future).single.id, 'a1');
  });
}
