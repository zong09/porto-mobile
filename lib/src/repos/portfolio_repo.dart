import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/portfolio_asset_dao.dart';
import '../state/providers.dart';

class PortfolioRepo {
  final PortfolioAssetDao dao;
  PortfolioRepo(this.dao);

  Future<Portfolio> create({required String name, required int color}) async {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('name');
    if (color < 0 || color > 5) throw ArgumentError('color');

    final order = (await dao.allPortfolios()).length;
    final id = const Uuid().v4();

    await dao.upsertPortfolio(
      PortfoliosCompanion.insert(id: id, name: n, color: color, sortOrder: Value(order)),
    );
    return Portfolio(id: id, name: n, color: color, sortOrder: order);
  }

  Future<void> save(Portfolio p) async {
    if (p.name.trim().isEmpty) throw ArgumentError('name');
    if (p.color < 0 || p.color > 5) throw ArgumentError('color');
    await dao.upsertPortfolio(p.toCompanion(true));
  }

  Future<void> remove(String id) => dao.deletePortfolio(id);

  Future<void> reorder(List<String> ids) => dao.reorderPortfolios(ids);

  Future<List<Portfolio>> all() => dao.allPortfolios();
}

final portfolioRepoProvider =
    Provider((ref) => PortfolioRepo(ref.watch(portfolioAssetDaoProvider)));
