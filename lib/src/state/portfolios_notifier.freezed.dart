// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolios_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssetNode {

 Asset get asset; PositionSummary get position;
/// Create a copy of AssetNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetNodeCopyWith<AssetNode> get copyWith => _$AssetNodeCopyWithImpl<AssetNode>(this as AssetNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetNode&&const DeepCollectionEquality().equals(other.asset, asset)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(asset),position);

@override
String toString() {
  return 'AssetNode(asset: $asset, position: $position)';
}


}

/// @nodoc
abstract mixin class $AssetNodeCopyWith<$Res>  {
  factory $AssetNodeCopyWith(AssetNode value, $Res Function(AssetNode) _then) = _$AssetNodeCopyWithImpl;
@useResult
$Res call({
 Asset asset, PositionSummary position
});




}
/// @nodoc
class _$AssetNodeCopyWithImpl<$Res>
    implements $AssetNodeCopyWith<$Res> {
  _$AssetNodeCopyWithImpl(this._self, this._then);

  final AssetNode _self;
  final $Res Function(AssetNode) _then;

/// Create a copy of AssetNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asset = freezed,Object? position = null,}) {
  return _then(_self.copyWith(
asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as Asset,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as PositionSummary,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetNode].
extension AssetNodePatterns on AssetNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetNode value)  $default,){
final _that = this;
switch (_that) {
case _AssetNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetNode value)?  $default,){
final _that = this;
switch (_that) {
case _AssetNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Asset asset,  PositionSummary position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetNode() when $default != null:
return $default(_that.asset,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Asset asset,  PositionSummary position)  $default,) {final _that = this;
switch (_that) {
case _AssetNode():
return $default(_that.asset,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Asset asset,  PositionSummary position)?  $default,) {final _that = this;
switch (_that) {
case _AssetNode() when $default != null:
return $default(_that.asset,_that.position);case _:
  return null;

}
}

}

/// @nodoc


class _AssetNode implements AssetNode {
  const _AssetNode({required this.asset, required this.position});
  

@override final  Asset asset;
@override final  PositionSummary position;

/// Create a copy of AssetNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetNodeCopyWith<_AssetNode> get copyWith => __$AssetNodeCopyWithImpl<_AssetNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetNode&&const DeepCollectionEquality().equals(other.asset, asset)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(asset),position);

@override
String toString() {
  return 'AssetNode(asset: $asset, position: $position)';
}


}

/// @nodoc
abstract mixin class _$AssetNodeCopyWith<$Res> implements $AssetNodeCopyWith<$Res> {
  factory _$AssetNodeCopyWith(_AssetNode value, $Res Function(_AssetNode) _then) = __$AssetNodeCopyWithImpl;
@override @useResult
$Res call({
 Asset asset, PositionSummary position
});




}
/// @nodoc
class __$AssetNodeCopyWithImpl<$Res>
    implements _$AssetNodeCopyWith<$Res> {
  __$AssetNodeCopyWithImpl(this._self, this._then);

  final _AssetNode _self;
  final $Res Function(_AssetNode) _then;

/// Create a copy of AssetNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asset = freezed,Object? position = null,}) {
  return _then(_AssetNode(
asset: freezed == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as Asset,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as PositionSummary,
  ));
}


}

/// @nodoc
mixin _$PortfolioNode {

 Portfolio get portfolio; List<AssetNode> get assets;
/// Create a copy of PortfolioNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioNodeCopyWith<PortfolioNode> get copyWith => _$PortfolioNodeCopyWithImpl<PortfolioNode>(this as PortfolioNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioNode&&const DeepCollectionEquality().equals(other.portfolio, portfolio)&&const DeepCollectionEquality().equals(other.assets, assets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(portfolio),const DeepCollectionEquality().hash(assets));

@override
String toString() {
  return 'PortfolioNode(portfolio: $portfolio, assets: $assets)';
}


}

/// @nodoc
abstract mixin class $PortfolioNodeCopyWith<$Res>  {
  factory $PortfolioNodeCopyWith(PortfolioNode value, $Res Function(PortfolioNode) _then) = _$PortfolioNodeCopyWithImpl;
@useResult
$Res call({
 Portfolio portfolio, List<AssetNode> assets
});




}
/// @nodoc
class _$PortfolioNodeCopyWithImpl<$Res>
    implements $PortfolioNodeCopyWith<$Res> {
  _$PortfolioNodeCopyWithImpl(this._self, this._then);

  final PortfolioNode _self;
  final $Res Function(PortfolioNode) _then;

/// Create a copy of PortfolioNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? portfolio = freezed,Object? assets = null,}) {
  return _then(_self.copyWith(
portfolio: freezed == portfolio ? _self.portfolio : portfolio // ignore: cast_nullable_to_non_nullable
as Portfolio,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<AssetNode>,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfolioNode].
extension PortfolioNodePatterns on PortfolioNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioNode value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioNode value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Portfolio portfolio,  List<AssetNode> assets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioNode() when $default != null:
return $default(_that.portfolio,_that.assets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Portfolio portfolio,  List<AssetNode> assets)  $default,) {final _that = this;
switch (_that) {
case _PortfolioNode():
return $default(_that.portfolio,_that.assets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Portfolio portfolio,  List<AssetNode> assets)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioNode() when $default != null:
return $default(_that.portfolio,_that.assets);case _:
  return null;

}
}

}

/// @nodoc


class _PortfolioNode implements PortfolioNode {
  const _PortfolioNode({required this.portfolio, required final  List<AssetNode> assets}): _assets = assets;
  

@override final  Portfolio portfolio;
 final  List<AssetNode> _assets;
@override List<AssetNode> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}


/// Create a copy of PortfolioNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioNodeCopyWith<_PortfolioNode> get copyWith => __$PortfolioNodeCopyWithImpl<_PortfolioNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioNode&&const DeepCollectionEquality().equals(other.portfolio, portfolio)&&const DeepCollectionEquality().equals(other._assets, _assets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(portfolio),const DeepCollectionEquality().hash(_assets));

@override
String toString() {
  return 'PortfolioNode(portfolio: $portfolio, assets: $assets)';
}


}

/// @nodoc
abstract mixin class _$PortfolioNodeCopyWith<$Res> implements $PortfolioNodeCopyWith<$Res> {
  factory _$PortfolioNodeCopyWith(_PortfolioNode value, $Res Function(_PortfolioNode) _then) = __$PortfolioNodeCopyWithImpl;
@override @useResult
$Res call({
 Portfolio portfolio, List<AssetNode> assets
});




}
/// @nodoc
class __$PortfolioNodeCopyWithImpl<$Res>
    implements _$PortfolioNodeCopyWith<$Res> {
  __$PortfolioNodeCopyWithImpl(this._self, this._then);

  final _PortfolioNode _self;
  final $Res Function(_PortfolioNode) _then;

/// Create a copy of PortfolioNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? portfolio = freezed,Object? assets = null,}) {
  return _then(_PortfolioNode(
portfolio: freezed == portfolio ? _self.portfolio : portfolio // ignore: cast_nullable_to_non_nullable
as Portfolio,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<AssetNode>,
  ));
}


}

/// @nodoc
mixin _$PortfoliosState {

 List<PortfolioNode> get nodes;
/// Create a copy of PortfoliosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfoliosStateCopyWith<PortfoliosState> get copyWith => _$PortfoliosStateCopyWithImpl<PortfoliosState>(this as PortfoliosState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfoliosState&&const DeepCollectionEquality().equals(other.nodes, nodes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(nodes));

@override
String toString() {
  return 'PortfoliosState(nodes: $nodes)';
}


}

/// @nodoc
abstract mixin class $PortfoliosStateCopyWith<$Res>  {
  factory $PortfoliosStateCopyWith(PortfoliosState value, $Res Function(PortfoliosState) _then) = _$PortfoliosStateCopyWithImpl;
@useResult
$Res call({
 List<PortfolioNode> nodes
});




}
/// @nodoc
class _$PortfoliosStateCopyWithImpl<$Res>
    implements $PortfoliosStateCopyWith<$Res> {
  _$PortfoliosStateCopyWithImpl(this._self, this._then);

  final PortfoliosState _self;
  final $Res Function(PortfoliosState) _then;

/// Create a copy of PortfoliosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodes = null,}) {
  return _then(_self.copyWith(
nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<PortfolioNode>,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfoliosState].
extension PortfoliosStatePatterns on PortfoliosState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfoliosState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfoliosState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfoliosState value)  $default,){
final _that = this;
switch (_that) {
case _PortfoliosState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfoliosState value)?  $default,){
final _that = this;
switch (_that) {
case _PortfoliosState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PortfolioNode> nodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfoliosState() when $default != null:
return $default(_that.nodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PortfolioNode> nodes)  $default,) {final _that = this;
switch (_that) {
case _PortfoliosState():
return $default(_that.nodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PortfolioNode> nodes)?  $default,) {final _that = this;
switch (_that) {
case _PortfoliosState() when $default != null:
return $default(_that.nodes);case _:
  return null;

}
}

}

/// @nodoc


class _PortfoliosState implements PortfoliosState {
  const _PortfoliosState({required final  List<PortfolioNode> nodes}): _nodes = nodes;
  

 final  List<PortfolioNode> _nodes;
@override List<PortfolioNode> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}


/// Create a copy of PortfoliosState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfoliosStateCopyWith<_PortfoliosState> get copyWith => __$PortfoliosStateCopyWithImpl<_PortfoliosState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfoliosState&&const DeepCollectionEquality().equals(other._nodes, _nodes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_nodes));

@override
String toString() {
  return 'PortfoliosState(nodes: $nodes)';
}


}

/// @nodoc
abstract mixin class _$PortfoliosStateCopyWith<$Res> implements $PortfoliosStateCopyWith<$Res> {
  factory _$PortfoliosStateCopyWith(_PortfoliosState value, $Res Function(_PortfoliosState) _then) = __$PortfoliosStateCopyWithImpl;
@override @useResult
$Res call({
 List<PortfolioNode> nodes
});




}
/// @nodoc
class __$PortfoliosStateCopyWithImpl<$Res>
    implements _$PortfoliosStateCopyWith<$Res> {
  __$PortfoliosStateCopyWithImpl(this._self, this._then);

  final _PortfoliosState _self;
  final $Res Function(_PortfoliosState) _then;

/// Create a copy of PortfoliosState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodes = null,}) {
  return _then(_PortfoliosState(
nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<PortfolioNode>,
  ));
}


}

// dart format on
