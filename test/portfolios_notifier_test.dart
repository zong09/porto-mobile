import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/state/portfolios_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';
import 'package:porto_mobile/src/repos/transaction_repo.dart';

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

  PortfoliosNotifier n() => container.read(portfoliosProvider.notifier);
  Future<PortfoliosState> state() async =>
      await container.read(portfoliosProvider.future);

  test('build() — empty portfolios', () async {
    final s = await state();
    expect(s.nodes, isEmpty);
  });

  test('addPortfolio', () async {
    await n().addPortfolio(name: 'Main', color: 2);
    final s = await state();
    expect(s.nodes, hasLength(1));
    expect(s.nodes.first.portfolio.name, 'Main');
    expect(s.nodes.first.assets, isEmpty);
  });

  test('reorderPortfolios', () async {
    await n().addPortfolio(name: 'First', color: 0);
    await n().addPortfolio(name: 'Second', color: 1);
    final s = await state();
    final id1 = s.nodes[0].portfolio.id;
    final id2 = s.nodes[1].portfolio.id;

    await n().reorderPortfolios([id2, id1]);
    final s2 = await state();
    expect(s2.nodes[0].portfolio.id, id2);
  });

  test('renamePortfolio & recolorPortfolio', () async {
    await n().addPortfolio(name: 'Main', color: 0);
    final s = await state();
    final id = s.nodes.first.portfolio.id;

    await n().renamePortfolio(id, 'X');
    expect((await state()).nodes.first.portfolio.name, 'X');

    await n().recolorPortfolio(id, 4);
    expect((await state()).nodes.first.portfolio.color, 4);
  });

  test('position calculation via txs', () async {
    await n().addPortfolio(name: 'Crypto', color: 0);
    final s = await state();
    final pid = s.nodes.first.portfolio.id;

    await n().addAsset(
      portfolioId: pid,
      type: 'crypto',
      symbol: 'BTC',
      name: 'Bitcoin',
      currency: 'USD',
    );
    final assetId = (await state()).nodes.first.assets.first.asset.id;

    final tRepo = container.read(transactionRepoProvider);
    await tRepo.add(assetId: assetId, side: 'buy', quantity: 2, price: 100, date: '2026-01-01');
    await tRepo.add(assetId: assetId, side: 'buy', quantity: 1, price: 200, date: '2026-02-01');

    container.invalidate(portfoliosProvider);
    final s2 = await state();
    final pos = s2.nodes.first.assets.first.position;
    expect(pos.quantity, closeTo(3, 0.01));
    expect(pos.totalCost, closeTo(400, 0.01));
  });

  test('deletePortfolio cascades', () async {
    await n().addPortfolio(name: 'Main', color: 0);
    final s = await state();
    final id = s.nodes.first.portfolio.id;

    await n().deletePortfolio(id);
    expect((await state()).nodes, isEmpty);
  });

  test('saveAsset throws when changing currency', () async {
    // Reuse setup from position test
    await n().addPortfolio(name: 'Crypto', color: 0);
    final s = await state();
    final pid = s.nodes.first.portfolio.id;

    await n().addAsset(
      portfolioId: pid,
      type: 'crypto',
      symbol: 'BTC',
      name: 'Bitcoin',
      currency: 'USD',
    );
    final asset = (await state()).nodes.first.assets.first.asset;

    expect(
      n().saveAsset(asset.copyWith(currency: 'THB')),
      throwsA(isA<ArgumentError>()),
    );
  });
}
