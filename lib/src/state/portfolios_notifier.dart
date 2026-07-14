import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/database.dart';
import '../domain/position_calculator.dart';
import '../repos/portfolio_repo.dart';
import '../repos/asset_repo.dart';
import '../repos/transaction_repo.dart';

part 'portfolios_notifier.freezed.dart';
part 'portfolios_notifier.g.dart';

@freezed
abstract class AssetNode with _$AssetNode {
  const factory AssetNode({required Asset asset, required PositionSummary position}) =
      _AssetNode;
}

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

  Future<void> _reload() async {
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
