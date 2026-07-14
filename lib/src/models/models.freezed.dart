// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Portfolio {

 String get id; String get name; int get color; int get sortOrder;
/// Create a copy of Portfolio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioCopyWith<Portfolio> get copyWith => _$PortfolioCopyWithImpl<Portfolio>(this as Portfolio, _$identity);

  /// Serializes this Portfolio to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Portfolio&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,sortOrder);

@override
String toString() {
  return 'Portfolio(id: $id, name: $name, color: $color, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $PortfolioCopyWith<$Res>  {
  factory $PortfolioCopyWith(Portfolio value, $Res Function(Portfolio) _then) = _$PortfolioCopyWithImpl;
@useResult
$Res call({
 String id, String name, int color, int sortOrder
});




}
/// @nodoc
class _$PortfolioCopyWithImpl<$Res>
    implements $PortfolioCopyWith<$Res> {
  _$PortfolioCopyWithImpl(this._self, this._then);

  final Portfolio _self;
  final $Res Function(Portfolio) _then;

/// Create a copy of Portfolio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Portfolio].
extension PortfolioPatterns on Portfolio {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Portfolio value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Portfolio() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Portfolio value)  $default,){
final _that = this;
switch (_that) {
case _Portfolio():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Portfolio value)?  $default,){
final _that = this;
switch (_that) {
case _Portfolio() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int color,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Portfolio() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.sortOrder);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int color,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Portfolio():
return $default(_that.id,_that.name,_that.color,_that.sortOrder);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int color,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Portfolio() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Portfolio implements Portfolio {
  const _Portfolio({required this.id, required this.name, required this.color, this.sortOrder = 0});
  factory _Portfolio.fromJson(Map<String, dynamic> json) => _$PortfolioFromJson(json);

@override final  String id;
@override final  String name;
@override final  int color;
@override@JsonKey() final  int sortOrder;

/// Create a copy of Portfolio
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioCopyWith<_Portfolio> get copyWith => __$PortfolioCopyWithImpl<_Portfolio>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Portfolio&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,sortOrder);

@override
String toString() {
  return 'Portfolio(id: $id, name: $name, color: $color, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$PortfolioCopyWith<$Res> implements $PortfolioCopyWith<$Res> {
  factory _$PortfolioCopyWith(_Portfolio value, $Res Function(_Portfolio) _then) = __$PortfolioCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int color, int sortOrder
});




}
/// @nodoc
class __$PortfolioCopyWithImpl<$Res>
    implements _$PortfolioCopyWith<$Res> {
  __$PortfolioCopyWithImpl(this._self, this._then);

  final _Portfolio _self;
  final $Res Function(_Portfolio) _then;

/// Create a copy of Portfolio
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? sortOrder = null,}) {
  return _then(_Portfolio(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Asset {

 String get id; String get portfolioId; AssetType get type; String get symbol; String get name; Currency get currency; String? get cgId; String? get yahooSymbol; double? get manualPrice; Direction get direction; int get sortOrder;
/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetCopyWith<Asset> get copyWith => _$AssetCopyWithImpl<Asset>(this as Asset, _$identity);

  /// Serializes this Asset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Asset&&(identical(other.id, id) || other.id == id)&&(identical(other.portfolioId, portfolioId) || other.portfolioId == portfolioId)&&(identical(other.type, type) || other.type == type)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.cgId, cgId) || other.cgId == cgId)&&(identical(other.yahooSymbol, yahooSymbol) || other.yahooSymbol == yahooSymbol)&&(identical(other.manualPrice, manualPrice) || other.manualPrice == manualPrice)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,portfolioId,type,symbol,name,currency,cgId,yahooSymbol,manualPrice,direction,sortOrder);

@override
String toString() {
  return 'Asset(id: $id, portfolioId: $portfolioId, type: $type, symbol: $symbol, name: $name, currency: $currency, cgId: $cgId, yahooSymbol: $yahooSymbol, manualPrice: $manualPrice, direction: $direction, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $AssetCopyWith<$Res>  {
  factory $AssetCopyWith(Asset value, $Res Function(Asset) _then) = _$AssetCopyWithImpl;
@useResult
$Res call({
 String id, String portfolioId, AssetType type, String symbol, String name, Currency currency, String? cgId, String? yahooSymbol, double? manualPrice, Direction direction, int sortOrder
});




}
/// @nodoc
class _$AssetCopyWithImpl<$Res>
    implements $AssetCopyWith<$Res> {
  _$AssetCopyWithImpl(this._self, this._then);

  final Asset _self;
  final $Res Function(Asset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? portfolioId = null,Object? type = null,Object? symbol = null,Object? name = null,Object? currency = null,Object? cgId = freezed,Object? yahooSymbol = freezed,Object? manualPrice = freezed,Object? direction = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,portfolioId: null == portfolioId ? _self.portfolioId : portfolioId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AssetType,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,cgId: freezed == cgId ? _self.cgId : cgId // ignore: cast_nullable_to_non_nullable
as String?,yahooSymbol: freezed == yahooSymbol ? _self.yahooSymbol : yahooSymbol // ignore: cast_nullable_to_non_nullable
as String?,manualPrice: freezed == manualPrice ? _self.manualPrice : manualPrice // ignore: cast_nullable_to_non_nullable
as double?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Asset].
extension AssetPatterns on Asset {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Asset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Asset value)  $default,){
final _that = this;
switch (_that) {
case _Asset():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Asset value)?  $default,){
final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String portfolioId,  AssetType type,  String symbol,  String name,  Currency currency,  String? cgId,  String? yahooSymbol,  double? manualPrice,  Direction direction,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that.id,_that.portfolioId,_that.type,_that.symbol,_that.name,_that.currency,_that.cgId,_that.yahooSymbol,_that.manualPrice,_that.direction,_that.sortOrder);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String portfolioId,  AssetType type,  String symbol,  String name,  Currency currency,  String? cgId,  String? yahooSymbol,  double? manualPrice,  Direction direction,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Asset():
return $default(_that.id,_that.portfolioId,_that.type,_that.symbol,_that.name,_that.currency,_that.cgId,_that.yahooSymbol,_that.manualPrice,_that.direction,_that.sortOrder);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String portfolioId,  AssetType type,  String symbol,  String name,  Currency currency,  String? cgId,  String? yahooSymbol,  double? manualPrice,  Direction direction,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that.id,_that.portfolioId,_that.type,_that.symbol,_that.name,_that.currency,_that.cgId,_that.yahooSymbol,_that.manualPrice,_that.direction,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Asset implements Asset {
  const _Asset({required this.id, required this.portfolioId, required this.type, required this.symbol, required this.name, this.currency = Currency.thb, this.cgId, this.yahooSymbol, this.manualPrice, this.direction = Direction.long, this.sortOrder = 0});
  factory _Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

@override final  String id;
@override final  String portfolioId;
@override final  AssetType type;
@override final  String symbol;
@override final  String name;
@override@JsonKey() final  Currency currency;
@override final  String? cgId;
@override final  String? yahooSymbol;
@override final  double? manualPrice;
@override@JsonKey() final  Direction direction;
@override@JsonKey() final  int sortOrder;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetCopyWith<_Asset> get copyWith => __$AssetCopyWithImpl<_Asset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Asset&&(identical(other.id, id) || other.id == id)&&(identical(other.portfolioId, portfolioId) || other.portfolioId == portfolioId)&&(identical(other.type, type) || other.type == type)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.cgId, cgId) || other.cgId == cgId)&&(identical(other.yahooSymbol, yahooSymbol) || other.yahooSymbol == yahooSymbol)&&(identical(other.manualPrice, manualPrice) || other.manualPrice == manualPrice)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,portfolioId,type,symbol,name,currency,cgId,yahooSymbol,manualPrice,direction,sortOrder);

@override
String toString() {
  return 'Asset(id: $id, portfolioId: $portfolioId, type: $type, symbol: $symbol, name: $name, currency: $currency, cgId: $cgId, yahooSymbol: $yahooSymbol, manualPrice: $manualPrice, direction: $direction, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$AssetCopyWith<$Res> implements $AssetCopyWith<$Res> {
  factory _$AssetCopyWith(_Asset value, $Res Function(_Asset) _then) = __$AssetCopyWithImpl;
@override @useResult
$Res call({
 String id, String portfolioId, AssetType type, String symbol, String name, Currency currency, String? cgId, String? yahooSymbol, double? manualPrice, Direction direction, int sortOrder
});




}
/// @nodoc
class __$AssetCopyWithImpl<$Res>
    implements _$AssetCopyWith<$Res> {
  __$AssetCopyWithImpl(this._self, this._then);

  final _Asset _self;
  final $Res Function(_Asset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? portfolioId = null,Object? type = null,Object? symbol = null,Object? name = null,Object? currency = null,Object? cgId = freezed,Object? yahooSymbol = freezed,Object? manualPrice = freezed,Object? direction = null,Object? sortOrder = null,}) {
  return _then(_Asset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,portfolioId: null == portfolioId ? _self.portfolioId : portfolioId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AssetType,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,cgId: freezed == cgId ? _self.cgId : cgId // ignore: cast_nullable_to_non_nullable
as String?,yahooSymbol: freezed == yahooSymbol ? _self.yahooSymbol : yahooSymbol // ignore: cast_nullable_to_non_nullable
as String?,manualPrice: freezed == manualPrice ? _self.manualPrice : manualPrice // ignore: cast_nullable_to_non_nullable
as double?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TransactionModel {

 String get id; String get assetId; TxSide get side; double get quantity; double get price; double get fee; String get date; String get createdAt;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.side, side) || other.side == side)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId,side,quantity,price,fee,date,createdAt);

@override
String toString() {
  return 'TransactionModel(id: $id, assetId: $assetId, side: $side, quantity: $quantity, price: $price, fee: $fee, date: $date, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String assetId, TxSide side, double quantity, double price, double fee, String date, String createdAt
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetId = null,Object? side = null,Object? quantity = null,Object? price = null,Object? fee = null,Object? date = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as TxSide,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String assetId,  TxSide side,  double quantity,  double price,  double fee,  String date,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.assetId,_that.side,_that.quantity,_that.price,_that.fee,_that.date,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String assetId,  TxSide side,  double quantity,  double price,  double fee,  String date,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.assetId,_that.side,_that.quantity,_that.price,_that.fee,_that.date,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String assetId,  TxSide side,  double quantity,  double price,  double fee,  String date,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.assetId,_that.side,_that.quantity,_that.price,_that.fee,_that.date,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel implements TransactionModel {
  const _TransactionModel({required this.id, required this.assetId, required this.side, required this.quantity, required this.price, this.fee = 0, required this.date, required this.createdAt});
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override final  String assetId;
@override final  TxSide side;
@override final  double quantity;
@override final  double price;
@override@JsonKey() final  double fee;
@override final  String date;
@override final  String createdAt;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.side, side) || other.side == side)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId,side,quantity,price,fee,date,createdAt);

@override
String toString() {
  return 'TransactionModel(id: $id, assetId: $assetId, side: $side, quantity: $quantity, price: $price, fee: $fee, date: $date, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId, TxSide side, double quantity, double price, double fee, String date, String createdAt
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,Object? side = null,Object? quantity = null,Object? price = null,Object? fee = null,Object? date = null,Object? createdAt = null,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as TxSide,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Liability {

 String get id; String get name; double get amount; Currency get currency;
/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiabilityCopyWith<Liability> get copyWith => _$LiabilityCopyWithImpl<Liability>(this as Liability, _$identity);

  /// Serializes this Liability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Liability&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,amount,currency);

@override
String toString() {
  return 'Liability(id: $id, name: $name, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $LiabilityCopyWith<$Res>  {
  factory $LiabilityCopyWith(Liability value, $Res Function(Liability) _then) = _$LiabilityCopyWithImpl;
@useResult
$Res call({
 String id, String name, double amount, Currency currency
});




}
/// @nodoc
class _$LiabilityCopyWithImpl<$Res>
    implements $LiabilityCopyWith<$Res> {
  _$LiabilityCopyWithImpl(this._self, this._then);

  final Liability _self;
  final $Res Function(Liability) _then;

/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,
  ));
}

}


/// Adds pattern-matching-related methods to [Liability].
extension LiabilityPatterns on Liability {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Liability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Liability value)  $default,){
final _that = this;
switch (_that) {
case _Liability():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Liability value)?  $default,){
final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  Currency currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.currency);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  Currency currency)  $default,) {final _that = this;
switch (_that) {
case _Liability():
return $default(_that.id,_that.name,_that.amount,_that.currency);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double amount,  Currency currency)?  $default,) {final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Liability implements Liability {
  const _Liability({required this.id, required this.name, required this.amount, this.currency = Currency.thb});
  factory _Liability.fromJson(Map<String, dynamic> json) => _$LiabilityFromJson(json);

@override final  String id;
@override final  String name;
@override final  double amount;
@override@JsonKey() final  Currency currency;

/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiabilityCopyWith<_Liability> get copyWith => __$LiabilityCopyWithImpl<_Liability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiabilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Liability&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,amount,currency);

@override
String toString() {
  return 'Liability(id: $id, name: $name, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$LiabilityCopyWith<$Res> implements $LiabilityCopyWith<$Res> {
  factory _$LiabilityCopyWith(_Liability value, $Res Function(_Liability) _then) = __$LiabilityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double amount, Currency currency
});




}
/// @nodoc
class __$LiabilityCopyWithImpl<$Res>
    implements _$LiabilityCopyWith<$Res> {
  __$LiabilityCopyWithImpl(this._self, this._then);

  final _Liability _self;
  final $Res Function(_Liability) _then;

/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? currency = null,}) {
  return _then(_Liability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,
  ));
}


}


/// @nodoc
mixin _$LiabilityTransaction {

 String get id; String get liabilityId; LiabilityTxType get type; double get amount; String get date; String get createdAt;
/// Create a copy of LiabilityTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiabilityTransactionCopyWith<LiabilityTransaction> get copyWith => _$LiabilityTransactionCopyWithImpl<LiabilityTransaction>(this as LiabilityTransaction, _$identity);

  /// Serializes this LiabilityTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiabilityTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.liabilityId, liabilityId) || other.liabilityId == liabilityId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,liabilityId,type,amount,date,createdAt);

@override
String toString() {
  return 'LiabilityTransaction(id: $id, liabilityId: $liabilityId, type: $type, amount: $amount, date: $date, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LiabilityTransactionCopyWith<$Res>  {
  factory $LiabilityTransactionCopyWith(LiabilityTransaction value, $Res Function(LiabilityTransaction) _then) = _$LiabilityTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String liabilityId, LiabilityTxType type, double amount, String date, String createdAt
});




}
/// @nodoc
class _$LiabilityTransactionCopyWithImpl<$Res>
    implements $LiabilityTransactionCopyWith<$Res> {
  _$LiabilityTransactionCopyWithImpl(this._self, this._then);

  final LiabilityTransaction _self;
  final $Res Function(LiabilityTransaction) _then;

/// Create a copy of LiabilityTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? liabilityId = null,Object? type = null,Object? amount = null,Object? date = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,liabilityId: null == liabilityId ? _self.liabilityId : liabilityId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LiabilityTxType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LiabilityTransaction].
extension LiabilityTransactionPatterns on LiabilityTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiabilityTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiabilityTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiabilityTransaction value)  $default,){
final _that = this;
switch (_that) {
case _LiabilityTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiabilityTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _LiabilityTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String liabilityId,  LiabilityTxType type,  double amount,  String date,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiabilityTransaction() when $default != null:
return $default(_that.id,_that.liabilityId,_that.type,_that.amount,_that.date,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String liabilityId,  LiabilityTxType type,  double amount,  String date,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _LiabilityTransaction():
return $default(_that.id,_that.liabilityId,_that.type,_that.amount,_that.date,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String liabilityId,  LiabilityTxType type,  double amount,  String date,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LiabilityTransaction() when $default != null:
return $default(_that.id,_that.liabilityId,_that.type,_that.amount,_that.date,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiabilityTransaction implements LiabilityTransaction {
  const _LiabilityTransaction({required this.id, required this.liabilityId, required this.type, required this.amount, required this.date, required this.createdAt});
  factory _LiabilityTransaction.fromJson(Map<String, dynamic> json) => _$LiabilityTransactionFromJson(json);

@override final  String id;
@override final  String liabilityId;
@override final  LiabilityTxType type;
@override final  double amount;
@override final  String date;
@override final  String createdAt;

/// Create a copy of LiabilityTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiabilityTransactionCopyWith<_LiabilityTransaction> get copyWith => __$LiabilityTransactionCopyWithImpl<_LiabilityTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiabilityTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiabilityTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.liabilityId, liabilityId) || other.liabilityId == liabilityId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,liabilityId,type,amount,date,createdAt);

@override
String toString() {
  return 'LiabilityTransaction(id: $id, liabilityId: $liabilityId, type: $type, amount: $amount, date: $date, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LiabilityTransactionCopyWith<$Res> implements $LiabilityTransactionCopyWith<$Res> {
  factory _$LiabilityTransactionCopyWith(_LiabilityTransaction value, $Res Function(_LiabilityTransaction) _then) = __$LiabilityTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String liabilityId, LiabilityTxType type, double amount, String date, String createdAt
});




}
/// @nodoc
class __$LiabilityTransactionCopyWithImpl<$Res>
    implements _$LiabilityTransactionCopyWith<$Res> {
  __$LiabilityTransactionCopyWithImpl(this._self, this._then);

  final _LiabilityTransaction _self;
  final $Res Function(_LiabilityTransaction) _then;

/// Create a copy of LiabilityTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? liabilityId = null,Object? type = null,Object? amount = null,Object? date = null,Object? createdAt = null,}) {
  return _then(_LiabilityTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,liabilityId: null == liabilityId ? _self.liabilityId : liabilityId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LiabilityTxType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NetWorthSnapshot {

 String get date; double get totalAssetsThb; double get totalLiabilitiesThb; double get netWorthThb; double? get fxRate;
/// Create a copy of NetWorthSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetWorthSnapshotCopyWith<NetWorthSnapshot> get copyWith => _$NetWorthSnapshotCopyWithImpl<NetWorthSnapshot>(this as NetWorthSnapshot, _$identity);

  /// Serializes this NetWorthSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetWorthSnapshot&&(identical(other.date, date) || other.date == date)&&(identical(other.totalAssetsThb, totalAssetsThb) || other.totalAssetsThb == totalAssetsThb)&&(identical(other.totalLiabilitiesThb, totalLiabilitiesThb) || other.totalLiabilitiesThb == totalLiabilitiesThb)&&(identical(other.netWorthThb, netWorthThb) || other.netWorthThb == netWorthThb)&&(identical(other.fxRate, fxRate) || other.fxRate == fxRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,totalAssetsThb,totalLiabilitiesThb,netWorthThb,fxRate);

@override
String toString() {
  return 'NetWorthSnapshot(date: $date, totalAssetsThb: $totalAssetsThb, totalLiabilitiesThb: $totalLiabilitiesThb, netWorthThb: $netWorthThb, fxRate: $fxRate)';
}


}

/// @nodoc
abstract mixin class $NetWorthSnapshotCopyWith<$Res>  {
  factory $NetWorthSnapshotCopyWith(NetWorthSnapshot value, $Res Function(NetWorthSnapshot) _then) = _$NetWorthSnapshotCopyWithImpl;
@useResult
$Res call({
 String date, double totalAssetsThb, double totalLiabilitiesThb, double netWorthThb, double? fxRate
});




}
/// @nodoc
class _$NetWorthSnapshotCopyWithImpl<$Res>
    implements $NetWorthSnapshotCopyWith<$Res> {
  _$NetWorthSnapshotCopyWithImpl(this._self, this._then);

  final NetWorthSnapshot _self;
  final $Res Function(NetWorthSnapshot) _then;

/// Create a copy of NetWorthSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? totalAssetsThb = null,Object? totalLiabilitiesThb = null,Object? netWorthThb = null,Object? fxRate = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,totalAssetsThb: null == totalAssetsThb ? _self.totalAssetsThb : totalAssetsThb // ignore: cast_nullable_to_non_nullable
as double,totalLiabilitiesThb: null == totalLiabilitiesThb ? _self.totalLiabilitiesThb : totalLiabilitiesThb // ignore: cast_nullable_to_non_nullable
as double,netWorthThb: null == netWorthThb ? _self.netWorthThb : netWorthThb // ignore: cast_nullable_to_non_nullable
as double,fxRate: freezed == fxRate ? _self.fxRate : fxRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [NetWorthSnapshot].
extension NetWorthSnapshotPatterns on NetWorthSnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetWorthSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetWorthSnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetWorthSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _NetWorthSnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetWorthSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _NetWorthSnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  double totalAssetsThb,  double totalLiabilitiesThb,  double netWorthThb,  double? fxRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetWorthSnapshot() when $default != null:
return $default(_that.date,_that.totalAssetsThb,_that.totalLiabilitiesThb,_that.netWorthThb,_that.fxRate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  double totalAssetsThb,  double totalLiabilitiesThb,  double netWorthThb,  double? fxRate)  $default,) {final _that = this;
switch (_that) {
case _NetWorthSnapshot():
return $default(_that.date,_that.totalAssetsThb,_that.totalLiabilitiesThb,_that.netWorthThb,_that.fxRate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  double totalAssetsThb,  double totalLiabilitiesThb,  double netWorthThb,  double? fxRate)?  $default,) {final _that = this;
switch (_that) {
case _NetWorthSnapshot() when $default != null:
return $default(_that.date,_that.totalAssetsThb,_that.totalLiabilitiesThb,_that.netWorthThb,_that.fxRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetWorthSnapshot implements NetWorthSnapshot {
  const _NetWorthSnapshot({required this.date, required this.totalAssetsThb, required this.totalLiabilitiesThb, required this.netWorthThb, this.fxRate});
  factory _NetWorthSnapshot.fromJson(Map<String, dynamic> json) => _$NetWorthSnapshotFromJson(json);

@override final  String date;
@override final  double totalAssetsThb;
@override final  double totalLiabilitiesThb;
@override final  double netWorthThb;
@override final  double? fxRate;

/// Create a copy of NetWorthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetWorthSnapshotCopyWith<_NetWorthSnapshot> get copyWith => __$NetWorthSnapshotCopyWithImpl<_NetWorthSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetWorthSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetWorthSnapshot&&(identical(other.date, date) || other.date == date)&&(identical(other.totalAssetsThb, totalAssetsThb) || other.totalAssetsThb == totalAssetsThb)&&(identical(other.totalLiabilitiesThb, totalLiabilitiesThb) || other.totalLiabilitiesThb == totalLiabilitiesThb)&&(identical(other.netWorthThb, netWorthThb) || other.netWorthThb == netWorthThb)&&(identical(other.fxRate, fxRate) || other.fxRate == fxRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,totalAssetsThb,totalLiabilitiesThb,netWorthThb,fxRate);

@override
String toString() {
  return 'NetWorthSnapshot(date: $date, totalAssetsThb: $totalAssetsThb, totalLiabilitiesThb: $totalLiabilitiesThb, netWorthThb: $netWorthThb, fxRate: $fxRate)';
}


}

/// @nodoc
abstract mixin class _$NetWorthSnapshotCopyWith<$Res> implements $NetWorthSnapshotCopyWith<$Res> {
  factory _$NetWorthSnapshotCopyWith(_NetWorthSnapshot value, $Res Function(_NetWorthSnapshot) _then) = __$NetWorthSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String date, double totalAssetsThb, double totalLiabilitiesThb, double netWorthThb, double? fxRate
});




}
/// @nodoc
class __$NetWorthSnapshotCopyWithImpl<$Res>
    implements _$NetWorthSnapshotCopyWith<$Res> {
  __$NetWorthSnapshotCopyWithImpl(this._self, this._then);

  final _NetWorthSnapshot _self;
  final $Res Function(_NetWorthSnapshot) _then;

/// Create a copy of NetWorthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? totalAssetsThb = null,Object? totalLiabilitiesThb = null,Object? netWorthThb = null,Object? fxRate = freezed,}) {
  return _then(_NetWorthSnapshot(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,totalAssetsThb: null == totalAssetsThb ? _self.totalAssetsThb : totalAssetsThb // ignore: cast_nullable_to_non_nullable
as double,totalLiabilitiesThb: null == totalLiabilitiesThb ? _self.totalLiabilitiesThb : totalLiabilitiesThb // ignore: cast_nullable_to_non_nullable
as double,netWorthThb: null == netWorthThb ? _self.netWorthThb : netWorthThb // ignore: cast_nullable_to_non_nullable
as double,fxRate: freezed == fxRate ? _self.fxRate : fxRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$PriceCacheEntry {

 String get key; double get price; double get chg24h; String get currency; String get fetchedAt;
/// Create a copy of PriceCacheEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceCacheEntryCopyWith<PriceCacheEntry> get copyWith => _$PriceCacheEntryCopyWithImpl<PriceCacheEntry>(this as PriceCacheEntry, _$identity);

  /// Serializes this PriceCacheEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceCacheEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.price, price) || other.price == price)&&(identical(other.chg24h, chg24h) || other.chg24h == chg24h)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,price,chg24h,currency,fetchedAt);

@override
String toString() {
  return 'PriceCacheEntry(key: $key, price: $price, chg24h: $chg24h, currency: $currency, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $PriceCacheEntryCopyWith<$Res>  {
  factory $PriceCacheEntryCopyWith(PriceCacheEntry value, $Res Function(PriceCacheEntry) _then) = _$PriceCacheEntryCopyWithImpl;
@useResult
$Res call({
 String key, double price, double chg24h, String currency, String fetchedAt
});




}
/// @nodoc
class _$PriceCacheEntryCopyWithImpl<$Res>
    implements $PriceCacheEntryCopyWith<$Res> {
  _$PriceCacheEntryCopyWithImpl(this._self, this._then);

  final PriceCacheEntry _self;
  final $Res Function(PriceCacheEntry) _then;

/// Create a copy of PriceCacheEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? price = null,Object? chg24h = null,Object? currency = null,Object? fetchedAt = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,chg24h: null == chg24h ? _self.chg24h : chg24h // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceCacheEntry].
extension PriceCacheEntryPatterns on PriceCacheEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceCacheEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceCacheEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceCacheEntry value)  $default,){
final _that = this;
switch (_that) {
case _PriceCacheEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceCacheEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PriceCacheEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  double price,  double chg24h,  String currency,  String fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceCacheEntry() when $default != null:
return $default(_that.key,_that.price,_that.chg24h,_that.currency,_that.fetchedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  double price,  double chg24h,  String currency,  String fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _PriceCacheEntry():
return $default(_that.key,_that.price,_that.chg24h,_that.currency,_that.fetchedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  double price,  double chg24h,  String currency,  String fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _PriceCacheEntry() when $default != null:
return $default(_that.key,_that.price,_that.chg24h,_that.currency,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceCacheEntry implements PriceCacheEntry {
  const _PriceCacheEntry({required this.key, required this.price, this.chg24h = 0, required this.currency, required this.fetchedAt});
  factory _PriceCacheEntry.fromJson(Map<String, dynamic> json) => _$PriceCacheEntryFromJson(json);

@override final  String key;
@override final  double price;
@override@JsonKey() final  double chg24h;
@override final  String currency;
@override final  String fetchedAt;

/// Create a copy of PriceCacheEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceCacheEntryCopyWith<_PriceCacheEntry> get copyWith => __$PriceCacheEntryCopyWithImpl<_PriceCacheEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceCacheEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceCacheEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.price, price) || other.price == price)&&(identical(other.chg24h, chg24h) || other.chg24h == chg24h)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,price,chg24h,currency,fetchedAt);

@override
String toString() {
  return 'PriceCacheEntry(key: $key, price: $price, chg24h: $chg24h, currency: $currency, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$PriceCacheEntryCopyWith<$Res> implements $PriceCacheEntryCopyWith<$Res> {
  factory _$PriceCacheEntryCopyWith(_PriceCacheEntry value, $Res Function(_PriceCacheEntry) _then) = __$PriceCacheEntryCopyWithImpl;
@override @useResult
$Res call({
 String key, double price, double chg24h, String currency, String fetchedAt
});




}
/// @nodoc
class __$PriceCacheEntryCopyWithImpl<$Res>
    implements _$PriceCacheEntryCopyWith<$Res> {
  __$PriceCacheEntryCopyWithImpl(this._self, this._then);

  final _PriceCacheEntry _self;
  final $Res Function(_PriceCacheEntry) _then;

/// Create a copy of PriceCacheEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? price = null,Object? chg24h = null,Object? currency = null,Object? fetchedAt = null,}) {
  return _then(_PriceCacheEntry(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,chg24h: null == chg24h ? _self.chg24h : chg24h // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
