import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../db/database.dart';
import '../db/misc_dao.dart';
import '../domain/position_calculator.dart';
import '../domain/net_worth_calculator.dart';
import '../prices/price_repository.dart';
import '../prices/yahoo_client.dart';
import '../repos/portfolio_repo.dart';
import '../repos/asset_repo.dart';
import '../repos/transaction_repo.dart';
import '../repos/liability_repo.dart';
import '../state/providers.dart';
part 'overview_notifier.freezed.dart';
part 'overview_notifier.g.dart';

/// Fetches THB/USD FX with a persistent last-known fallback so the app stays
/// usable offline (mirrors the price fallback chain, CONTRACTS §11). On success
/// the rate is cached to `price_cache['fx']`; on failure the last cached rate is
/// returned. Rethrows only when the rate has never been cached (first-run
/// offline), which the notifier surfaces as its error state.
Future<double> fetchFxCached(
  MiscDao dao,
  Future<double> Function() fetch, {
  DateTime Function() now = DateTime.now,
}) async {
  try {
    final rate = await fetch();
    await dao.putPrice(PriceCacheCompanion.insert(
      key: 'fx',
      price: rate,
      currency: 'THB',
      fetchedAt: now().toUtc().toIso8601String(),
    ));
    return rate;
  } catch (_) {
    final cached = await dao.getPrice('fx');
    if (cached != null) return cached.price;
    rethrow;
  }
}

final fxProvider = Provider<Future<double> Function()>((ref) {
  final dao = ref.watch(miscDaoProvider);
  return () => fetchFxCached(dao, () => YahooClient(Dio()).getFxRate());
});

@freezed
abstract class OverviewState with _$OverviewState {
  const factory OverviewState({
    required NetWorthSummary? summary,
    required List<NetWorthHistoryData> history,
    required String? asOf,
    required bool offline,
  }) = _OverviewState;
}

@riverpod
class OverviewNotifier extends _$OverviewNotifier {
  @override
  Future<OverviewState> build() async {
    final pRepo = ref.read(portfolioRepoProvider);
    final aRepo = ref.read(assetRepoProvider);
    final tRepo = ref.read(transactionRepoProvider);
    final lRepo = ref.read(liabilityRepoProvider);
    final priceRepo = ref.read(priceRepositoryProvider);
    final miscDao = ref.read(miscDaoProvider);

    final assetInputs = <AssetInput>[];
    var offline = false;
    for (final p in await pRepo.all()) {
      for (final a in await aRepo.allFor(p.id)) {
        final txs = (await tRepo.byAsset(a.id))
            .map((t) => TxInput(
                quantity: t.quantity,
                price: t.price,
                fee: t.fee,
                side: t.side,
                date: t.date))
            .toList();
        final rp = await priceRepo.resolve(a);
        if (rp.source == 'cache' || rp.source == 'none') offline = true;
        assetInputs.add(AssetInput(
            type: a.type,
            currency: a.currency,
            direction: a.direction,
            manualPrice: a.manualPrice,
            txs: txs,
            price: rp.price,
            chg24h: rp.chg24h));
      }
    }
    final liabs = (await lRepo.all())
        .map((l) => LiabilityInput(amount: l.amount, currency: l.currency))
        .toList();
    final fx = await ref.read(fxProvider)();
    final summary = NetWorthCalculator.summary(
        assets: assetInputs, liabilities: liabs, fx: fx);
    final history = await miscDao.history();
    return OverviewState(
        summary: summary,
        history: history,
        asOf: DateTime.now().toUtc().toIso8601String(),
        offline: offline);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    final st = await future;
    final s = st.summary;
    if (s != null) {
      final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
      await ref.read(miscDaoProvider).upsertSnapshot(NetWorthHistoryData(
          date: today,
          totalAssetsThb: s.totalAssetsThb,
          totalLiabilitiesThb: s.totalLiabilitiesThb,
          netWorthThb: s.netWorthThb,
          fxRate: s.fx));
      ref.invalidateSelf();
      await future;
    }
  }
}
