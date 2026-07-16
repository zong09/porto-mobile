// T4.2 — end-to-end smoke flow (Phase 4).
//
// A headless full-app widget test: it drives the *real* app widget (PortoApp)
// over the *real* provider graph and a *real* on-disk SQLite DB — only the two
// price clients are mocked, so the price-cache persistence + offline fallback
// chain is genuinely exercised. (On-device `integration_test/` isn't used: this
// repo has no desktop/web runner and there's no emulator here, so this runs
// under plain `flutter test` where it can actually be verified.)
//
// Flow:
//   1. Seed portfolio → asset (crypto BTC + TH stock) → buy tx via the repos.
//   2. Launch the app "online"; assert the rendered Net Worth matches
//      NetWorthCalculator and no offline banner shows. This also persists live
//      prices into `price_cache`.
//   3. Simulate kill → relaunch on the SAME db file with the clients now
//      throwing and the clock advanced past the cache TTL; assert the data +
//      last-known prices are still shown and the offline banner appears.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:porto_mobile/main.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/domain/formatters.dart';
import 'package:porto_mobile/src/domain/net_worth_calculator.dart';
import 'package:porto_mobile/src/domain/position_calculator.dart';
import 'package:porto_mobile/src/prices/binance_client.dart';
import 'package:porto_mobile/src/prices/price_repository.dart';
import 'package:porto_mobile/src/prices/yahoo_client.dart';
import 'package:porto_mobile/src/repos/asset_repo.dart';
import 'package:porto_mobile/src/repos/portfolio_repo.dart';
import 'package:porto_mobile/src/repos/transaction_repo.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';

class _MockBinance extends Mock implements BinanceClient {}

class _MockYahoo extends Mock implements YahooClient {}

void main() {
  // Fixed price inputs (native currency), matched by the mocks below.
  const btcUsd = 100.0; // BTC quoted in USD
  const pttThb = 40.0; // PTT (TH stock) quoted in THB
  const fx = 35.0;

  // Frozen clock: phase 1 writes cache at t0; phase 2 reads at t0 + 5 min,
  // which is past the 60s/90s TTLs, forcing the live→cache fallback path.
  final t0 = DateTime.utc(2026, 7, 16, 12, 0, 0);
  final tLater = t0.add(const Duration(minutes: 5));

  // Expected Net Worth, straight from NetWorthCalculator (the on-screen value
  // must equal this): 1 BTC @ 100 USD * 35 = 3500 THB + 10 PTT @ 40 THB = 400.
  final expected = NetWorthCalculator.summary(
    assets: [
      AssetInput(
        type: 'crypto',
        currency: 'USD',
        direction: 'long',
        manualPrice: null,
        txs: const [
          TxInput(quantity: 1, price: btcUsd, fee: 0, side: 'buy', date: '2026-07-01'),
        ],
        price: btcUsd,
        chg24h: 0,
      ),
      AssetInput(
        type: 'th',
        currency: 'THB',
        direction: 'long',
        manualPrice: null,
        txs: const [
          TxInput(quantity: 10, price: pttThb, fee: 0, side: 'buy', date: '2026-07-01'),
        ],
        price: pttThb,
        chg24h: 0,
      ),
    ],
    liabilities: const [],
    fx: fx,
  );
  final expectedMoney = Formatters.money(expected.netWorthThb, currency: 'THB');

  late File dbFile;

  setUp(() {
    dbFile = File('${Directory.systemTemp.path}/porto_smoke_test.sqlite');
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('${dbFile.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
  });

  tearDown(() {
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('${dbFile.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
  });

  /// Pump until [finder] matches or a budget of frames elapses (avoids
  /// pumpAndSettle, which never settles while the loading spinner animates).
  Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  overridesFor(
    AppDatabase db,
    BinanceClient binance,
    YahooClient yahoo,
    DateTime Function() now,
  ) =>
      [
        appDatabaseProvider.overrideWithValue(db),
        priceRepositoryProvider.overrideWith(
          (ref) => PriceRepository(
            ref.watch(miscDaoProvider),
            binance,
            yahoo,
            now: now,
          ),
        ),
        // fx comes from a separate provider; pin it so the flow is deterministic.
        fxProvider.overrideWithValue(() async => fx),
      ];

  testWidgets('create → totals match calculator → relaunch offline persists',
      (tester) async {
    // ── Phase 1: online launch ──────────────────────────────────────────
    final db1 = AppDatabase(NativeDatabase(dbFile));

    final binance1 = _MockBinance();
    final yahoo1 = _MockYahoo();
    when(() => binance1.getPrices(any())).thenAnswer(
      (_) async => {
        'BTC': const CryptoPrice(
            usd: btcUsd, usdChg: 0, thb: btcUsd * fx, thbChg: 0),
      },
    );
    when(() => yahoo1.getStockPrice(any()))
        .thenAnswer((_) async => const StockQuote(price: pttThb, chg: 0));

    final overrides1 = overridesFor(db1, binance1, yahoo1, () => t0);

    // Seed via the real repos (same create path the UI uses).
    final seed = ProviderContainer(overrides: overrides1);
    final p = await seed.read(portfolioRepoProvider).create(name: 'Main', color: 0);
    final btc = await seed.read(assetRepoProvider).create(
        portfolioId: p.id, type: 'crypto', symbol: 'BTC', name: 'Bitcoin', currency: 'USD');
    final ptt = await seed.read(assetRepoProvider).create(
        portfolioId: p.id, type: 'th', symbol: 'PTT', name: 'PTT', currency: 'THB');
    await seed.read(transactionRepoProvider).add(
        assetId: btc.id, side: 'buy', quantity: 1, price: btcUsd, date: '2026-07-01');
    await seed.read(transactionRepoProvider).add(
        assetId: ptt.id, side: 'buy', quantity: 10, price: pttThb, date: '2026-07-01');
    seed.dispose();

    await tester.pumpWidget(
      ProviderScope(overrides: overrides1, child: const PortoApp()),
    );
    await pumpUntil(tester, find.text(expectedMoney));

    expect(find.text(expectedMoney), findsWidgets,
        reason: 'Overview hero must show the NetWorthCalculator total');
    expect(find.textContaining('as of'), findsNothing,
        reason: 'online: no offline banner');

    // ── Phase 2: kill → relaunch offline ────────────────────────────────
    await tester.pumpWidget(const SizedBox.shrink()); // unmount → "kill"
    await tester.pump();
    await db1.close();

    final binance2 = _MockBinance();
    final yahoo2 = _MockYahoo();
    when(() => binance2.getPrices(any())).thenThrow(Exception('offline'));
    when(() => yahoo2.getStockPrice(any())).thenThrow(Exception('offline'));

    final db2 = AppDatabase(NativeDatabase(dbFile)); // same file → persisted data
    final overrides2 = overridesFor(db2, binance2, yahoo2, () => tLater);

    await tester.pumpWidget(
      ProviderScope(overrides: overrides2, child: const PortoApp()),
    );
    await pumpUntil(tester, find.textContaining('as of'));

    expect(find.text(expectedMoney), findsWidgets,
        reason: 'offline: net worth still computed from last-known cached prices');
    expect(find.textContaining('as of'), findsOneWidget,
        reason: 'offline: "as of" banner shown');

    await db2.close();
  });
}
