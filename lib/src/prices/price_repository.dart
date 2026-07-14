import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database.dart';
import '../db/misc_dao.dart';
import 'binance_client.dart';
import 'yahoo_client.dart';
import '../state/providers.dart';

/// Result of resolving an asset's current price in its native currency.
class ResolvedPrice {
  /// Price in the asset's native currency.
  final double price;

  /// 24h % change.
  final double chg24h;

  /// Source of the price: 'fixed' | 'manual' | 'cache' | 'live' | 'none'.
  final String source;

  const ResolvedPrice(this.price, this.chg24h, this.source);
}

/// Resolves an asset's current price in its native currency + 24h change,
/// with a TTL'd DB cache and a fallback chain (CONTRACTS §11).
class PriceRepository {
  final MiscDao dao;
  final BinanceClient binance;
  final YahooClient yahoo;
  final DateTime Function() now;

  PriceRepository(this.dao, this.binance, this.yahoo, {DateTime Function()? now})
      : now = now ?? DateTime.now;

  /// Resolve the price for [asset].
  Future<ResolvedPrice> resolve(Asset asset) async {
    // 1. deposit → fixed
    if (asset.type == 'deposit') {
      return const ResolvedPrice(1, 0, 'fixed');
    }

    // 2. fund → manual price
    if (asset.type == 'fund') {
      return ResolvedPrice(asset.manualPrice ?? 0, 0, 'manual');
    }

    // 3. crypto / th / us
    final isCrypto = asset.type == 'crypto';
    final key = isCrypto ? 'crypto:${asset.symbol}' : 'stock:${asset.symbol}';
    final ttl = isCrypto ? const Duration(seconds: 60) : const Duration(seconds: 90);

    // 3a — check cache
    final cached = await dao.getPrice(key);
    if (cached != null &&
        now().difference(DateTime.parse(cached.fetchedAt)) < ttl) {
      return ResolvedPrice(cached.price, cached.chg24h, 'cache');
    }

    // 3b — try live
    try {
      double native;
      double chg;
      if (isCrypto) {
        final cp = (await binance.getPrices([asset.symbol]))[asset.symbol];
        if (cp == null) throw StateError('no price');
        native = asset.currency == 'USD' ? cp.usd : cp.thb;
        chg = asset.currency == 'USD' ? cp.usdChg : cp.thbChg;
      } else {
        final ysym = asset.yahooSymbol ??
            (asset.type == 'th' ? '${asset.symbol}.BK' : asset.symbol);
        final q = await yahoo.getStockPrice(ysym);
        native = q.price;
        chg = q.chg;
      }

      // persist cache
      await dao.putPrice(PriceCacheCompanion.insert(
        key: key,
        price: native,
        chg24h: Value(chg),
        currency: asset.currency,
        fetchedAt: now().toUtc().toIso8601String(),
      ));
      return ResolvedPrice(native, chg, 'live');
    } catch (_) {
      // 3c — fallback chain
      if (cached != null) {
        return ResolvedPrice(cached.price, cached.chg24h, 'cache');
      }
      if (asset.manualPrice != null) {
        return ResolvedPrice(asset.manualPrice!, 0, 'manual');
      }
      return const ResolvedPrice(0, 0, 'none');
    }
  }
}

/// Infra provider for PriceRepository.
final priceRepositoryProvider = Provider((ref) => PriceRepository(
      ref.watch(miscDaoProvider),
      BinanceClient(Dio(), getFx: () async => YahooClient(Dio()).getFxRate()),
      YahooClient(Dio()),
    ));
