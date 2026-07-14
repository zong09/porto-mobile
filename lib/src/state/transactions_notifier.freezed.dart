// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transactions_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TxRow {

 Transaction get tx; Asset get asset;
/// Create a copy of TxRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxRowCopyWith<TxRow> get copyWith => _$TxRowCopyWithImpl<TxRow>(this as TxRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxRow&&const DeepCollectionEquality().equals(other.tx, tx)&&const DeepCollectionEquality().equals(other.asset, asset));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tx),const DeepCollectionEquality().hash(asset));

@override
String toString() {
  return 'TxRow(tx: $tx, asset: $asset)';
}


}

/// @nodoc
abstract mixin class $TxRowCopyWith<$Res>  {
  factory $TxRowCopyWith(TxRow value, $Res Function(TxRow) _then) = _$TxRowCopyWithImpl;
@useResult
$Res call({
 Transaction tx, Asset asset
});




}
/// @nodoc
class _$TxRowCopyWithImpl<$Res>
    implements $TxRowCopyWith<$Res> {
  _$TxRowCopyWithImpl(this._self, this._then);

  final TxRow _self;
  final $Res Function(TxRow) _then;

/// Create a copy of TxRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tx = freezed,Object? asset = freezed,}) {
  return _then(_self.copyWith(
tx: freezed == tx ? _self.tx : tx // ignore: cast_nullable_to_non_nullable
as Transaction,asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as Asset,
  ));
}

}


/// Adds pattern-matching-related methods to [TxRow].
extension TxRowPatterns on TxRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TxRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TxRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TxRow value)  $default,){
final _that = this;
switch (_that) {
case _TxRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TxRow value)?  $default,){
final _that = this;
switch (_that) {
case _TxRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Transaction tx,  Asset asset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TxRow() when $default != null:
return $default(_that.tx,_that.asset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Transaction tx,  Asset asset)  $default,) {final _that = this;
switch (_that) {
case _TxRow():
return $default(_that.tx,_that.asset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Transaction tx,  Asset asset)?  $default,) {final _that = this;
switch (_that) {
case _TxRow() when $default != null:
return $default(_that.tx,_that.asset);case _:
  return null;

}
}

}

/// @nodoc


class _TxRow implements TxRow {
  const _TxRow({required this.tx, required this.asset});
  

@override final  Transaction tx;
@override final  Asset asset;

/// Create a copy of TxRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TxRowCopyWith<_TxRow> get copyWith => __$TxRowCopyWithImpl<_TxRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TxRow&&const DeepCollectionEquality().equals(other.tx, tx)&&const DeepCollectionEquality().equals(other.asset, asset));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tx),const DeepCollectionEquality().hash(asset));

@override
String toString() {
  return 'TxRow(tx: $tx, asset: $asset)';
}


}

/// @nodoc
abstract mixin class _$TxRowCopyWith<$Res> implements $TxRowCopyWith<$Res> {
  factory _$TxRowCopyWith(_TxRow value, $Res Function(_TxRow) _then) = __$TxRowCopyWithImpl;
@override @useResult
$Res call({
 Transaction tx, Asset asset
});




}
/// @nodoc
class __$TxRowCopyWithImpl<$Res>
    implements _$TxRowCopyWith<$Res> {
  __$TxRowCopyWithImpl(this._self, this._then);

  final _TxRow _self;
  final $Res Function(_TxRow) _then;

/// Create a copy of TxRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tx = freezed,Object? asset = freezed,}) {
  return _then(_TxRow(
tx: freezed == tx ? _self.tx : tx // ignore: cast_nullable_to_non_nullable
as Transaction,asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as Asset,
  ));
}


}

/// @nodoc
mixin _$TxGroup {

 String get date; List<TxRow> get rows;
/// Create a copy of TxGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxGroupCopyWith<TxGroup> get copyWith => _$TxGroupCopyWithImpl<TxGroup>(this as TxGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxGroup&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.rows, rows));
}


@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(rows));

@override
String toString() {
  return 'TxGroup(date: $date, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $TxGroupCopyWith<$Res>  {
  factory $TxGroupCopyWith(TxGroup value, $Res Function(TxGroup) _then) = _$TxGroupCopyWithImpl;
@useResult
$Res call({
 String date, List<TxRow> rows
});




}
/// @nodoc
class _$TxGroupCopyWithImpl<$Res>
    implements $TxGroupCopyWith<$Res> {
  _$TxGroupCopyWithImpl(this._self, this._then);

  final TxGroup _self;
  final $Res Function(TxGroup) _then;

/// Create a copy of TxGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? rows = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<TxRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [TxGroup].
extension TxGroupPatterns on TxGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TxGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TxGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TxGroup value)  $default,){
final _that = this;
switch (_that) {
case _TxGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TxGroup value)?  $default,){
final _that = this;
switch (_that) {
case _TxGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  List<TxRow> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TxGroup() when $default != null:
return $default(_that.date,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  List<TxRow> rows)  $default,) {final _that = this;
switch (_that) {
case _TxGroup():
return $default(_that.date,_that.rows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  List<TxRow> rows)?  $default,) {final _that = this;
switch (_that) {
case _TxGroup() when $default != null:
return $default(_that.date,_that.rows);case _:
  return null;

}
}

}

/// @nodoc


class _TxGroup implements TxGroup {
  const _TxGroup({required this.date, required final  List<TxRow> rows}): _rows = rows;
  

@override final  String date;
 final  List<TxRow> _rows;
@override List<TxRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of TxGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TxGroupCopyWith<_TxGroup> get copyWith => __$TxGroupCopyWithImpl<_TxGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TxGroup&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._rows, _rows));
}


@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_rows));

@override
String toString() {
  return 'TxGroup(date: $date, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$TxGroupCopyWith<$Res> implements $TxGroupCopyWith<$Res> {
  factory _$TxGroupCopyWith(_TxGroup value, $Res Function(_TxGroup) _then) = __$TxGroupCopyWithImpl;
@override @useResult
$Res call({
 String date, List<TxRow> rows
});




}
/// @nodoc
class __$TxGroupCopyWithImpl<$Res>
    implements _$TxGroupCopyWith<$Res> {
  __$TxGroupCopyWithImpl(this._self, this._then);

  final _TxGroup _self;
  final $Res Function(_TxGroup) _then;

/// Create a copy of TxGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? rows = null,}) {
  return _then(_TxGroup(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<TxRow>,
  ));
}


}

/// @nodoc
mixin _$TransactionsState {

 List<TxGroup> get groups;
/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionsStateCopyWith<TransactionsState> get copyWith => _$TransactionsStateCopyWithImpl<TransactionsState>(this as TransactionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionsState&&const DeepCollectionEquality().equals(other.groups, groups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'TransactionsState(groups: $groups)';
}


}

/// @nodoc
abstract mixin class $TransactionsStateCopyWith<$Res>  {
  factory $TransactionsStateCopyWith(TransactionsState value, $Res Function(TransactionsState) _then) = _$TransactionsStateCopyWithImpl;
@useResult
$Res call({
 List<TxGroup> groups
});




}
/// @nodoc
class _$TransactionsStateCopyWithImpl<$Res>
    implements $TransactionsStateCopyWith<$Res> {
  _$TransactionsStateCopyWithImpl(this._self, this._then);

  final TransactionsState _self;
  final $Res Function(TransactionsState) _then;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<TxGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionsState].
extension TransactionsStatePatterns on TransactionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionsState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionsState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TxGroup> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
return $default(_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TxGroup> groups)  $default,) {final _that = this;
switch (_that) {
case _TransactionsState():
return $default(_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TxGroup> groups)?  $default,) {final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
return $default(_that.groups);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionsState implements TransactionsState {
  const _TransactionsState({required final  List<TxGroup> groups}): _groups = groups;
  

 final  List<TxGroup> _groups;
@override List<TxGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionsStateCopyWith<_TransactionsState> get copyWith => __$TransactionsStateCopyWithImpl<_TransactionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionsState&&const DeepCollectionEquality().equals(other._groups, _groups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'TransactionsState(groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$TransactionsStateCopyWith<$Res> implements $TransactionsStateCopyWith<$Res> {
  factory _$TransactionsStateCopyWith(_TransactionsState value, $Res Function(_TransactionsState) _then) = __$TransactionsStateCopyWithImpl;
@override @useResult
$Res call({
 List<TxGroup> groups
});




}
/// @nodoc
class __$TransactionsStateCopyWithImpl<$Res>
    implements _$TransactionsStateCopyWith<$Res> {
  __$TransactionsStateCopyWithImpl(this._self, this._then);

  final _TransactionsState _self;
  final $Res Function(_TransactionsState) _then;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,}) {
  return _then(_TransactionsState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<TxGroup>,
  ));
}


}

// dart format on
