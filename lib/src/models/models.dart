import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class Portfolio with _$Portfolio {
  const factory Portfolio({
    required String id,
    required String name,
    required int color,
    @Default(0) int sortOrder,
  }) = _Portfolio;

  factory Portfolio.fromJson(Map<String, dynamic> json) =>
      _$PortfolioFromJson(json);
}

@freezed
abstract class Asset with _$Asset {
  const factory Asset({
    required String id,
    required String portfolioId,
    required AssetType type,
    required String symbol,
    required String name,
    @Default(Currency.thb) Currency currency,
    String? cgId,
    String? yahooSymbol,
    double? manualPrice,
    @Default(Direction.long) Direction direction,
    @Default(0) int sortOrder,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String assetId,
    required TxSide side,
    required double quantity,
    required double price,
    @Default(0) double fee,
    required String date,
    required String createdAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

@freezed
abstract class Liability with _$Liability {
  const factory Liability({
    required String id,
    required String name,
    required double amount,
    @Default(Currency.thb) Currency currency,
  }) = _Liability;

  factory Liability.fromJson(Map<String, dynamic> json) =>
      _$LiabilityFromJson(json);
}

@freezed
abstract class LiabilityTransaction with _$LiabilityTransaction {
  const factory LiabilityTransaction({
    required String id,
    required String liabilityId,
    required LiabilityTxType type,
    required double amount,
    required String date,
    required String createdAt,
  }) = _LiabilityTransaction;

  factory LiabilityTransaction.fromJson(Map<String, dynamic> json) =>
      _$LiabilityTransactionFromJson(json);
}

@freezed
abstract class NetWorthSnapshot with _$NetWorthSnapshot {
  const factory NetWorthSnapshot({
    required String date,
    required double totalAssetsThb,
    required double totalLiabilitiesThb,
    required double netWorthThb,
    double? fxRate,
  }) = _NetWorthSnapshot;

  factory NetWorthSnapshot.fromJson(Map<String, dynamic> json) =>
      _$NetWorthSnapshotFromJson(json);
}

@freezed
abstract class PriceCacheEntry with _$PriceCacheEntry {
  const factory PriceCacheEntry({
    required String key,
    required double price,
    @Default(0) double chg24h,
    required String currency,
    required String fetchedAt,
  }) = _PriceCacheEntry;

  factory PriceCacheEntry.fromJson(Map<String, dynamic> json) =>
      _$PriceCacheEntryFromJson(json);
}
