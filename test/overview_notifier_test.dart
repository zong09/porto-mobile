import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/prices/price_repository.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';

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
}
