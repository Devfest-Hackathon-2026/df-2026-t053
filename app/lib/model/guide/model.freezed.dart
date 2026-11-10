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
mixin _$GuideState {

 GuideText? get text; GuidePhase get phase; GuideFailure? get failure;/// GUIDE_RATE_LIMITED で、再生成できるまでの秒数（サーバーの retryAfterSeconds）。
/// 待っている間だけ値を持ち、待ち時間が過ぎたら null に戻す。
 int? get retryAfterSeconds;
/// Create a copy of GuideState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideStateCopyWith<GuideState> get copyWith => _$GuideStateCopyWithImpl<GuideState>(this as GuideState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GuideState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideState&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.retryAfterSeconds, _this.retryAfterSeconds) || other.retryAfterSeconds == _this.retryAfterSeconds));
}


@override
int get hashCode {
  final _this = this as GuideState;
  return Object.hash(runtimeType,_this.text,_this.phase,_this.failure,_this.retryAfterSeconds);
}

@override
String toString() {
  final _this = this as GuideState;
  return 'GuideState(text: ${_this.text}, phase: ${_this.phase}, failure: ${_this.failure}, retryAfterSeconds: ${_this.retryAfterSeconds})';
}


}

/// @nodoc
abstract mixin class $GuideStateCopyWith<$Res>  {
  factory $GuideStateCopyWith(GuideState value, $Res Function(GuideState) _then) = _$GuideStateCopyWithImpl;
@useResult
$Res call({
 GuideText? text, GuidePhase phase, GuideFailure? failure, int? retryAfterSeconds
});




}
/// @nodoc
class _$GuideStateCopyWithImpl<$Res>
    implements $GuideStateCopyWith<$Res> {
  _$GuideStateCopyWithImpl(this._self, this._then);

  final GuideState _self;
  final $Res Function(GuideState) _then;

/// Create a copy of GuideState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? phase = null,Object? failure = freezed,Object? retryAfterSeconds = freezed,}) {
  return _then(GuideState(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as GuideText?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as GuidePhase,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as GuideFailure?,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideState].
extension GuideStatePatterns on GuideState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideState value)  $default,){
final _that = this;
switch (_that) {
case _GuideState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideState value)?  $default,){
final _that = this;
switch (_that) {
case _GuideState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GuideText? text,  GuidePhase phase,  GuideFailure? failure,  int? retryAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideState() when $default != null:
return $default(_that.text,_that.phase,_that.failure,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GuideText? text,  GuidePhase phase,  GuideFailure? failure,  int? retryAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _GuideState():
return $default(_that.text,_that.phase,_that.failure,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GuideText? text,  GuidePhase phase,  GuideFailure? failure,  int? retryAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _GuideState() when $default != null:
return $default(_that.text,_that.phase,_that.failure,_that.retryAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _GuideState implements GuideState {
  const _GuideState({this.text, this.phase = GuidePhase.idle, this.failure, this.retryAfterSeconds});
  

@override final  GuideText? text;
@override@JsonKey() final  GuidePhase phase;
@override final  GuideFailure? failure;
/// GUIDE_RATE_LIMITED で、再生成できるまでの秒数（サーバーの retryAfterSeconds）。
/// 待っている間だけ値を持ち、待ち時間が過ぎたら null に戻す。
@override final  int? retryAfterSeconds;

/// Create a copy of GuideState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideStateCopyWith<_GuideState> get copyWith => __$GuideStateCopyWithImpl<_GuideState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideState&&(identical(other.text, text) || other.text == text)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,phase,failure,retryAfterSeconds);
}

@override
String toString() {
    return 'GuideState(text: $text, phase: $phase, failure: $failure, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$GuideStateCopyWith<$Res> implements $GuideStateCopyWith<$Res> {
  factory _$GuideStateCopyWith(_GuideState value, $Res Function(_GuideState) _then) = __$GuideStateCopyWithImpl;
@override @useResult
$Res call({
 GuideText? text, GuidePhase phase, GuideFailure? failure, int? retryAfterSeconds
});




}
/// @nodoc
class __$GuideStateCopyWithImpl<$Res>
    implements _$GuideStateCopyWith<$Res> {
  __$GuideStateCopyWithImpl(this._self, this._then);

  final _GuideState _self;
  final $Res Function(_GuideState) _then;

/// Create a copy of GuideState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? phase = null,Object? failure = freezed,Object? retryAfterSeconds = freezed,}) {
  return _then(_GuideState(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as GuideText?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as GuidePhase,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as GuideFailure?,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
