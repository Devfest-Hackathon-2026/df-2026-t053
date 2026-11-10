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
mixin _$ModeSelectState {

 String get nickname; ModeSelectFlow get flow; ExplorationMode get mode; String? get spot; double get progress; ModeSelectBoot get boot; List<SpawnEntrance> get entrances; String? get notice; PlayPhase get playPhase; PlayMode? get pendingSessionMode;
/// Create a copy of ModeSelectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModeSelectStateCopyWith<ModeSelectState> get copyWith => _$ModeSelectStateCopyWithImpl<ModeSelectState>(this as ModeSelectState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ModeSelectState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModeSelectState&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.flow, _this.flow) || other.flow == _this.flow)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.spot, _this.spot) || other.spot == _this.spot)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.boot, _this.boot) || other.boot == _this.boot)&&const DeepCollectionEquality().equals(other.entrances, _this.entrances)&&(identical(other.notice, _this.notice) || other.notice == _this.notice)&&(identical(other.playPhase, _this.playPhase) || other.playPhase == _this.playPhase)&&(identical(other.pendingSessionMode, _this.pendingSessionMode) || other.pendingSessionMode == _this.pendingSessionMode));
}


@override
int get hashCode {
  final _this = this as ModeSelectState;
  return Object.hash(runtimeType,_this.nickname,_this.flow,_this.mode,_this.spot,_this.progress,_this.boot,const DeepCollectionEquality().hash(_this.entrances),_this.notice,_this.playPhase,_this.pendingSessionMode);
}

@override
String toString() {
  final _this = this as ModeSelectState;
  return 'ModeSelectState(nickname: ${_this.nickname}, flow: ${_this.flow}, mode: ${_this.mode}, spot: ${_this.spot}, progress: ${_this.progress}, boot: ${_this.boot}, entrances: ${_this.entrances}, notice: ${_this.notice}, playPhase: ${_this.playPhase}, pendingSessionMode: ${_this.pendingSessionMode})';
}


}

/// @nodoc
abstract mixin class $ModeSelectStateCopyWith<$Res>  {
  factory $ModeSelectStateCopyWith(ModeSelectState value, $Res Function(ModeSelectState) _then) = _$ModeSelectStateCopyWithImpl;
@useResult
$Res call({
 String nickname, ModeSelectFlow flow, ExplorationMode mode, String? spot, double progress, ModeSelectBoot boot, List<SpawnEntrance> entrances, String? notice, PlayPhase playPhase, PlayMode? pendingSessionMode
});




}
/// @nodoc
class _$ModeSelectStateCopyWithImpl<$Res>
    implements $ModeSelectStateCopyWith<$Res> {
  _$ModeSelectStateCopyWithImpl(this._self, this._then);

  final ModeSelectState _self;
  final $Res Function(ModeSelectState) _then;

/// Create a copy of ModeSelectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nickname = null,Object? flow = null,Object? mode = null,Object? spot = freezed,Object? progress = null,Object? boot = null,Object? entrances = null,Object? notice = freezed,Object? playPhase = null,Object? pendingSessionMode = freezed,}) {
  return _then(ModeSelectState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as ModeSelectFlow,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,boot: null == boot ? _self.boot : boot // ignore: cast_nullable_to_non_nullable
as ModeSelectBoot,entrances: null == entrances ? _self.entrances : entrances // ignore: cast_nullable_to_non_nullable
as List<SpawnEntrance>,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,playPhase: null == playPhase ? _self.playPhase : playPhase // ignore: cast_nullable_to_non_nullable
as PlayPhase,pendingSessionMode: freezed == pendingSessionMode ? _self.pendingSessionMode : pendingSessionMode // ignore: cast_nullable_to_non_nullable
as PlayMode?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModeSelectState].
extension ModeSelectStatePatterns on ModeSelectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModeSelectState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModeSelectState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModeSelectState value)  $default,){
final _that = this;
switch (_that) {
case _ModeSelectState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModeSelectState value)?  $default,){
final _that = this;
switch (_that) {
case _ModeSelectState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nickname,  ModeSelectFlow flow,  ExplorationMode mode,  String? spot,  double progress,  ModeSelectBoot boot,  List<SpawnEntrance> entrances,  String? notice,  PlayPhase playPhase,  PlayMode? pendingSessionMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModeSelectState() when $default != null:
return $default(_that.nickname,_that.flow,_that.mode,_that.spot,_that.progress,_that.boot,_that.entrances,_that.notice,_that.playPhase,_that.pendingSessionMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nickname,  ModeSelectFlow flow,  ExplorationMode mode,  String? spot,  double progress,  ModeSelectBoot boot,  List<SpawnEntrance> entrances,  String? notice,  PlayPhase playPhase,  PlayMode? pendingSessionMode)  $default,) {final _that = this;
switch (_that) {
case _ModeSelectState():
return $default(_that.nickname,_that.flow,_that.mode,_that.spot,_that.progress,_that.boot,_that.entrances,_that.notice,_that.playPhase,_that.pendingSessionMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nickname,  ModeSelectFlow flow,  ExplorationMode mode,  String? spot,  double progress,  ModeSelectBoot boot,  List<SpawnEntrance> entrances,  String? notice,  PlayPhase playPhase,  PlayMode? pendingSessionMode)?  $default,) {final _that = this;
switch (_that) {
case _ModeSelectState() when $default != null:
return $default(_that.nickname,_that.flow,_that.mode,_that.spot,_that.progress,_that.boot,_that.entrances,_that.notice,_that.playPhase,_that.pendingSessionMode);case _:
  return null;

}
}

}

/// @nodoc


class _ModeSelectState implements ModeSelectState {
  const _ModeSelectState({this.nickname = '旅人4821', this.flow = ModeSelectFlow.none, this.mode = ExplorationMode.free, this.spot = null, this.progress = 0, this.boot = ModeSelectBoot.booting,  List<SpawnEntrance> entrances = const [], this.notice, this.playPhase = PlayPhase.idle, this.pendingSessionMode}): _entrances = entrances;
  

@override@JsonKey() final  String nickname;
@override@JsonKey() final  ModeSelectFlow flow;
@override@JsonKey() final  ExplorationMode mode;
@override@JsonKey() final  String? spot;
@override@JsonKey() final  double progress;
@override@JsonKey() final  ModeSelectBoot boot;
 final  List<SpawnEntrance> _entrances;
@override@JsonKey() List<SpawnEntrance> get entrances {
  if (_entrances is EqualUnmodifiableListView) return _entrances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entrances);
}

@override final  String? notice;
@override@JsonKey() final  PlayPhase playPhase;
@override final  PlayMode? pendingSessionMode;

/// Create a copy of ModeSelectState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModeSelectStateCopyWith<_ModeSelectState> get copyWith => __$ModeSelectStateCopyWithImpl<_ModeSelectState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModeSelectState&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.spot, spot) || other.spot == spot)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.boot, boot) || other.boot == boot)&&const DeepCollectionEquality().equals(other.entrances, _entrances)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.playPhase, playPhase) || other.playPhase == playPhase)&&(identical(other.pendingSessionMode, pendingSessionMode) || other.pendingSessionMode == pendingSessionMode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nickname,flow,mode,spot,progress,boot,const DeepCollectionEquality().hash(_entrances),notice,playPhase,pendingSessionMode);
}

@override
String toString() {
    return 'ModeSelectState(nickname: $nickname, flow: $flow, mode: $mode, spot: $spot, progress: $progress, boot: $boot, entrances: $entrances, notice: $notice, playPhase: $playPhase, pendingSessionMode: $pendingSessionMode)';
}


}

/// @nodoc
abstract mixin class _$ModeSelectStateCopyWith<$Res> implements $ModeSelectStateCopyWith<$Res> {
  factory _$ModeSelectStateCopyWith(_ModeSelectState value, $Res Function(_ModeSelectState) _then) = __$ModeSelectStateCopyWithImpl;
@override @useResult
$Res call({
 String nickname, ModeSelectFlow flow, ExplorationMode mode, String? spot, double progress, ModeSelectBoot boot, List<SpawnEntrance> entrances, String? notice, PlayPhase playPhase, PlayMode? pendingSessionMode
});




}
/// @nodoc
class __$ModeSelectStateCopyWithImpl<$Res>
    implements _$ModeSelectStateCopyWith<$Res> {
  __$ModeSelectStateCopyWithImpl(this._self, this._then);

  final _ModeSelectState _self;
  final $Res Function(_ModeSelectState) _then;

/// Create a copy of ModeSelectState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nickname = null,Object? flow = null,Object? mode = null,Object? spot = freezed,Object? progress = null,Object? boot = null,Object? entrances = null,Object? notice = freezed,Object? playPhase = null,Object? pendingSessionMode = freezed,}) {
  return _then(_ModeSelectState(
nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as ModeSelectFlow,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,spot: freezed == spot ? _self.spot : spot // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,boot: null == boot ? _self.boot : boot // ignore: cast_nullable_to_non_nullable
as ModeSelectBoot,entrances: null == entrances ? _self._entrances : entrances // ignore: cast_nullable_to_non_nullable
as List<SpawnEntrance>,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,playPhase: null == playPhase ? _self.playPhase : playPhase // ignore: cast_nullable_to_non_nullable
as PlayPhase,pendingSessionMode: freezed == pendingSessionMode ? _self.pendingSessionMode : pendingSessionMode // ignore: cast_nullable_to_non_nullable
as PlayMode?,
  ));
}


}

// dart format on
