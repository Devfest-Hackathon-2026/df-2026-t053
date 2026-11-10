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
mixin _$PlayState {

 PlayPhase get phase; PlaySession? get session; SubmitShotResponse? get result; PendingShot? get pendingShot;
/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayStateCopyWith<PlayState> get copyWith => _$PlayStateCopyWithImpl<PlayState>(this as PlayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayState&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.session, _this.session) || other.session == _this.session)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.pendingShot, _this.pendingShot) || other.pendingShot == _this.pendingShot));
}


@override
int get hashCode {
  final _this = this as PlayState;
  return Object.hash(runtimeType,_this.phase,_this.session,_this.result,_this.pendingShot);
}

@override
String toString() {
  final _this = this as PlayState;
  return 'PlayState(phase: ${_this.phase}, session: ${_this.session}, result: ${_this.result}, pendingShot: ${_this.pendingShot})';
}


}

/// @nodoc
abstract mixin class $PlayStateCopyWith<$Res>  {
  factory $PlayStateCopyWith(PlayState value, $Res Function(PlayState) _then) = _$PlayStateCopyWithImpl;
@useResult
$Res call({
 PlayPhase phase, PlaySession? session, SubmitShotResponse? result, PendingShot? pendingShot
});


$PendingShotCopyWith<$Res>? get pendingShot;

}
/// @nodoc
class _$PlayStateCopyWithImpl<$Res>
    implements $PlayStateCopyWith<$Res> {
  _$PlayStateCopyWithImpl(this._self, this._then);

  final PlayState _self;
  final $Res Function(PlayState) _then;

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? session = freezed,Object? result = freezed,Object? pendingShot = freezed,}) {
  return _then(PlayState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PlayPhase,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as PlaySession?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SubmitShotResponse?,pendingShot: freezed == pendingShot ? _self.pendingShot : pendingShot // ignore: cast_nullable_to_non_nullable
as PendingShot?,
  ));
}
/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingShotCopyWith<$Res>? get pendingShot {
    if (_self.pendingShot == null) {
    return null;
  }

  return $PendingShotCopyWith<$Res>(_self.pendingShot!, (value) {
    return _then(_self.copyWith(pendingShot: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayState].
extension PlayStatePatterns on PlayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayState value)  $default,){
final _that = this;
switch (_that) {
case _PlayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayPhase phase,  PlaySession? session,  SubmitShotResponse? result,  PendingShot? pendingShot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayState() when $default != null:
return $default(_that.phase,_that.session,_that.result,_that.pendingShot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayPhase phase,  PlaySession? session,  SubmitShotResponse? result,  PendingShot? pendingShot)  $default,) {final _that = this;
switch (_that) {
case _PlayState():
return $default(_that.phase,_that.session,_that.result,_that.pendingShot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayPhase phase,  PlaySession? session,  SubmitShotResponse? result,  PendingShot? pendingShot)?  $default,) {final _that = this;
switch (_that) {
case _PlayState() when $default != null:
return $default(_that.phase,_that.session,_that.result,_that.pendingShot);case _:
  return null;

}
}

}

/// @nodoc


class _PlayState implements PlayState {
  const _PlayState({this.phase = PlayPhase.idle, this.session, this.result, this.pendingShot});
  

@override@JsonKey() final  PlayPhase phase;
@override final  PlaySession? session;
@override final  SubmitShotResponse? result;
@override final  PendingShot? pendingShot;

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayStateCopyWith<_PlayState> get copyWith => __$PlayStateCopyWithImpl<_PlayState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.session, session) || other.session == session)&&(identical(other.result, result) || other.result == result)&&(identical(other.pendingShot, pendingShot) || other.pendingShot == pendingShot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,session,result,pendingShot);
}

@override
String toString() {
    return 'PlayState(phase: $phase, session: $session, result: $result, pendingShot: $pendingShot)';
}


}

/// @nodoc
abstract mixin class _$PlayStateCopyWith<$Res> implements $PlayStateCopyWith<$Res> {
  factory _$PlayStateCopyWith(_PlayState value, $Res Function(_PlayState) _then) = __$PlayStateCopyWithImpl;
@override @useResult
$Res call({
 PlayPhase phase, PlaySession? session, SubmitShotResponse? result, PendingShot? pendingShot
});


@override $PendingShotCopyWith<$Res>? get pendingShot;

}
/// @nodoc
class __$PlayStateCopyWithImpl<$Res>
    implements _$PlayStateCopyWith<$Res> {
  __$PlayStateCopyWithImpl(this._self, this._then);

  final _PlayState _self;
  final $Res Function(_PlayState) _then;

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? session = freezed,Object? result = freezed,Object? pendingShot = freezed,}) {
  return _then(_PlayState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PlayPhase,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as PlaySession?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SubmitShotResponse?,pendingShot: freezed == pendingShot ? _self.pendingShot : pendingShot // ignore: cast_nullable_to_non_nullable
as PendingShot?,
  ));
}

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingShotCopyWith<$Res>? get pendingShot {
    if (_self.pendingShot == null) {
    return null;
  }

  return $PendingShotCopyWith<$Res>(_self.pendingShot!, (value) {
    return _then(_self.copyWith(pendingShot: value));
  });
}
}


/// @nodoc
mixin _$PendingShot {

 String get authUserId; String get playSessionId; int get revisionId; ShotInput get shot; String get requestId;
/// Create a copy of PendingShot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingShotCopyWith<PendingShot> get copyWith => _$PendingShotCopyWithImpl<PendingShot>(this as PendingShot, _$identity);

  /// Serializes this PendingShot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PendingShot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingShot&&(identical(other.authUserId, _this.authUserId) || other.authUserId == _this.authUserId)&&(identical(other.playSessionId, _this.playSessionId) || other.playSessionId == _this.playSessionId)&&(identical(other.revisionId, _this.revisionId) || other.revisionId == _this.revisionId)&&(identical(other.shot, _this.shot) || other.shot == _this.shot)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PendingShot;
  return Object.hash(runtimeType,_this.authUserId,_this.playSessionId,_this.revisionId,_this.shot,_this.requestId);
}

@override
String toString() {
  final _this = this as PendingShot;
  return 'PendingShot(authUserId: ${_this.authUserId}, playSessionId: ${_this.playSessionId}, revisionId: ${_this.revisionId}, shot: ${_this.shot}, requestId: ${_this.requestId})';
}


}

/// @nodoc
abstract mixin class $PendingShotCopyWith<$Res>  {
  factory $PendingShotCopyWith(PendingShot value, $Res Function(PendingShot) _then) = _$PendingShotCopyWithImpl;
@useResult
$Res call({
 String authUserId, String playSessionId, int revisionId, ShotInput shot, String requestId
});




}
/// @nodoc
class _$PendingShotCopyWithImpl<$Res>
    implements $PendingShotCopyWith<$Res> {
  _$PendingShotCopyWithImpl(this._self, this._then);

  final PendingShot _self;
  final $Res Function(PendingShot) _then;

/// Create a copy of PendingShot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authUserId = null,Object? playSessionId = null,Object? revisionId = null,Object? shot = null,Object? requestId = null,}) {
  return _then(PendingShot(
authUserId: null == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String,playSessionId: null == playSessionId ? _self.playSessionId : playSessionId // ignore: cast_nullable_to_non_nullable
as String,revisionId: null == revisionId ? _self.revisionId : revisionId // ignore: cast_nullable_to_non_nullable
as int,shot: null == shot ? _self.shot : shot // ignore: cast_nullable_to_non_nullable
as ShotInput,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingShot].
extension PendingShotPatterns on PendingShot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingShot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingShot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingShot value)  $default,){
final _that = this;
switch (_that) {
case _PendingShot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingShot value)?  $default,){
final _that = this;
switch (_that) {
case _PendingShot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String authUserId,  String playSessionId,  int revisionId,  ShotInput shot,  String requestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingShot() when $default != null:
return $default(_that.authUserId,_that.playSessionId,_that.revisionId,_that.shot,_that.requestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String authUserId,  String playSessionId,  int revisionId,  ShotInput shot,  String requestId)  $default,) {final _that = this;
switch (_that) {
case _PendingShot():
return $default(_that.authUserId,_that.playSessionId,_that.revisionId,_that.shot,_that.requestId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String authUserId,  String playSessionId,  int revisionId,  ShotInput shot,  String requestId)?  $default,) {final _that = this;
switch (_that) {
case _PendingShot() when $default != null:
return $default(_that.authUserId,_that.playSessionId,_that.revisionId,_that.shot,_that.requestId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingShot implements PendingShot {
  const _PendingShot({required this.authUserId, required this.playSessionId, required this.revisionId, required this.shot, required this.requestId});
  factory _PendingShot.fromJson(Map<String, dynamic> json) => _$PendingShotFromJson(json);

@override final  String authUserId;
@override final  String playSessionId;
@override final  int revisionId;
@override final  ShotInput shot;
@override final  String requestId;

/// Create a copy of PendingShot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingShotCopyWith<_PendingShot> get copyWith => __$PendingShotCopyWithImpl<_PendingShot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingShotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingShot&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.playSessionId, playSessionId) || other.playSessionId == playSessionId)&&(identical(other.revisionId, revisionId) || other.revisionId == revisionId)&&(identical(other.shot, shot) || other.shot == shot)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,authUserId,playSessionId,revisionId,shot,requestId);
}

@override
String toString() {
    return 'PendingShot(authUserId: $authUserId, playSessionId: $playSessionId, revisionId: $revisionId, shot: $shot, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class _$PendingShotCopyWith<$Res> implements $PendingShotCopyWith<$Res> {
  factory _$PendingShotCopyWith(_PendingShot value, $Res Function(_PendingShot) _then) = __$PendingShotCopyWithImpl;
@override @useResult
$Res call({
 String authUserId, String playSessionId, int revisionId, ShotInput shot, String requestId
});




}
/// @nodoc
class __$PendingShotCopyWithImpl<$Res>
    implements _$PendingShotCopyWith<$Res> {
  __$PendingShotCopyWithImpl(this._self, this._then);

  final _PendingShot _self;
  final $Res Function(_PendingShot) _then;

/// Create a copy of PendingShot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authUserId = null,Object? playSessionId = null,Object? revisionId = null,Object? shot = null,Object? requestId = null,}) {
  return _then(_PendingShot(
authUserId: null == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String,playSessionId: null == playSessionId ? _self.playSessionId : playSessionId // ignore: cast_nullable_to_non_nullable
as String,revisionId: null == revisionId ? _self.revisionId : revisionId // ignore: cast_nullable_to_non_nullable
as int,shot: null == shot ? _self.shot : shot // ignore: cast_nullable_to_non_nullable
as ShotInput,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PlayFailure {

 PlayFailureKind get kind; int? get retryAfterSeconds;
/// Create a copy of PlayFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayFailureCopyWith<PlayFailure> get copyWith => _$PlayFailureCopyWithImpl<PlayFailure>(this as PlayFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayFailure&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.retryAfterSeconds, _this.retryAfterSeconds) || other.retryAfterSeconds == _this.retryAfterSeconds));
}


@override
int get hashCode {
  final _this = this as PlayFailure;
  return Object.hash(runtimeType,_this.kind,_this.retryAfterSeconds);
}

@override
String toString() {
  final _this = this as PlayFailure;
  return 'PlayFailure(kind: ${_this.kind}, retryAfterSeconds: ${_this.retryAfterSeconds})';
}


}

/// @nodoc
abstract mixin class $PlayFailureCopyWith<$Res>  {
  factory $PlayFailureCopyWith(PlayFailure value, $Res Function(PlayFailure) _then) = _$PlayFailureCopyWithImpl;
@useResult
$Res call({
 PlayFailureKind kind, int? retryAfterSeconds
});




}
/// @nodoc
class _$PlayFailureCopyWithImpl<$Res>
    implements $PlayFailureCopyWith<$Res> {
  _$PlayFailureCopyWithImpl(this._self, this._then);

  final PlayFailure _self;
  final $Res Function(PlayFailure) _then;

/// Create a copy of PlayFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? retryAfterSeconds = freezed,}) {
  return _then(PlayFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlayFailureKind,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayFailure].
extension PlayFailurePatterns on PlayFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayFailure value)  $default,){
final _that = this;
switch (_that) {
case _PlayFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayFailure value)?  $default,){
final _that = this;
switch (_that) {
case _PlayFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayFailureKind kind,  int? retryAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayFailure() when $default != null:
return $default(_that.kind,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayFailureKind kind,  int? retryAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _PlayFailure():
return $default(_that.kind,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayFailureKind kind,  int? retryAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _PlayFailure() when $default != null:
return $default(_that.kind,_that.retryAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _PlayFailure implements PlayFailure {
  const _PlayFailure(this.kind, {this.retryAfterSeconds});
  

@override final  PlayFailureKind kind;
@override final  int? retryAfterSeconds;

/// Create a copy of PlayFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayFailureCopyWith<_PlayFailure> get copyWith => __$PlayFailureCopyWithImpl<_PlayFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayFailure&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,retryAfterSeconds);
}

@override
String toString() {
    return 'PlayFailure(kind: $kind, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$PlayFailureCopyWith<$Res> implements $PlayFailureCopyWith<$Res> {
  factory _$PlayFailureCopyWith(_PlayFailure value, $Res Function(_PlayFailure) _then) = __$PlayFailureCopyWithImpl;
@override @useResult
$Res call({
 PlayFailureKind kind, int? retryAfterSeconds
});




}
/// @nodoc
class __$PlayFailureCopyWithImpl<$Res>
    implements _$PlayFailureCopyWith<$Res> {
  __$PlayFailureCopyWithImpl(this._self, this._then);

  final _PlayFailure _self;
  final $Res Function(_PlayFailure) _then;

/// Create a copy of PlayFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? retryAfterSeconds = freezed,}) {
  return _then(_PlayFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlayFailureKind,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
