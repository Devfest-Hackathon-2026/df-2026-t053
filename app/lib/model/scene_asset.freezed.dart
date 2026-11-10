// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scene_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SceneAsset {

 String get assetPath; String get title; String get sizeLabel; String get technique;
/// Create a copy of SceneAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneAssetCopyWith<SceneAsset> get copyWith => _$SceneAssetCopyWithImpl<SceneAsset>(this as SceneAsset, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SceneAsset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneAsset&&(identical(other.assetPath, _this.assetPath) || other.assetPath == _this.assetPath)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.sizeLabel, _this.sizeLabel) || other.sizeLabel == _this.sizeLabel)&&(identical(other.technique, _this.technique) || other.technique == _this.technique));
}


@override
int get hashCode {
  final _this = this as SceneAsset;
  return Object.hash(runtimeType,_this.assetPath,_this.title,_this.sizeLabel,_this.technique);
}

@override
String toString() {
  final _this = this as SceneAsset;
  return 'SceneAsset(assetPath: ${_this.assetPath}, title: ${_this.title}, sizeLabel: ${_this.sizeLabel}, technique: ${_this.technique})';
}


}

/// @nodoc
abstract mixin class $SceneAssetCopyWith<$Res>  {
  factory $SceneAssetCopyWith(SceneAsset value, $Res Function(SceneAsset) _then) = _$SceneAssetCopyWithImpl;
@useResult
$Res call({
 String assetPath, String title, String sizeLabel, String technique
});




}
/// @nodoc
class _$SceneAssetCopyWithImpl<$Res>
    implements $SceneAssetCopyWith<$Res> {
  _$SceneAssetCopyWithImpl(this._self, this._then);

  final SceneAsset _self;
  final $Res Function(SceneAsset) _then;

/// Create a copy of SceneAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetPath = null,Object? title = null,Object? sizeLabel = null,Object? technique = null,}) {
  return _then(SceneAsset(
assetPath: null == assetPath ? _self.assetPath : assetPath // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sizeLabel: null == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String,technique: null == technique ? _self.technique : technique // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneAsset].
extension SceneAssetPatterns on SceneAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneAsset value)  $default,){
final _that = this;
switch (_that) {
case _SceneAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneAsset value)?  $default,){
final _that = this;
switch (_that) {
case _SceneAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String assetPath,  String title,  String sizeLabel,  String technique)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneAsset() when $default != null:
return $default(_that.assetPath,_that.title,_that.sizeLabel,_that.technique);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String assetPath,  String title,  String sizeLabel,  String technique)  $default,) {final _that = this;
switch (_that) {
case _SceneAsset():
return $default(_that.assetPath,_that.title,_that.sizeLabel,_that.technique);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String assetPath,  String title,  String sizeLabel,  String technique)?  $default,) {final _that = this;
switch (_that) {
case _SceneAsset() when $default != null:
return $default(_that.assetPath,_that.title,_that.sizeLabel,_that.technique);case _:
  return null;

}
}

}

/// @nodoc


class _SceneAsset implements SceneAsset {
  const _SceneAsset({required this.assetPath, required this.title, required this.sizeLabel, required this.technique});
  

@override final  String assetPath;
@override final  String title;
@override final  String sizeLabel;
@override final  String technique;

/// Create a copy of SceneAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneAssetCopyWith<_SceneAsset> get copyWith => __$SceneAssetCopyWithImpl<_SceneAsset>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneAsset&&(identical(other.assetPath, assetPath) || other.assetPath == assetPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.technique, technique) || other.technique == technique));
}


@override
int get hashCode {
    return Object.hash(runtimeType,assetPath,title,sizeLabel,technique);
}

@override
String toString() {
    return 'SceneAsset(assetPath: $assetPath, title: $title, sizeLabel: $sizeLabel, technique: $technique)';
}


}

/// @nodoc
abstract mixin class _$SceneAssetCopyWith<$Res> implements $SceneAssetCopyWith<$Res> {
  factory _$SceneAssetCopyWith(_SceneAsset value, $Res Function(_SceneAsset) _then) = __$SceneAssetCopyWithImpl;
@override @useResult
$Res call({
 String assetPath, String title, String sizeLabel, String technique
});




}
/// @nodoc
class __$SceneAssetCopyWithImpl<$Res>
    implements _$SceneAssetCopyWith<$Res> {
  __$SceneAssetCopyWithImpl(this._self, this._then);

  final _SceneAsset _self;
  final $Res Function(_SceneAsset) _then;

/// Create a copy of SceneAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetPath = null,Object? title = null,Object? sizeLabel = null,Object? technique = null,}) {
  return _then(_SceneAsset(
assetPath: null == assetPath ? _self.assetPath : assetPath // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sizeLabel: null == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String,technique: null == technique ? _self.technique : technique // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
