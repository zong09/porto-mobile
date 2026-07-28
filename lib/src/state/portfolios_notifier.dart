import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/database.dart';
import '../domain/currency_converter.dart';
import '../domain/position_calculator.dart';
import '../repos/portfolio_repo.dart';
import '../repos/asset_repo.dart';
import '../repos/transaction_repo.dart';
import 'overview_notifier.dart';
import 'transactions_notifier.dart';

part 'portfolios_notifier.freezed.dart';
part 'portfolios_notifier.g.dart';

@freezed
abstract class AssetNode with _$AssetNode {
  const factory AssetNode({required Asset asset, required PositionSummary position}) =
      _AssetNode;
}

// ── native → THB helpers ────────────────────────────────────────────────────
//
// `PositionSummary.totalCost` / `.realizedPnl` are denominated in the asset's
// NATIVE currency (locked at creation, CONTRACTS §7). The rule, per
// docs/phase5-handoff.md §2:
//
//   * AGGREGATES over possibly-mixed assets — portfolio/screen totals, and the
//     proportions behind allocation bars — MUST convert first, or a USD holding
//     is counted as THB. Use these helpers.
//   * SINGLE-ASSET rows keep their own amount and their own glyph. Do not
//     convert those.

double assetCostThb(AssetNode an, double fx) =>
    CurrencyConverter.toThb(an.position.totalCost, an.asset.currency, fx);

double assetRealizedPnlThb(AssetNode an, double fx) =>
    CurrencyConverter.toThb(an.position.realizedPnl, an.asset.currency, fx);

double assetsCostThb(Iterable<AssetNode> assets, double fx) =>
    assets.fold<double>(0, (sum, an) => sum + assetCostThb(an, fx));

double nodeCostThb(PortfolioNode node, double fx) =>
    assetsCostThb(node.assets, fx);

@freezed
abstract class PortfolioNode with _$PortfolioNode {
  const factory PortfolioNode({required Portfolio portfolio, required List<AssetNode> assets}) =
      _PortfolioNode;
}

@freezed
abstract class PortfoliosState with _$PortfoliosState {
  const factory PortfoliosState({required List<PortfolioNode> nodes}) = _PortfoliosState;
}

@riverpod
class PortfoliosNotifier extends _$PortfoliosNotifier {
  PortfolioRepo get _pRepo => ref.read(portfolioRepoProvider);
  AssetRepo get _aRepo => ref.read(assetRepoProvider);
  TransactionRepo get _tRepo => ref.read(transactionRepoProvider);

  @override
  Future<PortfoliosState> build() async {
    final ports = await _pRepo.all();
    final nodes = <PortfolioNode>[];
    for (final p in ports) {
      final assets = await _aRepo.allFor(p.id);
      final assetNodes = <AssetNode>[];
      for (final a in assets) {
        final txs = await _tRepo.byAsset(a.id);
        final inputs = txs
            .map(
              (t) => TxInput(
                quantity: t.quantity,
                price: t.price,
                fee: t.fee,
                side: t.side,
                date: t.date,
              ),
            )
            .toList();
        final pos = PositionCalculator.calculate(inputs, direction: a.direction);
        assetNodes.add(AssetNode(asset: a, position: pos));
      }
      nodes.add(PortfolioNode(portfolio: p, assets: assetNodes));
    }
    return PortfoliosState(nodes: nodes);
  }

  /// The mirror of `TransactionsNotifier._reload`, which invalidates this
  /// provider for the same reason. `transactions.assetId` and
  /// `assets.portfolioId` both cascade, so deleting an asset or a portfolio
  /// destroys transaction rows — and `TransactionsNotifier` never notices:
  /// it is autoDispose, but `AppShell`'s `IndexedStack` keeps
  /// `TransactionsScreen` mounted on every tab, so nothing disposes it and it
  /// keeps rendering rows for transactions the DB no longer has. `saveAsset`
  /// has the milder version — a renamed asset leaves stale row titles.
  ///
  /// `overviewProvider` too: `OverviewNotifier.build` reads the repos directly
  /// (`ref.read`, not `ref.watch`), so nothing propagates to it and the Net
  /// Worth hero holds the pre-write number until pull-to-refresh.
  Future<void> _reload() async {
    ref.invalidate(transactionsProvider);
    ref.invalidate(overviewProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> addPortfolio({required String name, required int color}) async {
    await _pRepo.create(name: name, color: color);
    await _reload();
  }

  Future<void> renamePortfolio(String id, String name) async {
    final p = (await _pRepo.all()).firstWhere((x) => x.id == id);
    await _pRepo.save(p.copyWith(name: name));
    await _reload();
  }

  Future<void> recolorPortfolio(String id, int color) async {
    final p = (await _pRepo.all()).firstWhere((x) => x.id == id);
    await _pRepo.save(p.copyWith(color: color));
    await _reload();
  }

  Future<void> deletePortfolio(String id) async {
    await _pRepo.remove(id);
    await _reload();
  }

  Future<void> reorderPortfolios(List<String> ids) async {
    await _pRepo.reorder(ids);
    await _reload();
  }

  Future<void> addAsset({
    required String portfolioId,
    required String type,
    required String symbol,
    required String name,
    required String currency,
    String? cgId,
    String? yahooSymbol,
    double? manualPrice,
    String direction = 'long',
  }) async {
    await _aRepo.create(
      portfolioId: portfolioId,
      type: type,
      symbol: symbol,
      name: name,
      currency: currency,
      cgId: cgId,
      yahooSymbol: yahooSymbol,
      manualPrice: manualPrice,
      direction: direction,
    );
    await _reload();
  }

  Future<void> saveAsset(Asset asset) async {
    await _aRepo.save(asset);
    await _reload();
  }

  Future<void> deleteAsset(String id) async {
    await _aRepo.remove(id);
    await _reload();
  }
}
