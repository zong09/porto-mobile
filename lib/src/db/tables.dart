import 'package:drift/drift.dart';

class Portfolios extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get portfolioId =>
      text().references(Portfolios, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get symbol => text()();
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('THB'))();
  TextColumn get cgId => text().nullable()();
  TextColumn get yahooSymbol => text().nullable()();
  RealColumn get manualPrice => real().nullable()();
  TextColumn get direction => text().withDefault(const Constant('long'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();
  TextColumn get side => text()();
  RealColumn get quantity => real()();
  RealColumn get price => real()();
  RealColumn get fee => real().withDefault(const Constant(0))();
  TextColumn get date => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Liabilities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('THB'))();

  @override
  Set<Column> get primaryKey => {id};
}

class LiabilityTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get liabilityId =>
      text().references(Liabilities, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get date => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class NetWorthHistory extends Table {
  TextColumn get date => text()();
  RealColumn get totalAssetsThb => real()();
  RealColumn get totalLiabilitiesThb => real()();
  RealColumn get netWorthThb => real()();
  RealColumn get fxRate => real().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

class PriceCache extends Table {
  TextColumn get key => text()();
  RealColumn get price => real()();
  RealColumn get chg24h => real().withDefault(const Constant(0))();
  TextColumn get currency => text()();
  TextColumn get fetchedAt => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
