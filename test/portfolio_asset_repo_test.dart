import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/portfolio_asset_dao.dart';
import 'package:porto_mobile/src/repos/portfolio_repo.dart';
import 'package:porto_mobile/src/repos/asset_repo.dart';

void main() {
  late AppDatabase db;
  late PortfolioRepo pRepo;
  late AssetRepo aRepo;

  void setUpRepo() {
    db = AppDatabase(NativeDatabase.memory());
    final dao = PortfolioAssetDao(db);
    pRepo = PortfolioRepo(dao);
    aRepo = AssetRepo(dao);
  }

  tearDown(() => db.close());

  test('create portfolio with correct sortOrder', () async {
    setUpRepo();
    final p1 = await pRepo.create(name: 'Main', color: 2);
    final all = await pRepo.all();
    expect(all.length, 1);
    expect(p1.name, 'Main');
    expect(p1.color, 2);
    expect(p1.sortOrder, 0);

    final p2 = await pRepo.create(name: 'Alt', color: 3);
    expect(p2.sortOrder, 1);
  });

  test('create throws on empty name or bad color', () async {
    setUpRepo();
    expect(() => pRepo.create(name: '  ', color: 2), throwsArgumentError);
    expect(() => pRepo.create(name: 'X', color: 6), throwsArgumentError);
    expect(() => pRepo.create(name: 'X', color: -1), throwsArgumentError);
  });

  test('save updates existing portfolio', () async {
    setUpRepo();
    final p = await pRepo.create(name: 'Main', color: 2);
    final id = p.id;
    await pRepo.save(p.copyWith(name: 'Renamed'));
    final all = await pRepo.all();
    expect(all.length, 1);
    expect(all.first.name, 'Renamed');
    expect(all.first.id, id);
  });

  test('remove portfolio', () async {
    setUpRepo();
    final p = await pRepo.create(name: 'Main', color: 2);
    await pRepo.remove(p.id);
    final all = await pRepo.all();
    expect(all, isEmpty);
  });

  test('reorder portfolios', () async {
    setUpRepo();
    final p1 = await pRepo.create(name: 'First', color: 1);
    final p2 = await pRepo.create(name: 'Second', color: 2);
    await pRepo.reorder([p2.id, p1.id]);
    final all = await pRepo.all();
    expect(all.length, 2);
    expect(all[0].id, p2.id);
    expect(all[0].sortOrder, 0);
    expect(all[1].id, p1.id);
    expect(all[1].sortOrder, 1);
  });

  test('create asset with correct defaults', () async {
    setUpRepo();
    final p = await pRepo.create(name: 'Main', color: 2);
    final a = await aRepo.create(
      portfolioId: p.id,
      type: 'crypto',
      symbol: 'BTC',
      name: 'Bitcoin',
      currency: 'USD',
    );
    final forP = await aRepo.allFor(p.id);
    expect(forP.length, 1);
    expect(a.currency, 'USD');
    expect(a.direction, 'long');
    expect(a.sortOrder, 0);
  });

  test('asset create throws on invalid type or empty symbol', () async {
    setUpRepo();
    final p = await pRepo.create(name: 'Main', color: 2);
    expect(
      () => aRepo.create(
        portfolioId: p.id,
        type: 'bogus',
        symbol: 'BTC',
        name: 'X',
        currency: 'USD',
      ),
      throwsArgumentError,
    );
    expect(
      () => aRepo.create(
        portfolioId: p.id,
        type: 'crypto',
        symbol: '',
        name: 'X',
        currency: 'USD',
      ),
      throwsArgumentError,
    );
  });

  test('currency lock on save', () async {
    setUpRepo();
    final p = await pRepo.create(name: 'Main', color: 2);
    final a = await aRepo.create(
      portfolioId: p.id,
      type: 'crypto',
      symbol: 'BTC',
      name: 'Bitcoin',
      currency: 'USD',
    );
    final id = a.id;
    // Changing currency should throw
    expect(
      () => aRepo.save(
        Asset(
          id: id,
          portfolioId: a.portfolioId,
          type: a.type,
          symbol: a.symbol,
          name: a.name,
          currency: 'THB',
          cgId: a.cgId,
          yahooSymbol: a.yahooSymbol,
          manualPrice: a.manualPrice,
          direction: a.direction,
          sortOrder: a.sortOrder,
        ),
      ),
      throwsArgumentError,
    );
    // Changing name (same currency) should succeed
    await aRepo.save(
      Asset(
        id: id,
        portfolioId: a.portfolioId,
        type: a.type,
        symbol: a.symbol,
        name: 'BTC2',
        currency: a.currency,
        cgId: a.cgId,
        yahooSymbol: a.yahooSymbol,
        manualPrice: a.manualPrice,
        direction: a.direction,
        sortOrder: a.sortOrder,
      ),
    );
    final all = await aRepo.allFor(p.id);
    expect(all.first.name, 'BTC2');
  });

  test('FK cascade: removing portfolio removes assets', () async {
    setUpRepo();
    final p = await pRepo.create(name: 'Main', color: 2);
    await aRepo.create(
      portfolioId: p.id,
      type: 'crypto',
      symbol: 'BTC',
      name: 'Bitcoin',
      currency: 'USD',
    );
    await pRepo.remove(p.id);
    final all = await aRepo.all();
    expect(all, isEmpty);
  });
}
