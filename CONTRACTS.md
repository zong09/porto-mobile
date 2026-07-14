# CONTRACTS — frozen (Phase 1 scope)

Source of truth. Dispatched (Qwen) tasks implement these **exactly** — never rename, never
"improve". Contract changes go through Claude only. Money is stored as `REAL` in DB and wrapped
to `Decimal` (package:decimal) only inside domain math; models/DAOs use plain `double`.

App is **single-user, local-only** — there is **no `userId`** anywhere (the backend had one; drop it).

---

## 1. Enums (`lib/src/models/enums.dart`)

```
enum AssetType   { crypto, th, us, fund, deposit }
enum Currency    { thb, usd }          // JSON/DB value = uppercase 'THB' | 'USD'
enum TxSide      { buy, sell, deposit, withdraw }
enum Direction   { long, short }
enum LiabilityTxType { pay, add }
```

JSON/DB string mapping rules (freeze):
- `Currency`  ↔ `'THB'` / `'USD'` (UPPERCASE).
- `AssetType`, `TxSide`, `Direction`, `LiabilityTxType` ↔ their lowercase name (`'crypto'`, `'buy'`, `'long'`, `'pay'`).
- Every enum exposes `String get wire` (the stored string) and a static `fromWire(String)` factory.

---

## 2. Drift tables (`lib/src/db/tables.dart`)

All ids `TEXT` (UUID v4, generated on-device). Dates `TEXT` `YYYY-MM-DD`. Timestamps `TEXT` ISO-8601.
Money `REAL`. Enums stored as their `wire` string in a `TEXT` column. FKs `ON DELETE CASCADE`.

| Table | Column → type (constraints) |
|---|---|
| `portfolios` | `id` TEXT PK · `name` TEXT · `color` INT (0–5) · `sortOrder` INT default 0 |
| `assets` | `id` TEXT PK · `portfolioId` TEXT FK→portfolios.id CASCADE · `type` TEXT · `symbol` TEXT · `name` TEXT · `currency` TEXT default 'THB' · `cgId` TEXT? · `yahooSymbol` TEXT? · `manualPrice` REAL? · `direction` TEXT default 'long' · `sortOrder` INT default 0 |
| `transactions` | `id` TEXT PK · `assetId` TEXT FK→assets.id CASCADE · `side` TEXT · `quantity` REAL · `price` REAL · `fee` REAL default 0 · `date` TEXT · `createdAt` TEXT |
| `liabilities` | `id` TEXT PK · `name` TEXT · `amount` REAL · `currency` TEXT default 'THB' |
| `liabilityTransactions` | `id` TEXT PK · `liabilityId` TEXT FK→liabilities.id CASCADE · `type` TEXT · `amount` REAL · `date` TEXT · `createdAt` TEXT |
| `netWorthHistory` | `date` TEXT PK · `totalAssetsThb` REAL · `totalLiabilitiesThb` REAL · `netWorthThb` REAL · `fxRate` REAL? |
| `priceCache` | `key` TEXT PK (`crypto:BTC`,`stock:AAPL`,`fx`) · `price` REAL · `chg24h` REAL default 0 · `currency` TEXT · `fetchedAt` TEXT |
| `settings` | `key` TEXT PK · `value` TEXT |

Drift table class names (PascalCase, no `s`): `Portfolios`, `Assets`, `Transactions`,
`Liabilities`, `LiabilityTransactions`, `NetWorthHistory`, `PriceCache`, `Settings`.
Drift DB class: `AppDatabase` in `lib/src/db/database.dart`, `schemaVersion => 1`.

---

## 3. Domain models (`lib/src/models/*.dart`, freezed)

Plain immutable data classes mirroring the table columns 1:1 (same field names, `double` for money,
enums for the enum columns). One freezed class per table row + JSON (`fromJson`/`toJson`) for
export/import:

`Portfolio`, `Asset`, `TransactionModel`, `Liability`, `LiabilityTransaction`,
`NetWorthSnapshot`, `PriceCacheEntry`.

> Note: the transaction model is named **`TransactionModel`** (not `Transaction`) to avoid
> colliding with Drift's generated `Transaction` companion.

---

## 4. Domain calculators (`lib/src/domain/`) — plain inputs, no freezed/drift deps

These are pure functions and take **plain** inputs so they compile independently of models/db.

### 4.1 `position_calculator.dart`

```dart
class TxInput {                 // plain, not the freezed model
  final double quantity;
  final double price;
  final double fee;
  final String side;            // 'buy'|'sell'|'deposit'|'withdraw'
  final String? date;           // 'YYYY-MM-DD' or null
  const TxInput({required this.quantity, required this.price,
                 this.fee = 0, required this.side, this.date});
}

class PositionSummary {
  final double quantity;
  final double avgCost;
  final double totalCost;
  final double realizedPnl;
  final String direction;       // 'long'|'short'
  const PositionSummary({...});
}

class PositionCalculator {
  static PositionSummary calculate(List<TxInput> txs, {String direction = 'long'});
}
```

### 4.2 `net_worth_calculator.dart`

```dart
class AssetInput {
  final String type;            // 'crypto'|'th'|'us'|'fund'|'deposit'
  final String currency;        // 'THB'|'USD'
  final String direction;       // 'long'|'short'
  final double? manualPrice;
  final List<TxInput> txs;
  final double price;           // resolved live/last price in the asset's NATIVE currency
  final double chg24h;          // 24h % change
}

class NetWorthSummary {
  final double totalAssetsThb, totalLiabilitiesThb, netWorthThb,
               todayPlThb, totalCostThb, fx;
}

class LiabilityInput { final double amount; final String currency; } // 'THB'|'USD'

class NetWorthCalculator {
  static NetWorthSummary summary({
    required List<AssetInput> assets,
    required List<LiabilityInput> liabilities,
    required double fx,
  });
}
```

### 4.3 `currency_converter.dart` / `formatters.dart`

```dart
class CurrencyConverter {
  // native→THB base:  multiplier = currency=='USD' ? fx : 1
  static double toThb(double amount, String currency, double fx);
  static double convert(double amount, String from, String to, double fx); // via THB
}

class Formatters {
  static String money(double v, {String currency = 'USD'});   // USD → 2dp, THB → 2dp, grouped
  static String compact(double v);                            // 1.2K / 3.4M
  static String pct(double v);                                // +1.23% / -0.50%
}
```

---

## 5. Price clients (`lib/src/prices/`)

```dart
class ApiError implements Exception { final String message; ApiError(this.message); }

class CryptoPrice { final double usd, usdChg, thb, thbChg; }

class BinanceClient {
  BinanceClient(this.dio, {required this.getFx});   // getFx: Future<double> Function()
  Future<Map<String,CryptoPrice>> getPrices(List<String> ids);   // ids e.g. ['BTC','ETH']
}

class StockQuote { final double price, chg; }       // chg = percent

class YahooClient {
  YahooClient(this.dio);
  Future<StockQuote> getStockPrice(String symbol);  // TH stocks pass 'PTT.BK' etc.
  Future<double> getFxRate();                        // from 'THB=X', fallback 35.84
}

class PricePoint { final int t; final double p; }   // t = epoch ms, p = price

class PriceHistoryClient {
  PriceHistoryClient(this.dio, {required this.getFx});
  Future<List<PricePoint>> cryptoHistory(String coinId, int days);   // THB, Binance klines
  Future<List<PricePoint>> stockHistory(String symbol, String range);// range '7D'|'1M'|'3M'|'1Y'
}
```

Symbol regex (validate before hitting upstream): `^[A-Za-z0-9.\-^=]{1,15}$`. Reject → throw `ApiError`.

---

## 6. Theme tokens (`lib/src/ui/theme/`) — see `tasks/design-tokens.md` for values

`colors.dart` (`AppColors`), `typography.dart` (`AppType`), `spacing.dart` (`AppSpacing`,
`AppRadii`). Exact values in `tasks/design-tokens.md`.

---

# CONTRACTS — Phase 2 (repos + Riverpod notifiers) — frozen

Added for Phase 2 (T2.01–T2.09). Same rule: dispatched tasks implement these **exactly**.

## 7. Riverpod & data conventions

- **In-app domain type = the Drift row class** (`Portfolio`, `Asset`, `Transaction`, `Liability`,
  `LiabilityTransaction`, `NetWorthHistoryData`, `PriceCacheData`). Repos take/return these.
  Enum columns are plain `String` on the row (the `wire` value, e.g. `'crypto'`, `'USD'`).
  The **freezed models** (§3) are used **only** by `BackupRepo` for JSON export/import.
- **IDs / times** (repos only — keep calculators pure): `id = const Uuid().v4()`;
  `createdAt = DateTime.now().toUtc().toIso8601String()`; `date` (when defaulted) =
  `DateTime.now().toIso8601String().substring(0,10)`.
- **Notifiers**: `@riverpod` codegen, async. `part 'x_notifier.g.dart';` · class
  `XNotifier extends _$XNotifier` with `FutureOr<XState> build()`. **The generator strips the
  `Notifier` suffix**: `LiabilitiesNotifier` → provider `liabilitiesProvider`,
  `PortfoliosNotifier` → `portfoliosProvider`, `TransactionsNotifier` → `transactionsProvider`,
  `OverviewNotifier` → `overviewProvider`, `SettingsNotifier` → `settingsProvider`. State is an
  **`abstract` freezed class** (freezed 3.x requires `abstract class X with _$X`) in the same file.
- **Mutation pattern** (no stream watching in Phase 2): every mutating method does
  `await _repo.doThing(...); ref.invalidateSelf(); await future;` — deterministic and easy to test.
- **Infra providers** are plain (not codegen). Tests override `appDatabaseProvider` with an
  in-memory `AppDatabase(NativeDatabase.memory())` and read state via
  `container.read(xNotifierProvider.future)`.
- Run `dart run build_runner build` after editing any freezed/`@riverpod` file; commit generated
  `.g.dart` / `.freezed.dart`.

### 7.1 Infra providers — `lib/src/state/providers.dart` (owned by T2.01)

```dart
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('override in main() / tests'));
final portfolioAssetDaoProvider = Provider((ref) => PortfolioAssetDao(ref.watch(appDatabaseProvider)));
final transactionDaoProvider    = Provider((ref) => TransactionDao(ref.watch(appDatabaseProvider)));
final liabilityDaoProvider      = Provider((ref) => LiabilityDao(ref.watch(appDatabaseProvider)));
final miscDaoProvider           = Provider((ref) => MiscDao(ref.watch(appDatabaseProvider)));
```
Each repo file declares its **own** repo provider at the bottom, reading the DAO provider (so tasks
never edit a file another task owns):
`final portfolioRepoProvider = Provider((ref) => PortfolioRepo(ref.watch(portfolioAssetDaoProvider)));`
— likewise `assetRepoProvider`, `transactionRepoProvider`, `liabilityRepoProvider`,
`settingsRepoProvider`, `backupRepoProvider`, `priceRepositoryProvider`.

## 8. Validation (enforced in repos — throw `ArgumentError` on violation)

name (trimmed) non-empty · portfolio `color` in 0..5 · asset `symbol` (trimmed) non-empty ·
`currency` ∈ {`THB`,`USD`} · `type` ∈ {crypto,th,us,fund,deposit} · `direction` ∈ {long,short} ·
tx `quantity` > 0 · `price` ≥ 0 · `fee` ≥ 0 · liability/adjust `amount` > 0 · `manualPrice`
(if given) ≥ 0. **Asset `currency` is locked after create** (`AssetRepo.save` reads the stored
row and throws if currency differs).

## 9. Repo signatures (Drift rows in/out)

DAOs are upsert-only (`insertOnConflictUpdate`) with no single-row get; repos therefore build full
rows for `save` and locate existing rows via the DAO's list methods. **T2.01 adds one method**
`Future<List<Asset>> allAssets()` to `PortfolioAssetDao` (`db.select(db.assets).get()`) — the only
permitted Phase-1-file edit; everything else stays in Phase-2 files.

```dart
// T2.01
class PortfolioRepo {                       // ctor(PortfolioAssetDao dao)
  Future<Portfolio> create({required String name, required int color});   // sortOrder = current count
  Future<void> save(Portfolio p);           // validates; upsert full row
  Future<void> remove(String id);
  Future<void> reorder(List<String> idsInOrder);
  Future<List<Portfolio>> all();
}
class AssetRepo {                           // ctor(PortfolioAssetDao dao)
  Future<Asset> create({required String portfolioId, required String type, required String symbol,
    required String name, required String currency, String? cgId, String? yahooSymbol,
    double? manualPrice, String direction = 'long'});                     // sortOrder = count in portfolio
  Future<void> save(Asset a);               // validates; currency-lock check; upsert full row
  Future<void> remove(String id);
  Future<List<Asset>> allFor(String portfolioId);
  Future<List<Asset>> all();
}
// T2.03
class TransactionRepo {                     // ctor(TransactionDao dao)
  Future<Transaction> add({required String assetId, required String side, required double quantity,
    required double price, double fee = 0, required String date});        // id+createdAt generated
  Future<void> save(Transaction t);
  Future<void> remove(String id);
  Future<List<Transaction>> byAsset(String assetId);
  Future<List<Transaction>> all();
}
// T2.05  (adjust ports liabilities.service.ts#adjust: next = pay? amt-a : amt+a, clamp max(0,·),
//         write liability_transaction + updated liability in ONE db.transaction)
class LiabilityRepo {                        // ctor(LiabilityDao dao)
  Future<Liability> create({required String name, required double amount, required String currency});
  Future<void> save(Liability l);
  Future<void> remove(String id);
  Future<void> adjust({required String liabilityId, required String type, required double amount,
    required String date});                  // type 'pay'|'add'
  Future<List<Liability>> all();
  Future<List<LiabilityTransaction>> txsFor(String liabilityId);
}
```

## 10. Notifier states & methods (freezed state + `@riverpod` async notifier)

Each notifier file has BOTH `part 'x_notifier.freezed.dart';` and `part 'x_notifier.g.dart';`.
`build()` loads once; every mutation ends with `ref.invalidateSelf(); await future;`. State classes
hold Drift rows + domain results (no JSON needed — in-memory only).

### 10.1 `state/portfolios_notifier.dart` (T2.02) — deps: portfolioRepo, assetRepo, transactionRepo, PositionCalculator
```dart
@freezed class AssetNode      { Asset asset; PositionSummary position; }
@freezed class PortfolioNode  { Portfolio portfolio; List<AssetNode> assets; }
@freezed class PortfoliosState{ List<PortfolioNode> nodes; }
@riverpod class PortfoliosNotifier extends _$PortfoliosNotifier {
  FutureOr<PortfoliosState> build();     // for each portfolio → assets → PositionCalculator over its txs
  Future<void> addPortfolio({required String name, required int color});
  Future<void> renamePortfolio(String id, String name);   // load row, copyWith, repo.save
  Future<void> recolorPortfolio(String id, int color);
  Future<void> deletePortfolio(String id);
  Future<void> reorderPortfolios(List<String> ids);
  Future<void> addAsset({required String portfolioId, required String type, required String symbol,
    required String name, required String currency, String? cgId, String? yahooSymbol,
    double? manualPrice, String direction = 'long'});
  Future<void> saveAsset(Asset asset);
  Future<void> deleteAsset(String id);
}
```
`build()` maps each tx to `TxInput(quantity, price, fee, side, date)` and calls
`PositionCalculator.calculate(inputs, direction: asset.direction)`.

### 10.2 `state/transactions_notifier.dart` (T2.04) — deps: transactionRepo, assetRepo
```dart
@freezed class TxRow           { Transaction tx; Asset asset; }
@freezed class TxGroup         { String date; List<TxRow> rows; }
@freezed class TransactionsState { List<TxGroup> groups; }
@riverpod class TransactionsNotifier extends _$TransactionsNotifier {
  FutureOr<TransactionsState> build();   // all txs, join asset by id, group by date
  Future<void> addTransaction({required String assetId, required String side,
    required double quantity, required double price, double fee = 0, required String date});
  Future<void> saveTransaction(Transaction t);
  Future<void> deleteTransaction(String id);
}
```
`build()`: assets = `assetRepo.all()` → `{id: asset}`; txs = `transactionRepo.all()`; sort txs by
`date` DESC then `createdAt` DESC; group consecutive equal `date` into `TxGroup`; each `TxRow.asset`
is the joined asset (skip a tx whose asset is missing — shouldn't happen under FK).

### 10.3 `state/liabilities_notifier.dart` (T2.06) — deps: liabilityRepo
```dart
@freezed class LiabilitiesState { List<Liability> liabilities; }
@riverpod class LiabilitiesNotifier extends _$LiabilitiesNotifier {
  FutureOr<LiabilitiesState> build();    // liabilityRepo.all()
  Future<void> addLiability({required String name, required double amount, required String currency});
  Future<void> saveLiability(Liability l);
  Future<void> deleteLiability(String id);
  Future<void> adjust({required String liabilityId, required String type, required double amount,
    required String date});
}
```

## 11. PriceRepository (`lib/src/prices/price_repository.dart`, T2.07)

Resolves an asset's current price in its **native** currency + 24h change, with a TTL'd DB cache
(`price_cache`) and a fallback chain. Clients do NOT cache internally, so the TTL lives here.

```dart
class ResolvedPrice {
  final double price;      // native currency
  final double chg24h;     // percent
  final String source;     // 'fixed' | 'manual' | 'cache' | 'live' | 'none'
  const ResolvedPrice(this.price, this.chg24h, this.source);
}

class PriceRepository {
  PriceRepository(this.dao, this.binance, this.yahoo, {DateTime Function()? now});
  // deps: MiscDao dao, BinanceClient binance, YahooClient yahoo; clock defaults to DateTime.now
  Future<ResolvedPrice> resolve(Asset asset);
}
final priceRepositoryProvider = Provider((ref) => PriceRepository(
  ref.watch(miscDaoProvider),
  BinanceClient(Dio(), getFx: () async => YahooClient(Dio()).getFxRate()),
  YahooClient(Dio())));
```

**resolve(asset) algorithm** (cache key: `crypto:<symbol>` ttl 60s · `stock:<symbol>` ttl 90s):
1. `deposit` → `ResolvedPrice(1, 0, 'fixed')`.
2. `fund`    → `ResolvedPrice(asset.manualPrice ?? 0, 0, 'manual')`.
3. crypto/th/us:
   a. `cached = await dao.getPrice(key)`. If cached != null and
      `now().difference(DateTime.parse(cached.fetchedAt)) < ttl` → `ResolvedPrice(cached.price, cached.chg24h, 'cache')`.
   b. else try live:
      - crypto: `cp = (await binance.getPrices([asset.symbol]))[asset.symbol]`; if null → throw;
        `native = asset.currency=='USD' ? cp.usd : cp.thb`; `chg = asset.currency=='USD' ? cp.usdChg : cp.thbChg`.
      - stock: `ysym = asset.yahooSymbol ?? (asset.type=='th' ? '${asset.symbol}.BK' : asset.symbol)`;
        `q = await yahoo.getStockPrice(ysym)`; `native = q.price`; `chg = q.chg`.
      - on success: `await dao.putPrice(PriceCacheCompanion.insert(key: key, price: native,
        chg24h: Value(chg), currency: asset.currency, fetchedAt: now().toUtc().toIso8601String()))`;
        return `ResolvedPrice(native, chg, 'live')`.
   c. on ANY exception in (b): if `cached != null` → `ResolvedPrice(cached.price, cached.chg24h, 'cache')`;
      else if `asset.manualPrice != null` → `ResolvedPrice(asset.manualPrice!, 0, 'manual')`;
      else `ResolvedPrice(0, 0, 'none')`.

`PriceCacheData` fields: `key, price, chg24h, currency, fetchedAt`. `PriceCacheCompanion.insert`
requires `key, price, currency, fetchedAt`; `chg24h` is `Value<double>` (default 0).

### 10.4 Notifier test harness (all notifier tasks)
```dart
final db = AppDatabase(NativeDatabase.memory());
final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
addTearDown(container.dispose); addTearDown(db.close);
final n = container.read(xProvider.notifier);   // xProvider = suffix-stripped name (see §7)
await n.addPortfolio(name: 'Main', color: 0);
final state = await container.read(xProvider.future);   // re-read after mutation
// Use `late` + per-test setUp/tearDown for a FRESH db+container each test (state must not leak).
```
