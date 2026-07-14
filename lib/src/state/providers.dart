import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database.dart';
import '../db/portfolio_asset_dao.dart';
import '../db/transaction_dao.dart';
import '../db/liability_dao.dart';
import '../db/misc_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('override in main() / tests'));

final portfolioAssetDaoProvider = Provider((ref) => PortfolioAssetDao(ref.watch(appDatabaseProvider)));
final transactionDaoProvider    = Provider((ref) => TransactionDao(ref.watch(appDatabaseProvider)));
final liabilityDaoProvider      = Provider((ref) => LiabilityDao(ref.watch(appDatabaseProvider)));
final miscDaoProvider           = Provider((ref) => MiscDao(ref.watch(appDatabaseProvider)));
