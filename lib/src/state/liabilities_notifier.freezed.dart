// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liabilities_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiabilitiesState {

 List<Liability> get liabilities;
/// Create a copy of LiabilitiesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiabilitiesStateCopyWith<LiabilitiesState> get copyWith => _$LiabilitiesStateCopyWithImpl<LiabilitiesState>(this as LiabilitiesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiabilitiesState&&const DeepCollectionEquality().equals(other.liabilities, liabilities));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(liabilities));

@override
String toString() {
  return 'LiabilitiesState(liabilities: $liabilities)';
}


}

/// @nodoc
abstract mixin class $LiabilitiesStateCopyWith<$Res>  {
  factory $LiabilitiesStateCopyWith(LiabilitiesState value, $Res Function(LiabilitiesState) _then) = _$LiabilitiesStateCopyWithImpl;
@useResult
$Res call({
 List<Liability> liabilities
});




}
/// @nodoc
class _$LiabilitiesStateCopyWithImpl<$Res>
    implements $LiabilitiesStateCopyWith<$Res> {
  _$LiabilitiesStateCopyWithImpl(this._self, this._then);

  final LiabilitiesState _self;
  final $Res Function(LiabilitiesState) _then;

/// Create a copy of LiabilitiesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? liabilities = null,}) {
  return _then(_self.copyWith(
liabilities: null == liabilities ? _self.liabilities : liabilities // ignore: cast_nullable_to_non_nullable
as List<Liability>,
  ));
}

}


/// Adds pattern-matching-related methods to [LiabilitiesState].
extension LiabilitiesStatePatterns on LiabilitiesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiabilitiesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiabilitiesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiabilitiesState value)  $default,){
final _that = this;
switch (_that) {
case _LiabilitiesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiabilitiesState value)?  $default,){
final _that = this;
switch (_that) {
case _LiabilitiesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Liability> liabilities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiabilitiesState() when $default != null:
return $default(_that.liabilities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Liability> liabilities)  $default,) {final _that = this;
switch (_that) {
case _LiabilitiesState():
return $default(_that.liabilities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Liability> liabilities)?  $default,) {final _that = this;
switch (_that) {
case _LiabilitiesState() when $default != null:
return $default(_that.liabilities);case _:
  return null;

}
}

}

/// @nodoc


class _LiabilitiesState implements LiabilitiesState {
  const _LiabilitiesState({required final  List<Liability> liabilities}): _liabilities = liabilities;
  

 final  List<Liability> _liabilities;
@override List<Liability> get liabilities {
  if (_liabilities is EqualUnmodifiableListView) return _liabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liabilities);
}


/// Create a copy of LiabilitiesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiabilitiesStateCopyWith<_LiabilitiesState> get copyWith => __$LiabilitiesStateCopyWithImpl<_LiabilitiesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiabilitiesState&&const DeepCollectionEquality().equals(other._liabilities, _liabilities));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_liabilities));

@override
String toString() {
  return 'LiabilitiesState(liabilities: $liabilities)';
}


}

/// @nodoc
abstract mixin class _$LiabilitiesStateCopyWith<$Res> implements $LiabilitiesStateCopyWith<$Res> {
  factory _$LiabilitiesStateCopyWith(_LiabilitiesState value, $Res Function(_LiabilitiesState) _then) = __$LiabilitiesStateCopyWithImpl;
@override @useResult
$Res call({
 List<Liability> liabilities
});




}
/// @nodoc
class __$LiabilitiesStateCopyWithImpl<$Res>
    implements _$LiabilitiesStateCopyWith<$Res> {
  __$LiabilitiesStateCopyWithImpl(this._self, this._then);

  final _LiabilitiesState _self;
  final $Res Function(_LiabilitiesState) _then;

/// Create a copy of LiabilitiesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? liabilities = null,}) {
  return _then(_LiabilitiesState(
liabilities: null == liabilities ? _self._liabilities : liabilities // ignore: cast_nullable_to_non_nullable
as List<Liability>,
  ));
}


}

// dart format on
