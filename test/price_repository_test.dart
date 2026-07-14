import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/db/misc_dao.dart';
import 'package:porto_mobile/src/prices/binance_client.dart';
import 'package:porto_mobile/src/prices/yahoo_client.dart';
import 'package:porto_mobile/src/prices/price_repository.dart';

class MockBinance extends Mock implements BinanceClient {}

class MockYahoo extends Mock implements YahooClient {}

Asset asset({
  required String type,
  String symbol = 'BTC',
  String currency = 'USD',
  double? manualPrice,
  String? yahooSymbol,
}) =>
    Asset(
      id: 'x',
      portfolioId: 'p',
      type: type,
      symbol: symbol,
      name: 'n',
      currency: currency,
      cgId: null,
      yahooSymbol: yahooSymbol,
      manualPrice: manualPrice,
      direction: 'long',
      sortOrder: 0,
    );

void main() {
  late AppDatabase db;
  late MiscDao dao;
  late MockBinance mockBinance;
  late MockYahoo mockYahoo;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = MiscDao(db);
    mockBinance = MockBinance();
    mockYahoo = MockYahoo();
  });

  tearDown(() => db.close());

  test('1. deposit → fixed price', () async {
    final repo = PriceRepository(dao, mockBinance, mockYahoo);
    final result = await repo.resolve(asset(type: 'deposit'));
    expect(result.price, 1);
    expect(result.chg24h, 0);
    expect(result.source, 'fixed');
    verifyNever(() => mockBinance.getPrices(any()));
    verifyNever(() => mockYahoo.getStockPrice(any()));
  });

  test('2. fund → manual price', () async {
    final repo = PriceRepository(dao, mockBinance, mockYahoo);
    final result = await repo.resolve(asset(type: 'fund', manualPrice: 12.5));
    expect(result.price, 12.5);
    expect(result.chg24h, 0);
    expect(result.source, 'manual');
  });

  test('3. crypto live', () async {
    when(() => mockBinance.getPrices(any()))
        .thenAnswer((_) async => {'BTC': const CryptoPrice(usd: 100, usdChg: 5, thb: 3600, thbChg: 5)});

    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    final repo = PriceRepository(dao, mockBinance, mockYahoo, now: () => t0);
    final result = await repo.resolve(asset(type: 'crypto', currency: 'USD'));

    expect(result.price, 100);
    expect(result.chg24h, 5);
    expect(result.source, 'live');

    // verify cache was persisted
    final cached = await dao.getPrice('crypto:BTC');
    expect(cached, isNotNull);
    expect(cached!.price, 100);
    expect(cached.chg24h, 5);
  });

  test('4. crypto fresh cache hit', () async {
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    await dao.putPrice(PriceCacheCompanion.insert(
      key: 'crypto:BTC',
      price: 999,
      chg24h: const Value(1),
      currency: 'USD',
      fetchedAt: t0.toIso8601String(),
    ));

    final repo = PriceRepository(dao, mockBinance, mockYahoo,
        now: () => t0.add(const Duration(seconds: 30)));
    final result = await repo.resolve(asset(type: 'crypto', symbol: 'BTC', currency: 'USD'));

    expect(result.price, 999);
    expect(result.chg24h, 1);
    expect(result.source, 'cache');
    verifyNever(() => mockBinance.getPrices(any()));
  });

  test('5. stale cache → live', () async {
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    await dao.putPrice(PriceCacheCompanion.insert(
      key: 'crypto:BTC',
      price: 999,
      chg24h: const Value(1),
      currency: 'USD',
      fetchedAt: t0.toIso8601String(),
    ));

    when(() => mockBinance.getPrices(any()))
        .thenAnswer((_) async => {'BTC': const CryptoPrice(usd: 200, usdChg: 3, thb: 7200, thbChg: 3)});

    final repo = PriceRepository(dao, mockBinance, mockYahoo,
        now: () => t0.add(const Duration(seconds: 120)));
    final result = await repo.resolve(asset(type: 'crypto', symbol: 'BTC', currency: 'USD'));

    expect(result.price, 200);
    expect(result.chg24h, 3);
    expect(result.source, 'live');
  });

  test('6. fallback to cache on error', () async {
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    await dao.putPrice(PriceCacheCompanion.insert(
      key: 'crypto:BTC',
      price: 50,
      chg24h: const Value(0),
      currency: 'USD',
      fetchedAt: t0.toIso8601String(),
    ));

    when(() => mockBinance.getPrices(any())).thenThrow(Exception('net'));

    final repo = PriceRepository(dao, mockBinance, mockYahoo,
        now: () => t0.add(const Duration(seconds: 120)));
    final result = await repo.resolve(asset(type: 'crypto', symbol: 'BTC', currency: 'USD'));

    expect(result.price, 50);
    expect(result.source, 'cache');
  });

  test('7. stock native + .BK suffix', () async {
    when(() => mockYahoo.getStockPrice('PTT.BK'))
        .thenAnswer((_) async => const StockQuote(price: 35, chg: -1));

    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
    final repo = PriceRepository(dao, mockBinance, mockYahoo, now: () => t0);
    final result =
        await repo.resolve(asset(type: 'th', symbol: 'PTT', currency: 'THB'));

    expect(result.price, 35);
    expect(result.chg24h, -1);
    expect(result.source, 'live');
    verify(() => mockYahoo.getStockPrice('PTT.BK')).called(1);
  });
}
