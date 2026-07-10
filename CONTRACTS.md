# Porto Mobile — Frozen Contracts

This file is the contract specification for the Porto Mobile KMP app.
All Phase 1+ tasks implement against these contracts verbatim.
Contract changes must go through the orchestrator only.

---

## §1. Enums

```kotlin
enum class AssetType { CRYPTO, TH, US, FUND, DEPOSIT }
enum class Currency { THB, USD }
enum class TxSide { BUY, SELL, DEPOSIT, WITHDRAW }
enum class Direction { LONG, SHORT }
enum class LiabilityTxType { PAY, ADD }
```

## §2. Domain Models

All models are `@Serializable` data classes / enums for JSON export/import.

```kotlin
data class Portfolio(
    val id: String,       // UUID
    val name: String,
    val color: Int,       // 0-5
    val sortOrder: Int,
)

data class Asset(
    val id: String,       // UUID
    val portfolioId: String,
    val type: AssetType,
    val symbol: String,
    val name: String,
    val currency: Currency = Currency.USD,
    val cgId: String? = null,
    val yahooSymbol: String? = null,
    val manualPrice: Double? = null,
    val direction: Direction = Direction.LONG,
    val sortOrder: Int = 0,
)

data class Transaction(
    val id: String,       // UUID
    val assetId: String,
    val side: TxSide,
    val quantity: Double,
    val price: Double,
    val fee: Double = 0.0,
    val date: String,     // YYYY-MM-DD
    val createdAt: String, // ISO-8601
)

data class Liability(
    val id: String,       // UUID
    val name: String,
    val amount: Double,
    val currency: Currency = Currency.THB,
)

data class LiabilityTransaction(
    val id: String,       // UUID
    val liabilityId: String,
    val type: LiabilityTxType,
    val amount: Double,
    val date: String,     // YYYY-MM-DD
    val createdAt: String, // ISO-8601
)

data class NetWorthHistory(
    val date: String,     // YYYY-MM-DD (PK)
    val totalAssetsThb: Double,
    val totalLiabilitiesThb: Double,
    val netWorthThb: Double,
    val fxRate: Double? = null,
)

data class PriceCache(
    val key: String,      // "crypto:BTC", "stock:AAPL", "fx"
    val price: Double,
    val chg24h: Double,
    val currency: String,
    val fetchedAt: String, // ISO-8601
)

data class Settings(
    val key: String,
    val value: String,    // "THB", "USD", "th", "en"
)
```

## §3. DB Schema (SQLDelight — Porto.sq)

See `shared/src/commonMain/sqldelight/app/porto/db/Porto.sq` for the full DDL.
Key points:

- All ids: `TEXT` UUID, generated on-device.
- Numeric columns: `REAL` (port of backend `NUMERIC(20,8)` → JS `Double`).
- Dates: `TEXT` `YYYY-MM-DD`.
- FK cascade: `assets → transactions`, `liabilities → liability_transactions`, `portfolios → assets`.
- `INSERT OR REPLACE` for upsert tables (`net_worth_history`, `price_cache`, `settings`).

## §4. Logic Port Interfaces

### PositionCalculator

```kotlin
data class PositionSummary(
    val quantity: Double,
    val avgCost: Double,
    val totalCost: Double,
    val realizedPnl: Double,
    val direction: Direction,
)

interface PositionCalculator {
    fun calculate(
        transactions: List<SimpleTransaction>,
        direction: Direction = Direction.LONG,
    ): PositionSummary
}

data class SimpleTransaction(
    val quantity: Double,
    val price: Double,
    val fee: Double,
    val side: TxSide,
    val date: String? = null, // YYYY-MM-DD
)
```

Port rules from `position.service.ts`:
- Sort by date (oldest→newest) if dates available.
- Long: deposit/buy adds qty, sell/withdraw removes.
- Short: sell opens, buy covers.
- Realized P&L on close: `q * (price - avgCost) - fee` (long) or `q * (avgCost - price) - fee` (short).
- Reset to zero when `quantity < 1e-9`.

### NetWorthCalculator

```kotlin
data class NetWorthSummary(
    val totalAssetsThb: Double,
    val totalLiabilitiesThb: Double,
    val netWorthThb: Double,
    val todayPlThb: Double,
    val totalCostThb: Double,
    val fx: Double,
)

interface NetWorthCalculator {
    fun calculateSummary(
        assets: List<AssetWithPosition>,
        liabilities: List<Liability>,
        fx: Double,
    ): NetWorthSummary
}

data class AssetWithPosition(
    val asset: Asset,
    val position: PositionSummary,
    val price: Double,
    val chg24h: Double,
)
```

Port rules from `net-worth.service.ts#getSummary`:
- Deposit: price = 1.
- Fund: price = manualPrice.
- Crypto/Stock: use live price from PriceRepository (fallback chain).
- Multiplier: `asset.currency == USD ? fx : 1`.
- Short: subtract from totalAssetsThb.
- 24h P&L: `rawPl = assetValThb - assetValThb / (1 + chg24h/100)`, reversed for short.
- Snapshot upsert by date into `net_worth_history`.

### PriceRepository

```kotlin
interface PriceRepository {
    suspend fun getCryptoPrices(symbols: List<String>, currencies: List<String>): Map<String, CryptoPriceData>
    suspend fun getStockPrice(yahooSymbol: String): StockPriceData?
    suspend fun getFxRate(): Double  // THB→USD
}

data class CryptoPriceData(
    val thb: Double,
    val usd: Double,
    val thb24hChange: Double,
    val usd24hChange: Double,
)

data class StockPriceData(
    val price: Double,
    val chg: Double,
)
```

Port rules from `prices.service.ts`:
- Binance: batch ticker first → per-symbol fallback.
- Yahoo: direct → on 401 fetch crumb from `query2.finance.yahoo.com/v1/test/getcrumb` → retry.
- TH stocks: append `.BK` to symbol.
- FX: `THB=X`.
- TTL cache: 60s crypto, 90s stocks, 60s FX.
- Persist to `price_cache` table after fetch.

### LiabilityAdjust

```kotlin
interface LiabilityAdjust {
    suspend fun pay(liabilityId: String, amount: Double, date: String): Result<Unit>
    suspend fun add(liabilityId: String, amount: Double, date: String): Result<Unit>
}
```

Port rules from `liabilities.service.ts#adjust`:
- PAY: decrements amount, writes `liability_transaction` with type `pay`.
- ADD: increments amount, writes `liability_transaction` with type `add`.
- Atomic: single transaction wrapping both updates.

## §5. ViewModel Interfaces (CONTRACTS.md)

Each ViewModel exposes `StateFlow<UiState>` and an `Intent` sealed interface.

### OverviewViewModel

```kotlin
data class OverviewUiState(
    val summary: NetWorthSummary?,
    val history: List<NetWorthHistory>,
    val donutData: List<DonutSlice>,
    val isLoading: Boolean,
    val error: String?,
    val priceStale: Boolean,  // true when showing last-cached price
)

data class DonutSlice(
    val portfolioName: String,
    val assetName: String,
    val valueThb: Double,
    val color: Int,  // 0-5 → color index
)

sealed interface OverviewIntent {
    data class RefreshPrices : OverviewIntent
    data object Load : OverviewIntent
}
```

### PortfoliosViewModel

```kotlin
data class PortfoliosUiState(
    val portfolios: List<PortfolioCard>,
    val isLoading: Boolean,
    val error: String?,
)

data class PortfolioCard(
    val portfolio: Portfolio,
    val assets: List<AssetPosition>,
)

data class AssetPosition(
    val asset: Asset,
    val position: PositionSummary,
    val currentValueThb: Double,
)

sealed interface PortfoliosIntent {
    data object Load : PortfoliosIntent
    data class AddPortfolio(val name: String, val color: Int) : PortfoliosIntent
    data class UpdatePortfolio(val portfolio: Portfolio) : PortfoliosIntent
    data class DeletePortfolio(val id: String) : PortfoliosIntent
    data class ReorderPortfolio(val id: String, val sortOrder: Int) : PortfoliosIntent
    data class AddAsset(val portfolioId: String, val asset: Asset) : PortfoliosIntent
    data class UpdateAsset(val asset: Asset) : PortfoliosIntent
    data class DeleteAsset(val assetId: String) : PortfoliosIntent
}
```

### TransactionsViewModel

```kotlin
data class TransactionsUiState(
    val groupedByDate: Map<String, List<TransactionWithAsset>>,
    val isLoading: Boolean,
    val error: String?,
)

data class TransactionWithAsset(
    val transaction: Transaction,
    val asset: Asset,
)

sealed interface TransactionsIntent {
    data class Load(val portfolioId: String?) : TransactionsIntent
    data class AddTransaction(val tx: Transaction) : TransactionsIntent
    data class UpdateTransaction(val tx: Transaction) : TransactionsIntent
    data class DeleteTransaction(val id: String) : TransactionsIntent
}
```

### LiabilitiesViewModel

```kotlin
data class LiabilitiesUiState(
    val liabilities: List<LiabilityWithTx>,
    val isLoading: Boolean,
    val error: String?,
)

data class LiabilityWithTx(
    val liability: Liability,
    val transactions: List<LiabilityTransaction>,
)

sealed interface LiabilitiesIntent {
    data object Load : LiabilitiesIntent
    data class AddLiability(val name: String, val amount: Double, val currency: Currency) : LiabilitiesIntent
    data class UpdateLiability(val liability: Liability) : LiabilitiesIntent
    data class DeleteLiability(val id: String) : LiabilitiesIntent
    data class PayLiability(val liabilityId: String, val amount: Double, val date: String) : LiabilitiesIntent
    data class AddToLiability(val liabilityId: String, val amount: Double, val date: String) : LiabilitiesIntent
}
```

### SettingsViewModel

```kotlin
data class SettingsUiState(
    val displayCurrency: Currency,
    val language: String,
    val isLoading: Boolean,
    val error: String?,
    val exportInProgress: Boolean,
    val importInProgress: Boolean,
)

sealed interface SettingsIntent {
    data class SetDisplayCurrency(val currency: Currency) : SettingsIntent
    data class SetLanguage(val language: String) : SettingsIntent
    data object Export : SettingsIntent
    data class Import(val json: String) : SettingsIntent
}
```

## §6. Validation Rules

Enforced in repositories (no server):
- `quantity` / `amount` > 0
- `price` / `fee` ≥ 0
- `name` non-empty (trimmed)
- `portfolio.color` 0–5
- `asset.type` matches required fields (e.g. `fund` requires `manualPrice` for price lookup)
- `transaction.date` valid `YYYY-MM-DD`
- `liability.amount` > 0
