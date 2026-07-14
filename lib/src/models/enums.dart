import 'package:freezed_annotation/freezed_annotation.dart';

enum AssetType {
  @JsonValue('crypto')
  crypto,
  @JsonValue('th')
  th,
  @JsonValue('us')
  us,
  @JsonValue('fund')
  fund,
  @JsonValue('deposit')
  deposit;

  String get wire => name; // crypto/th/us/fund/deposit
  static AssetType fromWire(String s) => values.firstWhere((e) => e.name == s);
}

enum Currency {
  @JsonValue('THB')
  thb,
  @JsonValue('USD')
  usd;

  String get wire => this == Currency.thb ? 'THB' : 'USD';
  static Currency fromWire(String s) => s == 'USD' ? Currency.usd : Currency.thb;
}

enum TxSide {
  @JsonValue('buy')
  buy,
  @JsonValue('sell')
  sell,
  @JsonValue('deposit')
  deposit,
  @JsonValue('withdraw')
  withdraw;

  String get wire => name;
  static TxSide fromWire(String s) => values.firstWhere((e) => e.name == s);
}

enum Direction {
  @JsonValue('long')
  long,
  @JsonValue('short')
  short;

  String get wire => name;
  static Direction fromWire(String s) => values.firstWhere((e) => e.name == s);
}

enum LiabilityTxType {
  @JsonValue('pay')
  pay,
  @JsonValue('add')
  add;

  String get wire => name;
  static LiabilityTxType fromWire(String s) =>
      values.firstWhere((e) => e.name == s);
}
