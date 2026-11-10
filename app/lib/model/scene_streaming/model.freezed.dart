// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SceneStreamingSettings {

/// この距離以内の区画を、少なくとも簡略モデルで読み込む。
 double get drawDistanceMeters;/// この距離以内の区画を、高精細モデルへ切り替える。
 double get detailDistanceMeters;/// 境界付近の往復で読み込みと解放を繰り返さないための余裕。
/// 読み込んだ区画は、各距離にこの値を足した距離まで維持する。
 double get hysteresisMeters;/// 同時に読み込む区画の上限。近い区画から順に読み込む。
 int get maxConcurrentLoads;/// この距離を超えて移動するまで、必要な区画を計算し直さない。
 double get updateStepMeters;/// 読み込みに失敗した区画を再試行するまでの待ち時間。
 Duration get retryDelay;
/// Create a copy of SceneStreamingSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneStreamingSettingsCopyWith<SceneStreamingSettings> get copyWith => _$SceneStreamingSettingsCopyWithImpl<SceneStreamingSettings>(this as SceneStreamingSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SceneStreamingSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneStreamingSettings&&(identical(other.drawDistanceMeters, _this.drawDistanceMeters) || other.drawDistanceMeters == _this.drawDistanceMeters)&&(identical(other.detailDistanceMeters, _this.detailDistanceMeters) || other.detailDistanceMeters == _this.detailDistanceMeters)&&(identical(other.hysteresisMeters, _this.hysteresisMeters) || other.hysteresisMeters == _this.hysteresisMeters)&&(identical(other.maxConcurrentLoads, _this.maxConcurrentLoads) || other.maxConcurrentLoads == _this.maxConcurrentLoads)&&(identical(other.updateStepMeters, _this.updateStepMeters) || other.updateStepMeters == _this.updateStepMeters)&&(identical(other.retryDelay, _this.retryDelay) || other.retryDelay == _this.retryDelay));
}


@override
int get hashCode {
  final _this = this as SceneStreamingSettings;
  return Object.hash(runtimeType,_this.drawDistanceMeters,_this.detailDistanceMeters,_this.hysteresisMeters,_this.maxConcurrentLoads,_this.updateStepMeters,_this.retryDelay);
}

@override
String toString() {
  final _this = this as SceneStreamingSettings;
  return 'SceneStreamingSettings(drawDistanceMeters: ${_this.drawDistanceMeters}, detailDistanceMeters: ${_this.detailDistanceMeters}, hysteresisMeters: ${_this.hysteresisMeters}, maxConcurrentLoads: ${_this.maxConcurrentLoads}, updateStepMeters: ${_this.updateStepMeters}, retryDelay: ${_this.retryDelay})';
}


}

/// @nodoc
abstract mixin class $SceneStreamingSettingsCopyWith<$Res>  {
  factory $SceneStreamingSettingsCopyWith(SceneStreamingSettings value, $Res Function(SceneStreamingSettings) _then) = _$SceneStreamingSettingsCopyWithImpl;
@useResult
$Res call({
 double drawDistanceMeters, double detailDistanceMeters, double hysteresisMeters, int maxConcurrentLoads, double updateStepMeters, Duration retryDelay
});




}
/// @nodoc
class _$SceneStreamingSettingsCopyWithImpl<$Res>
    implements $SceneStreamingSettingsCopyWith<$Res> {
  _$SceneStreamingSettingsCopyWithImpl(this._self, this._then);

  final SceneStreamingSettings _self;
  final $Res Function(SceneStreamingSettings) _then;

/// Create a copy of SceneStreamingSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? drawDistanceMeters = null,Object? detailDistanceMeters = null,Object? hysteresisMeters = null,Object? maxConcurrentLoads = null,Object? updateStepMeters = null,Object? retryDelay = null,}) {
  return _then(SceneStreamingSettings(
drawDistanceMeters: null == drawDistanceMeters ? _self.drawDistanceMeters : drawDistanceMeters // ignore: cast_nullable_to_non_nullable
as double,detailDistanceMeters: null == detailDistanceMeters ? _self.detailDistanceMeters : detailDistanceMeters // ignore: cast_nullable_to_non_nullable
as double,hysteresisMeters: null == hysteresisMeters ? _self.hysteresisMeters : hysteresisMeters // ignore: cast_nullable_to_non_nullable
as double,maxConcurrentLoads: null == maxConcurrentLoads ? _self.maxConcurrentLoads : maxConcurrentLoads // ignore: cast_nullable_to_non_nullable
as int,updateStepMeters: null == updateStepMeters ? _self.updateStepMeters : updateStepMeters // ignore: cast_nullable_to_non_nullable
as double,retryDelay: null == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneStreamingSettings].
extension SceneStreamingSettingsPatterns on SceneStreamingSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneStreamingSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneStreamingSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneStreamingSettings value)  $default,){
final _that = this;
switch (_that) {
case _SceneStreamingSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneStreamingSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SceneStreamingSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double drawDistanceMeters,  double detailDistanceMeters,  double hysteresisMeters,  int maxConcurrentLoads,  double updateStepMeters,  Duration retryDelay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneStreamingSettings() when $default != null:
return $default(_that.drawDistanceMeters,_that.detailDistanceMeters,_that.hysteresisMeters,_that.maxConcurrentLoads,_that.updateStepMeters,_that.retryDelay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double drawDistanceMeters,  double detailDistanceMeters,  double hysteresisMeters,  int maxConcurrentLoads,  double updateStepMeters,  Duration retryDelay)  $default,) {final _that = this;
switch (_that) {
case _SceneStreamingSettings():
return $default(_that.drawDistanceMeters,_that.detailDistanceMeters,_that.hysteresisMeters,_that.maxConcurrentLoads,_that.updateStepMeters,_that.retryDelay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double drawDistanceMeters,  double detailDistanceMeters,  double hysteresisMeters,  int maxConcurrentLoads,  double updateStepMeters,  Duration retryDelay)?  $default,) {final _that = this;
switch (_that) {
case _SceneStreamingSettings() when $default != null:
return $default(_that.drawDistanceMeters,_that.detailDistanceMeters,_that.hysteresisMeters,_that.maxConcurrentLoads,_that.updateStepMeters,_that.retryDelay);case _:
  return null;

}
}

}

/// @nodoc


class _SceneStreamingSettings implements SceneStreamingSettings {
  const _SceneStreamingSettings({this.drawDistanceMeters = 2200, this.detailDistanceMeters = 200, this.hysteresisMeters = 40, this.maxConcurrentLoads = 2, this.updateStepMeters = 5, this.retryDelay = const Duration(seconds: 3)});
  

/// この距離以内の区画を、少なくとも簡略モデルで読み込む。
@override@JsonKey() final  double drawDistanceMeters;
/// この距離以内の区画を、高精細モデルへ切り替える。
@override@JsonKey() final  double detailDistanceMeters;
/// 境界付近の往復で読み込みと解放を繰り返さないための余裕。
/// 読み込んだ区画は、各距離にこの値を足した距離まで維持する。
@override@JsonKey() final  double hysteresisMeters;
/// 同時に読み込む区画の上限。近い区画から順に読み込む。
@override@JsonKey() final  int maxConcurrentLoads;
/// この距離を超えて移動するまで、必要な区画を計算し直さない。
@override@JsonKey() final  double updateStepMeters;
/// 読み込みに失敗した区画を再試行するまでの待ち時間。
@override@JsonKey() final  Duration retryDelay;

/// Create a copy of SceneStreamingSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneStreamingSettingsCopyWith<_SceneStreamingSettings> get copyWith => __$SceneStreamingSettingsCopyWithImpl<_SceneStreamingSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneStreamingSettings&&(identical(other.drawDistanceMeters, drawDistanceMeters) || other.drawDistanceMeters == drawDistanceMeters)&&(identical(other.detailDistanceMeters, detailDistanceMeters) || other.detailDistanceMeters == detailDistanceMeters)&&(identical(other.hysteresisMeters, hysteresisMeters) || other.hysteresisMeters == hysteresisMeters)&&(identical(other.maxConcurrentLoads, maxConcurrentLoads) || other.maxConcurrentLoads == maxConcurrentLoads)&&(identical(other.updateStepMeters, updateStepMeters) || other.updateStepMeters == updateStepMeters)&&(identical(other.retryDelay, retryDelay) || other.retryDelay == retryDelay));
}


@override
int get hashCode {
    return Object.hash(runtimeType,drawDistanceMeters,detailDistanceMeters,hysteresisMeters,maxConcurrentLoads,updateStepMeters,retryDelay);
}

@override
String toString() {
    return 'SceneStreamingSettings(drawDistanceMeters: $drawDistanceMeters, detailDistanceMeters: $detailDistanceMeters, hysteresisMeters: $hysteresisMeters, maxConcurrentLoads: $maxConcurrentLoads, updateStepMeters: $updateStepMeters, retryDelay: $retryDelay)';
}


}

/// @nodoc
abstract mixin class _$SceneStreamingSettingsCopyWith<$Res> implements $SceneStreamingSettingsCopyWith<$Res> {
  factory _$SceneStreamingSettingsCopyWith(_SceneStreamingSettings value, $Res Function(_SceneStreamingSettings) _then) = __$SceneStreamingSettingsCopyWithImpl;
@override @useResult
$Res call({
 double drawDistanceMeters, double detailDistanceMeters, double hysteresisMeters, int maxConcurrentLoads, double updateStepMeters, Duration retryDelay
});




}
/// @nodoc
class __$SceneStreamingSettingsCopyWithImpl<$Res>
    implements _$SceneStreamingSettingsCopyWith<$Res> {
  __$SceneStreamingSettingsCopyWithImpl(this._self, this._then);

  final _SceneStreamingSettings _self;
  final $Res Function(_SceneStreamingSettings) _then;

/// Create a copy of SceneStreamingSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? drawDistanceMeters = null,Object? detailDistanceMeters = null,Object? hysteresisMeters = null,Object? maxConcurrentLoads = null,Object? updateStepMeters = null,Object? retryDelay = null,}) {
  return _then(_SceneStreamingSettings(
drawDistanceMeters: null == drawDistanceMeters ? _self.drawDistanceMeters : drawDistanceMeters // ignore: cast_nullable_to_non_nullable
as double,detailDistanceMeters: null == detailDistanceMeters ? _self.detailDistanceMeters : detailDistanceMeters // ignore: cast_nullable_to_non_nullable
as double,hysteresisMeters: null == hysteresisMeters ? _self.hysteresisMeters : hysteresisMeters // ignore: cast_nullable_to_non_nullable
as double,maxConcurrentLoads: null == maxConcurrentLoads ? _self.maxConcurrentLoads : maxConcurrentLoads // ignore: cast_nullable_to_non_nullable
as int,updateStepMeters: null == updateStepMeters ? _self.updateStepMeters : updateStepMeters // ignore: cast_nullable_to_non_nullable
as double,retryDelay: null == retryDelay ? _self.retryDelay : retryDelay // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}


/// @nodoc
mixin _$SceneTileManifest {

 int get version; double get tileSizeMeters; List<SceneTile> get tiles;
/// Create a copy of SceneTileManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneTileManifestCopyWith<SceneTileManifest> get copyWith => _$SceneTileManifestCopyWithImpl<SceneTileManifest>(this as SceneTileManifest, _$identity);

  /// Serializes this SceneTileManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneTileManifest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneTileManifest&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.tileSizeMeters, _this.tileSizeMeters) || other.tileSizeMeters == _this.tileSizeMeters)&&const DeepCollectionEquality().equals(other.tiles, _this.tiles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneTileManifest;
  return Object.hash(runtimeType,_this.version,_this.tileSizeMeters,const DeepCollectionEquality().hash(_this.tiles));
}

@override
String toString() {
  final _this = this as SceneTileManifest;
  return 'SceneTileManifest(version: ${_this.version}, tileSizeMeters: ${_this.tileSizeMeters}, tiles: ${_this.tiles})';
}


}

/// @nodoc
abstract mixin class $SceneTileManifestCopyWith<$Res>  {
  factory $SceneTileManifestCopyWith(SceneTileManifest value, $Res Function(SceneTileManifest) _then) = _$SceneTileManifestCopyWithImpl;
@useResult
$Res call({
 int version, double tileSizeMeters, List<SceneTile> tiles
});




}
/// @nodoc
class _$SceneTileManifestCopyWithImpl<$Res>
    implements $SceneTileManifestCopyWith<$Res> {
  _$SceneTileManifestCopyWithImpl(this._self, this._then);

  final SceneTileManifest _self;
  final $Res Function(SceneTileManifest) _then;

/// Create a copy of SceneTileManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? tileSizeMeters = null,Object? tiles = null,}) {
  return _then(SceneTileManifest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,tileSizeMeters: null == tileSizeMeters ? _self.tileSizeMeters : tileSizeMeters // ignore: cast_nullable_to_non_nullable
as double,tiles: null == tiles ? _self.tiles : tiles // ignore: cast_nullable_to_non_nullable
as List<SceneTile>,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneTileManifest].
extension SceneTileManifestPatterns on SceneTileManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneTileManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneTileManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneTileManifest value)  $default,){
final _that = this;
switch (_that) {
case _SceneTileManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneTileManifest value)?  $default,){
final _that = this;
switch (_that) {
case _SceneTileManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  double tileSizeMeters,  List<SceneTile> tiles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneTileManifest() when $default != null:
return $default(_that.version,_that.tileSizeMeters,_that.tiles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  double tileSizeMeters,  List<SceneTile> tiles)  $default,) {final _that = this;
switch (_that) {
case _SceneTileManifest():
return $default(_that.version,_that.tileSizeMeters,_that.tiles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  double tileSizeMeters,  List<SceneTile> tiles)?  $default,) {final _that = this;
switch (_that) {
case _SceneTileManifest() when $default != null:
return $default(_that.version,_that.tileSizeMeters,_that.tiles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneTileManifest implements SceneTileManifest {
  const _SceneTileManifest({required this.version, required this.tileSizeMeters, required  List<SceneTile> tiles}): _tiles = tiles;
  factory _SceneTileManifest.fromJson(Map<String, dynamic> json) => _$SceneTileManifestFromJson(json);

@override final  int version;
@override final  double tileSizeMeters;
 final  List<SceneTile> _tiles;
@override List<SceneTile> get tiles {
  if (_tiles is EqualUnmodifiableListView) return _tiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tiles);
}


/// Create a copy of SceneTileManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneTileManifestCopyWith<_SceneTileManifest> get copyWith => __$SceneTileManifestCopyWithImpl<_SceneTileManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneTileManifestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneTileManifest&&(identical(other.version, version) || other.version == version)&&(identical(other.tileSizeMeters, tileSizeMeters) || other.tileSizeMeters == tileSizeMeters)&&const DeepCollectionEquality().equals(other.tiles, _tiles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,tileSizeMeters,const DeepCollectionEquality().hash(_tiles));
}

@override
String toString() {
    return 'SceneTileManifest(version: $version, tileSizeMeters: $tileSizeMeters, tiles: $tiles)';
}


}

/// @nodoc
abstract mixin class _$SceneTileManifestCopyWith<$Res> implements $SceneTileManifestCopyWith<$Res> {
  factory _$SceneTileManifestCopyWith(_SceneTileManifest value, $Res Function(_SceneTileManifest) _then) = __$SceneTileManifestCopyWithImpl;
@override @useResult
$Res call({
 int version, double tileSizeMeters, List<SceneTile> tiles
});




}
/// @nodoc
class __$SceneTileManifestCopyWithImpl<$Res>
    implements _$SceneTileManifestCopyWith<$Res> {
  __$SceneTileManifestCopyWithImpl(this._self, this._then);

  final _SceneTileManifest _self;
  final $Res Function(_SceneTileManifest) _then;

/// Create a copy of SceneTileManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? tileSizeMeters = null,Object? tiles = null,}) {
  return _then(_SceneTileManifest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,tileSizeMeters: null == tileSizeMeters ? _self.tileSizeMeters : tileSizeMeters // ignore: cast_nullable_to_non_nullable
as double,tiles: null == tiles ? _self._tiles : tiles // ignore: cast_nullable_to_non_nullable
as List<SceneTile>,
  ));
}


}


/// @nodoc
mixin _$SceneTile {

 String get id; double get minX; double get maxX; double get minZ; double get maxZ; String get detailPath; String get coarsePath; int get detailTriangles; int get coarseTriangles;
/// Create a copy of SceneTile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneTileCopyWith<SceneTile> get copyWith => _$SceneTileCopyWithImpl<SceneTile>(this as SceneTile, _$identity);

  /// Serializes this SceneTile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneTile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneTile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.minX, _this.minX) || other.minX == _this.minX)&&(identical(other.maxX, _this.maxX) || other.maxX == _this.maxX)&&(identical(other.minZ, _this.minZ) || other.minZ == _this.minZ)&&(identical(other.maxZ, _this.maxZ) || other.maxZ == _this.maxZ)&&(identical(other.detailPath, _this.detailPath) || other.detailPath == _this.detailPath)&&(identical(other.coarsePath, _this.coarsePath) || other.coarsePath == _this.coarsePath)&&(identical(other.detailTriangles, _this.detailTriangles) || other.detailTriangles == _this.detailTriangles)&&(identical(other.coarseTriangles, _this.coarseTriangles) || other.coarseTriangles == _this.coarseTriangles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneTile;
  return Object.hash(runtimeType,_this.id,_this.minX,_this.maxX,_this.minZ,_this.maxZ,_this.detailPath,_this.coarsePath,_this.detailTriangles,_this.coarseTriangles);
}

@override
String toString() {
  final _this = this as SceneTile;
  return 'SceneTile(id: ${_this.id}, minX: ${_this.minX}, maxX: ${_this.maxX}, minZ: ${_this.minZ}, maxZ: ${_this.maxZ}, detailPath: ${_this.detailPath}, coarsePath: ${_this.coarsePath}, detailTriangles: ${_this.detailTriangles}, coarseTriangles: ${_this.coarseTriangles})';
}


}

/// @nodoc
abstract mixin class $SceneTileCopyWith<$Res>  {
  factory $SceneTileCopyWith(SceneTile value, $Res Function(SceneTile) _then) = _$SceneTileCopyWithImpl;
@useResult
$Res call({
 String id, double minX, double maxX, double minZ, double maxZ, String detailPath, String coarsePath, int detailTriangles, int coarseTriangles
});




}
/// @nodoc
class _$SceneTileCopyWithImpl<$Res>
    implements $SceneTileCopyWith<$Res> {
  _$SceneTileCopyWithImpl(this._self, this._then);

  final SceneTile _self;
  final $Res Function(SceneTile) _then;

/// Create a copy of SceneTile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? minX = null,Object? maxX = null,Object? minZ = null,Object? maxZ = null,Object? detailPath = null,Object? coarsePath = null,Object? detailTriangles = null,Object? coarseTriangles = null,}) {
  return _then(SceneTile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,minX: null == minX ? _self.minX : minX // ignore: cast_nullable_to_non_nullable
as double,maxX: null == maxX ? _self.maxX : maxX // ignore: cast_nullable_to_non_nullable
as double,minZ: null == minZ ? _self.minZ : minZ // ignore: cast_nullable_to_non_nullable
as double,maxZ: null == maxZ ? _self.maxZ : maxZ // ignore: cast_nullable_to_non_nullable
as double,detailPath: null == detailPath ? _self.detailPath : detailPath // ignore: cast_nullable_to_non_nullable
as String,coarsePath: null == coarsePath ? _self.coarsePath : coarsePath // ignore: cast_nullable_to_non_nullable
as String,detailTriangles: null == detailTriangles ? _self.detailTriangles : detailTriangles // ignore: cast_nullable_to_non_nullable
as int,coarseTriangles: null == coarseTriangles ? _self.coarseTriangles : coarseTriangles // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneTile].
extension SceneTilePatterns on SceneTile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneTile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneTile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneTile value)  $default,){
final _that = this;
switch (_that) {
case _SceneTile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneTile value)?  $default,){
final _that = this;
switch (_that) {
case _SceneTile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double minX,  double maxX,  double minZ,  double maxZ,  String detailPath,  String coarsePath,  int detailTriangles,  int coarseTriangles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneTile() when $default != null:
return $default(_that.id,_that.minX,_that.maxX,_that.minZ,_that.maxZ,_that.detailPath,_that.coarsePath,_that.detailTriangles,_that.coarseTriangles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double minX,  double maxX,  double minZ,  double maxZ,  String detailPath,  String coarsePath,  int detailTriangles,  int coarseTriangles)  $default,) {final _that = this;
switch (_that) {
case _SceneTile():
return $default(_that.id,_that.minX,_that.maxX,_that.minZ,_that.maxZ,_that.detailPath,_that.coarsePath,_that.detailTriangles,_that.coarseTriangles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double minX,  double maxX,  double minZ,  double maxZ,  String detailPath,  String coarsePath,  int detailTriangles,  int coarseTriangles)?  $default,) {final _that = this;
switch (_that) {
case _SceneTile() when $default != null:
return $default(_that.id,_that.minX,_that.maxX,_that.minZ,_that.maxZ,_that.detailPath,_that.coarsePath,_that.detailTriangles,_that.coarseTriangles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneTile implements SceneTile {
  const _SceneTile({required this.id, required this.minX, required this.maxX, required this.minZ, required this.maxZ, required this.detailPath, required this.coarsePath, required this.detailTriangles, required this.coarseTriangles});
  factory _SceneTile.fromJson(Map<String, dynamic> json) => _$SceneTileFromJson(json);

@override final  String id;
@override final  double minX;
@override final  double maxX;
@override final  double minZ;
@override final  double maxZ;
@override final  String detailPath;
@override final  String coarsePath;
@override final  int detailTriangles;
@override final  int coarseTriangles;

/// Create a copy of SceneTile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneTileCopyWith<_SceneTile> get copyWith => __$SceneTileCopyWithImpl<_SceneTile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneTileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneTile&&(identical(other.id, id) || other.id == id)&&(identical(other.minX, minX) || other.minX == minX)&&(identical(other.maxX, maxX) || other.maxX == maxX)&&(identical(other.minZ, minZ) || other.minZ == minZ)&&(identical(other.maxZ, maxZ) || other.maxZ == maxZ)&&(identical(other.detailPath, detailPath) || other.detailPath == detailPath)&&(identical(other.coarsePath, coarsePath) || other.coarsePath == coarsePath)&&(identical(other.detailTriangles, detailTriangles) || other.detailTriangles == detailTriangles)&&(identical(other.coarseTriangles, coarseTriangles) || other.coarseTriangles == coarseTriangles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,minX,maxX,minZ,maxZ,detailPath,coarsePath,detailTriangles,coarseTriangles);
}

@override
String toString() {
    return 'SceneTile(id: $id, minX: $minX, maxX: $maxX, minZ: $minZ, maxZ: $maxZ, detailPath: $detailPath, coarsePath: $coarsePath, detailTriangles: $detailTriangles, coarseTriangles: $coarseTriangles)';
}


}

/// @nodoc
abstract mixin class _$SceneTileCopyWith<$Res> implements $SceneTileCopyWith<$Res> {
  factory _$SceneTileCopyWith(_SceneTile value, $Res Function(_SceneTile) _then) = __$SceneTileCopyWithImpl;
@override @useResult
$Res call({
 String id, double minX, double maxX, double minZ, double maxZ, String detailPath, String coarsePath, int detailTriangles, int coarseTriangles
});




}
/// @nodoc
class __$SceneTileCopyWithImpl<$Res>
    implements _$SceneTileCopyWith<$Res> {
  __$SceneTileCopyWithImpl(this._self, this._then);

  final _SceneTile _self;
  final $Res Function(_SceneTile) _then;

/// Create a copy of SceneTile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? minX = null,Object? maxX = null,Object? minZ = null,Object? maxZ = null,Object? detailPath = null,Object? coarsePath = null,Object? detailTriangles = null,Object? coarseTriangles = null,}) {
  return _then(_SceneTile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,minX: null == minX ? _self.minX : minX // ignore: cast_nullable_to_non_nullable
as double,maxX: null == maxX ? _self.maxX : maxX // ignore: cast_nullable_to_non_nullable
as double,minZ: null == minZ ? _self.minZ : minZ // ignore: cast_nullable_to_non_nullable
as double,maxZ: null == maxZ ? _self.maxZ : maxZ // ignore: cast_nullable_to_non_nullable
as double,detailPath: null == detailPath ? _self.detailPath : detailPath // ignore: cast_nullable_to_non_nullable
as String,coarsePath: null == coarsePath ? _self.coarsePath : coarsePath // ignore: cast_nullable_to_non_nullable
as String,detailTriangles: null == detailTriangles ? _self.detailTriangles : detailTriangles // ignore: cast_nullable_to_non_nullable
as int,coarseTriangles: null == coarseTriangles ? _self.coarseTriangles : coarseTriangles // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
