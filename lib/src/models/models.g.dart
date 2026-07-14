// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Portfolio _$PortfolioFromJson(Map<String, dynamic> json) => _Portfolio(
  id: json['id'] as String,
  name: json['name'] as String,
  color: (json['color'] as num).toInt(),
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PortfolioToJson(_Portfolio instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'sortOrder': instance.sortOrder,
    };

_Asset _$AssetFromJson(Map<String, dynamic> json) => _Asset(
  id: json['id'] as String,
  portfolioId: json['portfolioId'] as String,
  type: $enumDecode(_$AssetTypeEnumMap, json['type']),
  symbol: json['symbol'] as String,
  name: json['name'] as String,
  currency:
      $enumDecodeNullable(_$CurrencyEnumMap, json['currency']) ?? Currency.thb,
  cgId: json['cgId'] as String?,
  yahooSymbol: json['yahooSymbol'] as String?,
  manualPrice: (json['manualPrice'] as num?)?.toDouble(),
  direction:
      $enumDecodeNullable(_$DirectionEnumMap, json['direction']) ??
      Direction.long,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AssetToJson(_Asset instance) => <String, dynamic>{
  'id': instance.id,
  'portfolioId': instance.portfolioId,
  'type': _$AssetTypeEnumMap[instance.type]!,
  'symbol': instance.symbol,
  'name': instance.name,
  'currency': _$CurrencyEnumMap[instance.currency]!,
  'cgId': instance.cgId,
  'yahooSymbol': instance.yahooSymbol,
  'manualPrice': instance.manualPrice,
  'direction': _$DirectionEnumMap[instance.direction]!,
  'sortOrder': instance.sortOrder,
};

const _$AssetTypeEnumMap = {
  AssetType.crypto: 'crypto',
  AssetType.th: 'th',
  AssetType.us: 'us',
  AssetType.fund: 'fund',
  AssetType.deposit: 'deposit',
};

const _$CurrencyEnumMap = {Currency.thb: 'THB', Currency.usd: 'USD'};

const _$DirectionEnumMap = {Direction.long: 'long', Direction.short: 'short'};

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      side: $enumDecode(_$TxSideEnumMap, json['side']),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      date: json['date'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'side': _$TxSideEnumMap[instance.side]!,
      'quantity': instance.quantity,
      'price': instance.price,
      'fee': instance.fee,
      'date': instance.date,
      'createdAt': instance.createdAt,
    };

const _$TxSideEnumMap = {
  TxSide.buy: 'buy',
  TxSide.sell: 'sell',
  TxSide.deposit: 'deposit',
  TxSide.withdraw: 'withdraw',
};

_Liability _$LiabilityFromJson(Map<String, dynamic> json) => _Liability(
  id: json['id'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency:
      $enumDecodeNullable(_$CurrencyEnumMap, json['currency']) ?? Currency.thb,
);

Map<String, dynamic> _$LiabilityToJson(_Liability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'currency': _$CurrencyEnumMap[instance.currency]!,
    };

_LiabilityTransaction _$LiabilityTransactionFromJson(
  Map<String, dynamic> json,
) => _LiabilityTransaction(
  id: json['id'] as String,
  liabilityId: json['liabilityId'] as String,
  type: $enumDecode(_$LiabilityTxTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  date: json['date'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$LiabilityTransactionToJson(
  _LiabilityTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'liabilityId': instance.liabilityId,
  'type': _$LiabilityTxTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'date': instance.date,
  'createdAt': instance.createdAt,
};

const _$LiabilityTxTypeEnumMap = {
  LiabilityTxType.pay: 'pay',
  LiabilityTxType.add: 'add',
};

_NetWorthSnapshot _$NetWorthSnapshotFromJson(Map<String, dynamic> json) =>
    _NetWorthSnapshot(
      date: json['date'] as String,
      totalAssetsThb: (json['totalAssetsThb'] as num).toDouble(),
      totalLiabilitiesThb: (json['totalLiabilitiesThb'] as num).toDouble(),
      netWorthThb: (json['netWorthThb'] as num).toDouble(),
      fxRate: (json['fxRate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NetWorthSnapshotToJson(_NetWorthSnapshot instance) =>
    <String, dynamic>{
      'date': instance.date,
      'totalAssetsThb': instance.totalAssetsThb,
      'totalLiabilitiesThb': instance.totalLiabilitiesThb,
      'netWorthThb': instance.netWorthThb,
      'fxRate': instance.fxRate,
    };

_PriceCacheEntry _$PriceCacheEntryFromJson(Map<String, dynamic> json) =>
    _PriceCacheEntry(
      key: json['key'] as String,
      price: (json['price'] as num).toDouble(),
      chg24h: (json['chg24h'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String,
      fetchedAt: json['fetchedAt'] as String,
    );

Map<String, dynamic> _$PriceCacheEntryToJson(_PriceCacheEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'price': instance.price,
      'chg24h': instance.chg24h,
      'currency': instance.currency,
      'fetchedAt': instance.fetchedAt,
    };
