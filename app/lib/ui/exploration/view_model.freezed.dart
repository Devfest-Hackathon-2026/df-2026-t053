// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExplorationState {

 SceneAsset get asset; ExplorationMode get mode; String? get spot; ExplorationPanel get panel; bool get showResult; bool get isLoading; bool get loadFailed; double? get importSeconds; double get fps; double get frameMs; Position? get playerPosition; double get cameraForwardX; double get cameraForwardZ; bool get onRing; PlaySession? get session; SubmitShotResponse? get result; bool get sessionExpired; PlayFailureKind? get shotFailure; List<MapPinData> get mapPins; ChallengeRevision? get revision; bool get showShotFrame;
/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorationStateCopyWith<ExplorationState> get copyWith => _$ExplorationStateCopyWithImpl<ExplorationState>(this as ExplorationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExplorationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorationState&&(identical(other.asset, _this.asset) || other.asset == _this.asset)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.spot, _this.spot) || other.spot == _this.spot)&&(identical(other.panel, _this.panel) || other.panel == _this.panel)&&(identical(other.showResult, _this.showResult) || other.showResult == _this.showResult)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.loadFailed, _this.loadFailed) || other.loadFailed == _this.loadFailed)&&(identical(other.importSeconds, _this.importSeconds) || other.importSeconds == _this.importSeconds)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.frameMs, _this.frameMs) || other.frameMs == _this.frameMs)&&(identical(other.playerPosition, _this.playerPosition) || other.playerPosition == _this.playerPosition)&&(identical(other.cameraForwardX, _this.cameraForwardX) || other.cameraForwardX == _this.cameraForwardX)&&(identical(other.cameraForwardZ, _this.cameraForwardZ) || other.cameraForwardZ == _this.cameraForwardZ)&&(identical(other.onRing, _this.onRing) || other.onRing == _this.onRing)&&(identical(other.session, _this.session) || other.session == _this.session)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.sessionExpired, _this.sessionExpired) || other.sessionExpired == _this.sessionExpired)&&(identical(other.shotFailure, _this.shotFailure) || other.shotFailure == _this.shotFailure)&&const DeepCollectionEquality().equals(other.mapPins, _this.mapPins)&&(identical(other.revision, _this.revision) || other.revision == _this.revision)&&(identical(other.showShotFrame, _this.showShotFrame) || other.showShotFrame == _this.showShotFrame));
}


@override
int get hashCode {
  final _this = this as ExplorationState;
  return Object.hashAll([runtimeType,_this.asset,_this.mode,_this.spot,_this.panel,_this.showResult,_this.isLoading,_this.loadFailed,_this.importSeconds,_this.fps,_this.frameMs,_this.playerPosition,_this.cameraForwardX,_this.cameraForwardZ,_this.onRing,_this.session,_this.result,_this.sessionExpired,_this.shotFailure,const DeepCollectionEquality().hash(_this.mapPins),_this.revision,_this.showShotFrame]);
}

@override
String toString() {
  final _this = this as ExplorationState;
  return 'ExplorationState(asset: ${_this.asset}, mode: ${_this.mode}, spot: ${_this.spot}, panel: ${_this.panel}, showResult: ${_this.showResult}, isLoading: ${_this.isLoading}, loadFailed: ${_this.loadFailed}, importSeconds: ${_this.importSeconds}, fps: ${_this.fps}, frameMs: ${_this.frameMs}, playerPosition: ${_this.playerPosition}, cameraForwardX: ${_this.cameraForwardX}, cameraForwardZ: ${_this.cameraForwardZ}, onRing: ${_this.onRing}, session: ${_this.session}, result: ${_this.result}, sessionExpired: ${_this.sessionExpired}, shotFailure: ${_this.shotFailure}, mapPins: ${_this.mapPins}, revision: ${_this.revision}, showShotFrame: ${_this.showShotFrame})';
}


}

/// @nodoc
abstract mixin class $ExplorationStateCopyWith<$Res>  {
  factory $ExplorationStateCopyWith(ExplorationState value, $Res Function(ExplorationState) _then) = _$ExplorationStateCopyWithImpl;
@useResult
$Res call({
 SceneAsset asset, ExplorationMode mode, String? spot, ExplorationPanel panel, bool showResult, bool isLoading, bool loadFailed, double? importSeconds, double fps, double frameMs, Position? playerPosition, double cameraForwardX, double cameraForwardZ, bool onRing, PlaySession? session, SubmitShotResponse? result, bool sessionExpired, PlayFailureKind? shotFailure, List<MapPinData> mapPins, ChallengeRevision? revision, bool showShotFrame
});


$SceneAssetCopyWith<$Res> get asset;$PositionCopyWith<$Res>? get playerPosition;

}
/// @nodoc
class _$ExplorationStateCopyWithImpl<$Res>
    implements $ExplorationStateCopyWith<$Res> {
  _$ExplorationStateCopyWithImpl(this._self, this._then);

  final ExplorationState _self;
  final $Res Function(ExplorationState) _then;

/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asset = null,Object? mode = null,Object? spot = freezed,Object? panel = null,Object? showResult = null,Object? isLoading = null,Object? loadFailed = null,Object? importSeconds = freezed,Object? fps = null,Object? frameMs = null,Object? playerPosition = freezed,Object? cameraForwardX = null,Object? cameraForwardZ = null,Object? onRing = null,Object? session = freezed,Object? result = freezed,Object? sessionExpired = null,Object? shotFailure = freezed,Object? mapPins = null,Object? revision = freezed,Object? showShotFrame = null,}) {
  return _then(ExplorationState(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as SceneAsset,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,panel: null == panel ? _self.panel : panel // ignore: cast_nullable_to_non_nullable
as ExplorationPanel,showResult: null == showResult ? _self.showResult : showResult // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,importSeconds: freezed == importSeconds ? _self.importSeconds : importSeconds // ignore: cast_nullable_to_non_nullable
as double?,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double,frameMs: null == frameMs ? _self.frameMs : frameMs // ignore: cast_nullable_to_non_nullable
as double,playerPosition: freezed == playerPosition ? _self.playerPosition : playerPosition // ignore: cast_nullable_to_non_nullable
as Position?,cameraForwardX: null == cameraForwardX ? _self.cameraForwardX : cameraForwardX // ignore: cast_nullable_to_non_nullable
as double,cameraForwardZ: null == cameraForwardZ ? _self.cameraForwardZ : cameraForwardZ // ignore: cast_nullable_to_non_nullable
as double,onRing: null == onRing ? _self.onRing : onRing // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as PlaySession?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SubmitShotResponse?,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,shotFailure: freezed == shotFailure ? _self.shotFailure : shotFailure // ignore: cast_nullable_to_non_nullable
as PlayFailureKind?,mapPins: null == mapPins ? _self.mapPins : mapPins // ignore: cast_nullable_to_non_nullable
as List<MapPinData>,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as ChallengeRevision?,showShotFrame: null == showShotFrame ? _self.showShotFrame : showShotFrame // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SceneAssetCopyWith<$Res> get asset {
  
  return $SceneAssetCopyWith<$Res>(_self.asset, (value) {
    return _then(_self.copyWith(asset: value));
  });
}/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PositionCopyWith<$Res>? get playerPosition {
    if (_self.playerPosition == null) {
    return null;
  }

  return $PositionCopyWith<$Res>(_self.playerPosition!, (value) {
    return _then(_self.copyWith(playerPosition: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExplorationState].
extension ExplorationStatePatterns on ExplorationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExplorationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExplorationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExplorationState value)  $default,){
final _that = this;
switch (_that) {
case _ExplorationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExplorationState value)?  $default,){
final _that = this;
switch (_that) {
case _ExplorationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SceneAsset asset,  ExplorationMode mode,  String? spot,  ExplorationPanel panel,  bool showResult,  bool isLoading,  bool loadFailed,  double? importSeconds,  double fps,  double frameMs,  Position? playerPosition,  double cameraForwardX,  double cameraForwardZ,  bool onRing,  PlaySession? session,  SubmitShotResponse? result,  bool sessionExpired,  PlayFailureKind? shotFailure,  List<MapPinData> mapPins,  ChallengeRevision? revision,  bool showShotFrame)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExplorationState() when $default != null:
return $default(_that.asset,_that.mode,_that.spot,_that.panel,_that.showResult,_that.isLoading,_that.loadFailed,_that.importSeconds,_that.fps,_that.frameMs,_that.playerPosition,_that.cameraForwardX,_that.cameraForwardZ,_that.onRing,_that.session,_that.result,_that.sessionExpired,_that.shotFailure,_that.mapPins,_that.revision,_that.showShotFrame);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SceneAsset asset,  ExplorationMode mode,  String? spot,  ExplorationPanel panel,  bool showResult,  bool isLoading,  bool loadFailed,  double? importSeconds,  double fps,  double frameMs,  Position? playerPosition,  double cameraForwardX,  double cameraForwardZ,  bool onRing,  PlaySession? session,  SubmitShotResponse? result,  bool sessionExpired,  PlayFailureKind? shotFailure,  List<MapPinData> mapPins,  ChallengeRevision? revision,  bool showShotFrame)  $default,) {final _that = this;
switch (_that) {
case _ExplorationState():
return $default(_that.asset,_that.mode,_that.spot,_that.panel,_that.showResult,_that.isLoading,_that.loadFailed,_that.importSeconds,_that.fps,_that.frameMs,_that.playerPosition,_that.cameraForwardX,_that.cameraForwardZ,_that.onRing,_that.session,_that.result,_that.sessionExpired,_that.shotFailure,_that.mapPins,_that.revision,_that.showShotFrame);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SceneAsset asset,  ExplorationMode mode,  String? spot,  ExplorationPanel panel,  bool showResult,  bool isLoading,  bool loadFailed,  double? importSeconds,  double fps,  double frameMs,  Position? playerPosition,  double cameraForwardX,  double cameraForwardZ,  bool onRing,  PlaySession? session,  SubmitShotResponse? result,  bool sessionExpired,  PlayFailureKind? shotFailure,  List<MapPinData> mapPins,  ChallengeRevision? revision,  bool showShotFrame)?  $default,) {final _that = this;
switch (_that) {
case _ExplorationState() when $default != null:
return $default(_that.asset,_that.mode,_that.spot,_that.panel,_that.showResult,_that.isLoading,_that.loadFailed,_that.importSeconds,_that.fps,_that.frameMs,_that.playerPosition,_that.cameraForwardX,_that.cameraForwardZ,_that.onRing,_that.session,_that.result,_that.sessionExpired,_that.shotFailure,_that.mapPins,_that.revision,_that.showShotFrame);case _:
  return null;

}
}

}

/// @nodoc


class _ExplorationState implements ExplorationState {
  const _ExplorationState({required this.asset, this.mode = ExplorationMode.free, this.spot, this.panel = ExplorationPanel.none, this.showResult = false, this.isLoading = true, this.loadFailed = false, this.importSeconds, this.fps = 0, this.frameMs = 0, this.playerPosition, this.cameraForwardX = 0, this.cameraForwardZ = 0, this.onRing = false, this.session, this.result, this.sessionExpired = false, this.shotFailure,  List<MapPinData> mapPins = const [], this.revision, this.showShotFrame = true}): _mapPins = mapPins;
  

@override final  SceneAsset asset;
@override@JsonKey() final  ExplorationMode mode;
@override final  String? spot;
@override@JsonKey() final  ExplorationPanel panel;
@override@JsonKey() final  bool showResult;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool loadFailed;
@override final  double? importSeconds;
@override@JsonKey() final  double fps;
@override@JsonKey() final  double frameMs;
@override final  Position? playerPosition;
@override@JsonKey() final  double cameraForwardX;
@override@JsonKey() final  double cameraForwardZ;
@override@JsonKey() final  bool onRing;
@override final  PlaySession? session;
@override final  SubmitShotResponse? result;
@override@JsonKey() final  bool sessionExpired;
@override final  PlayFailureKind? shotFailure;
 final  List<MapPinData> _mapPins;
@override@JsonKey() List<MapPinData> get mapPins {
  if (_mapPins is EqualUnmodifiableListView) return _mapPins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapPins);
}

@override final  ChallengeRevision? revision;
@override@JsonKey() final  bool showShotFrame;

/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplorationStateCopyWith<_ExplorationState> get copyWith => __$ExplorationStateCopyWithImpl<_ExplorationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExplorationState&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.spot, spot) || other.spot == spot)&&(identical(other.panel, panel) || other.panel == panel)&&(identical(other.showResult, showResult) || other.showResult == showResult)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.importSeconds, importSeconds) || other.importSeconds == importSeconds)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.frameMs, frameMs) || other.frameMs == frameMs)&&(identical(other.playerPosition, playerPosition) || other.playerPosition == playerPosition)&&(identical(other.cameraForwardX, cameraForwardX) || other.cameraForwardX == cameraForwardX)&&(identical(other.cameraForwardZ, cameraForwardZ) || other.cameraForwardZ == cameraForwardZ)&&(identical(other.onRing, onRing) || other.onRing == onRing)&&(identical(other.session, session) || other.session == session)&&(identical(other.result, result) || other.result == result)&&(identical(other.sessionExpired, sessionExpired) || other.sessionExpired == sessionExpired)&&(identical(other.shotFailure, shotFailure) || other.shotFailure == shotFailure)&&const DeepCollectionEquality().equals(other.mapPins, _mapPins)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.showShotFrame, showShotFrame) || other.showShotFrame == showShotFrame));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,asset,mode,spot,panel,showResult,isLoading,loadFailed,importSeconds,fps,frameMs,playerPosition,cameraForwardX,cameraForwardZ,onRing,session,result,sessionExpired,shotFailure,const DeepCollectionEquality().hash(_mapPins),revision,showShotFrame]);
}

@override
String toString() {
    return 'ExplorationState(asset: $asset, mode: $mode, spot: $spot, panel: $panel, showResult: $showResult, isLoading: $isLoading, loadFailed: $loadFailed, importSeconds: $importSeconds, fps: $fps, frameMs: $frameMs, playerPosition: $playerPosition, cameraForwardX: $cameraForwardX, cameraForwardZ: $cameraForwardZ, onRing: $onRing, session: $session, result: $result, sessionExpired: $sessionExpired, shotFailure: $shotFailure, mapPins: $mapPins, revision: $revision, showShotFrame: $showShotFrame)';
}


}

/// @nodoc
abstract mixin class _$ExplorationStateCopyWith<$Res> implements $ExplorationStateCopyWith<$Res> {
  factory _$ExplorationStateCopyWith(_ExplorationState value, $Res Function(_ExplorationState) _then) = __$ExplorationStateCopyWithImpl;
@override @useResult
$Res call({
 SceneAsset asset, ExplorationMode mode, String? spot, ExplorationPanel panel, bool showResult, bool isLoading, bool loadFailed, double? importSeconds, double fps, double frameMs, Position? playerPosition, double cameraForwardX, double cameraForwardZ, bool onRing, PlaySession? session, SubmitShotResponse? result, bool sessionExpired, PlayFailureKind? shotFailure, List<MapPinData> mapPins, ChallengeRevision? revision, bool showShotFrame
});


@override $SceneAssetCopyWith<$Res> get asset;@override $PositionCopyWith<$Res>? get playerPosition;

}
/// @nodoc
class __$ExplorationStateCopyWithImpl<$Res>
    implements _$ExplorationStateCopyWith<$Res> {
  __$ExplorationStateCopyWithImpl(this._self, this._then);

  final _ExplorationState _self;
  final $Res Function(_ExplorationState) _then;

/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asset = null,Object? mode = null,Object? spot = freezed,Object? panel = null,Object? showResult = null,Object? isLoading = null,Object? loadFailed = null,Object? importSeconds = freezed,Object? fps = null,Object? frameMs = null,Object? playerPosition = freezed,Object? cameraForwardX = null,Object? cameraForwardZ = null,Object? onRing = null,Object? session = freezed,Object? result = freezed,Object? sessionExpired = null,Object? shotFailure = freezed,Object? mapPins = null,Object? revision = freezed,Object? showShotFrame = null,}) {
  return _then(_ExplorationState(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as SceneAsset,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,panel: null == panel ? _self.panel : panel // ignore: cast_nullable_to_non_nullable
as ExplorationPanel,showResult: null == showResult ? _self.showResult : showResult // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,importSeconds: freezed == importSeconds ? _self.importSeconds : importSeconds // ignore: cast_nullable_to_non_nullable
as double?,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double,frameMs: null == frameMs ? _self.frameMs : frameMs // ignore: cast_nullable_to_non_nullable
as double,playerPosition: freezed == playerPosition ? _self.playerPosition : playerPosition // ignore: cast_nullable_to_non_nullable
as Position?,cameraForwardX: null == cameraForwardX ? _self.cameraForwardX : cameraForwardX // ignore: cast_nullable_to_non_nullable
as double,cameraForwardZ: null == cameraForwardZ ? _self.cameraForwardZ : cameraForwardZ // ignore: cast_nullable_to_non_nullable
as double,onRing: null == onRing ? _self.onRing : onRing // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as PlaySession?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SubmitShotResponse?,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,shotFailure: freezed == shotFailure ? _self.shotFailure : shotFailure // ignore: cast_nullable_to_non_nullable
as PlayFailureKind?,mapPins: null == mapPins ? _self._mapPins : mapPins // ignore: cast_nullable_to_non_nullable
as List<MapPinData>,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as ChallengeRevision?,showShotFrame: null == showShotFrame ? _self.showShotFrame : showShotFrame // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SceneAssetCopyWith<$Res> get asset {
  
  return $SceneAssetCopyWith<$Res>(_self.asset, (value) {
    return _then(_self.copyWith(asset: value));
  });
}/// Create a copy of ExplorationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PositionCopyWith<$Res>? get playerPosition {
    if (_self.playerPosition == null) {
    return null;
  }

  return $PositionCopyWith<$Res>(_self.playerPosition!, (value) {
    return _then(_self.copyWith(playerPosition: value));
  });
}
}

// dart format on
