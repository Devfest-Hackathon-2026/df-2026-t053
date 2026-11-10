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
mixin _$ChallengeState {

 int? get challengeId; ChallengeRevision? get revision;
/// Create a copy of ChallengeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallengeStateCopyWith<ChallengeState> get copyWith => _$ChallengeStateCopyWithImpl<ChallengeState>(this as ChallengeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChallengeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallengeState&&(identical(other.challengeId, _this.challengeId) || other.challengeId == _this.challengeId)&&(identical(other.revision, _this.revision) || other.revision == _this.revision));
}


@override
int get hashCode {
  final _this = this as ChallengeState;
  return Object.hash(runtimeType,_this.challengeId,_this.revision);
}

@override
String toString() {
  final _this = this as ChallengeState;
  return 'ChallengeState(challengeId: ${_this.challengeId}, revision: ${_this.revision})';
}


}

/// @nodoc
abstract mixin class $ChallengeStateCopyWith<$Res>  {
  factory $ChallengeStateCopyWith(ChallengeState value, $Res Function(ChallengeState) _then) = _$ChallengeStateCopyWithImpl;
@useResult
$Res call({
 int? challengeId, ChallengeRevision? revision
});




}
/// @nodoc
class _$ChallengeStateCopyWithImpl<$Res>
    implements $ChallengeStateCopyWith<$Res> {
  _$ChallengeStateCopyWithImpl(this._self, this._then);

  final ChallengeState _self;
  final $Res Function(ChallengeState) _then;

/// Create a copy of ChallengeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = freezed,Object? revision = freezed,}) {
  return _then(ChallengeState(
challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as int?,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as ChallengeRevision?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChallengeState].
extension ChallengeStatePatterns on ChallengeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallengeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallengeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallengeState value)  $default,){
final _that = this;
switch (_that) {
case _ChallengeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallengeState value)?  $default,){
final _that = this;
switch (_that) {
case _ChallengeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? challengeId,  ChallengeRevision? revision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallengeState() when $default != null:
return $default(_that.challengeId,_that.revision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? challengeId,  ChallengeRevision? revision)  $default,) {final _that = this;
switch (_that) {
case _ChallengeState():
return $default(_that.challengeId,_that.revision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? challengeId,  ChallengeRevision? revision)?  $default,) {final _that = this;
switch (_that) {
case _ChallengeState() when $default != null:
return $default(_that.challengeId,_that.revision);case _:
  return null;

}
}

}

/// @nodoc


class _ChallengeState implements ChallengeState {
  const _ChallengeState({this.challengeId, this.revision});
  

@override final  int? challengeId;
@override final  ChallengeRevision? revision;

/// Create a copy of ChallengeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallengeStateCopyWith<_ChallengeState> get copyWith => __$ChallengeStateCopyWithImpl<_ChallengeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallengeState&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.revision, revision) || other.revision == revision));
}


@override
int get hashCode {
    return Object.hash(runtimeType,challengeId,revision);
}

@override
String toString() {
    return 'ChallengeState(challengeId: $challengeId, revision: $revision)';
}


}

/// @nodoc
abstract mixin class _$ChallengeStateCopyWith<$Res> implements $ChallengeStateCopyWith<$Res> {
  factory _$ChallengeStateCopyWith(_ChallengeState value, $Res Function(_ChallengeState) _then) = __$ChallengeStateCopyWithImpl;
@override @useResult
$Res call({
 int? challengeId, ChallengeRevision? revision
});




}
/// @nodoc
class __$ChallengeStateCopyWithImpl<$Res>
    implements _$ChallengeStateCopyWith<$Res> {
  __$ChallengeStateCopyWithImpl(this._self, this._then);

  final _ChallengeState _self;
  final $Res Function(_ChallengeState) _then;

/// Create a copy of ChallengeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = freezed,Object? revision = freezed,}) {
  return _then(_ChallengeState(
challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as int?,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as ChallengeRevision?,
  ));
}


}

/// @nodoc
mixin _$ChallengeFailure {

 ChallengeFailureKind get kind;
/// Create a copy of ChallengeFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallengeFailureCopyWith<ChallengeFailure> get copyWith => _$ChallengeFailureCopyWithImpl<ChallengeFailure>(this as ChallengeFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChallengeFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallengeFailure&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}


@override
int get hashCode {
  final _this = this as ChallengeFailure;
  return Object.hash(runtimeType,_this.kind);
}

@override
String toString() {
  final _this = this as ChallengeFailure;
  return 'ChallengeFailure(kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $ChallengeFailureCopyWith<$Res>  {
  factory $ChallengeFailureCopyWith(ChallengeFailure value, $Res Function(ChallengeFailure) _then) = _$ChallengeFailureCopyWithImpl;
@useResult
$Res call({
 ChallengeFailureKind kind
});




}
/// @nodoc
class _$ChallengeFailureCopyWithImpl<$Res>
    implements $ChallengeFailureCopyWith<$Res> {
  _$ChallengeFailureCopyWithImpl(this._self, this._then);

  final ChallengeFailure _self;
  final $Res Function(ChallengeFailure) _then;

/// Create a copy of ChallengeFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,}) {
  return _then(ChallengeFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChallengeFailureKind,
  ));
}

}


/// Adds pattern-matching-related methods to [ChallengeFailure].
extension ChallengeFailurePatterns on ChallengeFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallengeFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallengeFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallengeFailure value)  $default,){
final _that = this;
switch (_that) {
case _ChallengeFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallengeFailure value)?  $default,){
final _that = this;
switch (_that) {
case _ChallengeFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChallengeFailureKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallengeFailure() when $default != null:
return $default(_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChallengeFailureKind kind)  $default,) {final _that = this;
switch (_that) {
case _ChallengeFailure():
return $default(_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChallengeFailureKind kind)?  $default,) {final _that = this;
switch (_that) {
case _ChallengeFailure() when $default != null:
return $default(_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _ChallengeFailure implements ChallengeFailure {
  const _ChallengeFailure(this.kind);
  

@override final  ChallengeFailureKind kind;

/// Create a copy of ChallengeFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallengeFailureCopyWith<_ChallengeFailure> get copyWith => __$ChallengeFailureCopyWithImpl<_ChallengeFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallengeFailure&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind);
}

@override
String toString() {
    return 'ChallengeFailure(kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$ChallengeFailureCopyWith<$Res> implements $ChallengeFailureCopyWith<$Res> {
  factory _$ChallengeFailureCopyWith(_ChallengeFailure value, $Res Function(_ChallengeFailure) _then) = __$ChallengeFailureCopyWithImpl;
@override @useResult
$Res call({
 ChallengeFailureKind kind
});




}
/// @nodoc
class __$ChallengeFailureCopyWithImpl<$Res>
    implements _$ChallengeFailureCopyWith<$Res> {
  __$ChallengeFailureCopyWithImpl(this._self, this._then);

  final _ChallengeFailure _self;
  final $Res Function(_ChallengeFailure) _then;

/// Create a copy of ChallengeFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(_ChallengeFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChallengeFailureKind,
  ));
}


}

// dart format on
