package app.porto.shared.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class AssetType {
    @SerialName("crypto") CRYPTO,
    @SerialName("th") TH,
    @SerialName("us") US,
    @SerialName("fund") FUND,
    @SerialName("deposit") DEPOSIT,
}

@Serializable
enum class Currency {
    @SerialName("THB") THB,
    @SerialName("USD") USD,
}

@Serializable
enum class TxSide {
    @SerialName("buy") BUY,
    @SerialName("sell") SELL,
    @SerialName("deposit") DEPOSIT,
    @SerialName("withdraw") WITHDRAW,
}

@Serializable
enum class Direction {
    @SerialName("long") LONG,
    @SerialName("short") SHORT,
}

@Serializable
enum class LiabilityTxType {
    @SerialName("pay") PAY,
    @SerialName("add") ADD,
}

@Serializable
data class Portfolio(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val color: Int = 0, // 0-5
    val sortOrder: Int = 0,
)

@Serializable
data class Asset(
    val id: String = java.util.UUID.randomUUID().toString(),
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

@Serializable
data class Transaction(
    val id: String = java.util.UUID.randomUUID().toString(),
    val assetId: String,
    val side: TxSide,
    val quantity: Double,
    val price: Double,
    val fee: Double = 0.0,
    val date: String, // YYYY-MM-DD
    val createdAt: String, // ISO-8601 timestamp
)

@Serializable
data class Liability(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val amount: Double,
    val currency: Currency = Currency.THB,
)

@Serializable
data class LiabilityTransaction(
    val id: String = java.util.UUID.randomUUID().toString(),
    val liabilityId: String,
    val type: LiabilityTxType,
    val amount: Double,
    val date: String, // YYYY-MM-DD
    val createdAt: String, // ISO-8601 timestamp
)

@Serializable
data class NetWorthHistory(
    val date: String, // YYYY-MM-DD (primary key)
    val totalAssetsThb: Double,
    val totalLiabilitiesThb: Double,
    val netWorthThb: Double,
    val fxRate: Double? = null,
)

@Serializable
data class PriceCache(
    val key: String, // e.g. "crypto:BTC", "stock:AAPL", "fx"
    val price: Double,
    val chg24h: Double,
    val currency: String,
    val fetchedAt: String, // ISO-8601 timestamp
)

@Serializable
data class Settings(
    val key: String,
    val value: String, // e.g. "THB", "USD"
)
