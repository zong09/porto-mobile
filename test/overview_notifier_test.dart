import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/prices/price_repository.dart';
import 'package:porto_mobile/src/state/liabilities_notifier.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/state/portfolios_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';
import 'package:porto_mobile/src/state/transactions_notifier.dart';

class MockPriceRepo extends Mock implements PriceRepository {}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late MockPriceRepo mockPrice;

  setUpAll(() {
    registerFallbackValue(Asset(
      id: '_',
      portfolioId: '_',
      type: 'crypto',
      symbol: '_',
      name: '_',
      currency: 'USD',
      cgId: null,
      yahooSymbol: null,
      manualPrice: null,
      direction: 'long',
      sortOrder: 0,
    ));
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockPrice = MockPriceRepo();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      priceRepositoryProvider.overrideWithValue(mockPrice),
      fxProvider.overrideWithValue(() async => 35.0),
    ]);
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  OverviewNotifier notifier() =>
      container.read(overviewProvider.notifier);
  Future<OverviewState> state() async =>
      await container.read(overviewProvider.future);

  test('summary: fx, totalAssetsThb, netWorthThb, offline', () async {
    // seed portfolio + asset + tx
    await db.into(db.portfolios).insert(
        PortfoliosCompanion.insert(id: 'p1', name: 'M', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1',
        portfolioId: 'p1',
        type: 'crypto',
        symbol: 'BTC',
        name: 'B',
        currency: Value('USD')));
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
        id: 't1',
        assetId: 'a1',
        side: 'buy',
        quantity: 1,
        price: 100,
        date: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z'));

    when(() => mockPrice.resolve(any())).thenAnswer(
        (_) async => const ResolvedPrice(100, 0, 'live'));

    final s = await state();
    expect(s.summary, isNotNull);
    expect(s.summary!.fx, 35.0);
    expect(s.summary!.totalAssetsThb, closeTo(3500, 0.01));
    expect(s.summary!.netWorthThb, closeTo(3500, 0.01));
    expect(s.offline, isFalse);
  });

  test('offline flag when source is cache', () async {
    await db.into(db.portfolios).insert(
        PortfoliosCompanion.insert(id: 'p1', name: 'M', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1',
        portfolioId: 'p1',
        type: 'crypto',
        symbol: 'BTC',
        name: 'B',
        currency: Value('USD')));

    when(() => mockPrice.resolve(any())).thenAnswer(
        (_) async => const ResolvedPrice(100, 0, 'cache'));

    final s = await state();
    expect(s.offline, isTrue);
  });

  test('refresh snapshot: upserts + reloads history', () async {
    await db.into(db.portfolios).insert(
        PortfoliosCompanion.insert(id: 'p1', name: 'M', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1',
        portfolioId: 'p1',
        type: 'crypto',
        symbol: 'BTC',
        name: 'B',
        currency: Value('USD')));
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
        id: 't1',
        assetId: 'a1',
        side: 'buy',
        quantity: 1,
        price: 100,
        date: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z'));

    when(() => mockPrice.resolve(any())).thenAnswer(
        (_) async => const ResolvedPrice(100, 0, 'live'));

    await notifier().refresh();

    // verify snapshot row
    final rows = await db.select(db.netWorthHistory).get();
    expect(rows, hasLength(1));
    expect(rows.first.netWorthThb, closeTo(3500, 0.01));

    // verify history reloaded
    final s = await state();
    expect(s.history, hasLength(1));
  });

  // --- invalidation edges from the other notifiers -------------------------
  //
  // `build()` above reads the repos with `ref.read`, not `ref.watch`, so a
  // write in another notifier does not propagate here on its own — each one
  // has to invalidate `overviewProvider` explicitly. Every test below keeps
  // this provider alive with `container.listen`: it is autoDispose, and
  // without a listener it is thrown away after the first read, so the second
  // read rebuilds from scratch and passes even when the edge is missing.
  //
  // A widget test cannot see any of this — screen tests override the notifier
  // methods themselves, so `_reload()` never runs.

  Future<void> seedPortfolioWithAsset() async {
    await db
        .into(db.portfolios)
        .insert(PortfoliosCompanion.insert(id: 'p1', name: 'M', color: 0));
    await db.into(db.assets).insert(AssetsCompanion.insert(
        id: 'a1',
        portfolioId: 'p1',
        type: 'crypto',
        symbol: 'BTC',
        name: 'B',
        currency: Value('USD')));
  }

  Future<void> seedTx() =>
      db.into(db.transactions).insert(TransactionsCompanion.insert(
          id: 't1',
          assetId: 'a1',
          side: 'buy',
          quantity: 1,
          price: 100,
          date: '2026-01-01',
          createdAt: '2026-01-01T00:00:00Z'));

  test('LiabilitiesNotifier write refreshes Net Worth', () async {
    when(() => mockPrice.resolve(any()))
        .thenAnswer((_) async => const ResolvedPrice(100, 0, 'live'));
    container.listen(overviewProvider, (_, _) {});
    expect((await state()).summary!.netWorthThb, closeTo(0, 0.01));

    await container
        .read(liabilitiesProvider.notifier)
        .addLiability(name: 'Card', amount: 1000, currency: 'THB');

    expect((await state()).summary!.netWorthThb, closeTo(-1000, 0.01),
        reason: 'the Net Worth hero still shows the pre-write number');
  });

  test('TransactionsNotifier write refreshes Net Worth', () async {
    when(() => mockPrice.resolve(any()))
        .thenAnswer((_) async => const ResolvedPrice(100, 0, 'live'));
    await seedPortfolioWithAsset();
    container.listen(overviewProvider, (_, _) {});
    expect((await state()).summary!.netWorthThb, closeTo(0, 0.01));

    await container.read(transactionsProvider.notifier).addTransaction(
        assetId: 'a1',
        side: 'buy',
        quantity: 1,
        price: 100,
        date: '2026-01-01');

    expect((await state()).summary!.netWorthThb, closeTo(3500, 0.01),
        reason: 'recording a buy left Net Worth on the pre-write number');
  });

  test('PortfoliosNotifier write refreshes Net Worth', () async {
    when(() => mockPrice.resolve(any()))
        .thenAnswer((_) async => const ResolvedPrice(100, 0, 'live'));
    await seedPortfolioWithAsset();
    await seedTx();
    container.listen(overviewProvider, (_, _) {});
    expect((await state()).summary!.netWorthThb, closeTo(3500, 0.01));

    await container.read(portfoliosProvider.notifier).deleteAsset('a1');

    expect((await state()).summary!.netWorthThb, closeTo(0, 0.01),
        reason: 'the deleted asset is still counted in Net Worth');
  });
}
