import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/portfolio_asset_dao.dart';
import '../state/providers.dart';

const _types = {'crypto', 'th', 'us', 'fund', 'deposit'};
const _ccy = {'THB', 'USD'};
const _dir = {'long', 'short'};

class AssetRepo {
  final PortfolioAssetDao dao;
  AssetRepo(this.dao);

  void _validate(
    String type,
    String symbol,
    String name,
    String currency,
    String direction,
    double? manualPrice,
  ) {
    if (name.trim().isEmpty) throw ArgumentError('name');
    if (symbol.trim().isEmpty) throw ArgumentError('symbol');
    if (!_types.contains(type)) throw ArgumentError('type');
    if (!_ccy.contains(currency)) throw ArgumentError('currency');
    if (!_dir.contains(direction)) throw ArgumentError('direction');
    if (manualPrice != null && manualPrice < 0) throw ArgumentError('manualPrice');
  }

  Future<Asset> create({
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
    _validate(type, symbol, name, currency, direction, manualPrice);

    final order = (await dao.assetsFor(portfolioId)).length;
    final id = const Uuid().v4();

    await dao.upsertAsset(
      AssetsCompanion.insert(
        id: id,
        portfolioId: portfolioId,
        type: type,
        symbol: symbol.trim(),
        name: name.trim(),
        currency: Value(currency),
        cgId: Value(cgId),
        yahooSymbol: Value(yahooSymbol),
        manualPrice: Value(manualPrice),
        direction: Value(direction),
        sortOrder: Value(order),
      ),
    );
    return Asset(
      id: id,
      portfolioId: portfolioId,
      type: type,
      symbol: symbol.trim(),
      name: name.trim(),
      currency: currency,
      cgId: cgId,
      yahooSymbol: yahooSymbol,
      manualPrice: manualPrice,
      direction: direction,
      sortOrder: order,
    );
  }

  Future<void> save(Asset a) async {
    _validate(a.type, a.symbol, a.name, a.currency, a.direction, a.manualPrice);

    final existing = (await dao.assetsFor(a.portfolioId))
        .where((x) => x.id == a.id)
        .firstOrNull;
    if (existing != null && existing.currency != a.currency) {
      throw ArgumentError('currency is locked');
    }
    await dao.upsertAsset(a.toCompanion(true));
  }

  Future<void> remove(String id) => dao.deleteAsset(id);

  Future<List<Asset>> allFor(String pid) => dao.assetsFor(pid);

  Future<List<Asset>> all() => dao.allAssets();
}

final assetRepoProvider =
    Provider((ref) => AssetRepo(ref.watch(portfolioAssetDaoProvider)));
