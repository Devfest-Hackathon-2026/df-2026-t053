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
mixin _$CluePhotoState {

 CluePhotoPhase get phase; String? get alt; String? get path; int? get width; int? get height; double get progress; AssetFailureKind? get failure;
/// Create a copy of CluePhotoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CluePhotoStateCopyWith<CluePhotoState> get copyWith => _$CluePhotoStateCopyWithImpl<CluePhotoState>(this as CluePhotoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CluePhotoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CluePhotoState&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.alt, _this.alt) || other.alt == _this.alt)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as CluePhotoState;
  return Object.hash(runtimeType,_this.phase,_this.alt,_this.path,_this.width,_this.height,_this.progress,_this.failure);
}

@override
String toString() {
  final _this = this as CluePhotoState;
  return 'CluePhotoState(phase: ${_this.phase}, alt: ${_this.alt}, path: ${_this.path}, width: ${_this.width}, height: ${_this.height}, progress: ${_this.progress}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $CluePhotoStateCopyWith<$Res>  {
  factory $CluePhotoStateCopyWith(CluePhotoState value, $Res Function(CluePhotoState) _then) = _$CluePhotoStateCopyWithImpl;
@useResult
$Res call({
 CluePhotoPhase phase, String? alt, String? path, int? width, int? height, double progress, AssetFailureKind? failure
});




}
/// @nodoc
class _$CluePhotoStateCopyWithImpl<$Res>
    implements $CluePhotoStateCopyWith<$Res> {
  _$CluePhotoStateCopyWithImpl(this._self, this._then);

  final CluePhotoState _self;
  final $Res Function(CluePhotoState) _then;

/// Create a copy of CluePhotoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? alt = freezed,Object? path = freezed,Object? width = freezed,Object? height = freezed,Object? progress = null,Object? failure = freezed,}) {
  return _then(CluePhotoState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as CluePhotoPhase,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AssetFailureKind?,
  ));
}

}


/// Adds pattern-matching-related methods to [CluePhotoState].
extension CluePhotoStatePatterns on CluePhotoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CluePhotoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CluePhotoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CluePhotoState value)  $default,){
final _that = this;
switch (_that) {
case _CluePhotoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CluePhotoState value)?  $default,){
final _that = this;
switch (_that) {
case _CluePhotoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CluePhotoPhase phase,  String? alt,  String? path,  int? width,  int? height,  double progress,  AssetFailureKind? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CluePhotoState() when $default != null:
return $default(_that.phase,_that.alt,_that.path,_that.width,_that.height,_that.progress,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CluePhotoPhase phase,  String? alt,  String? path,  int? width,  int? height,  double progress,  AssetFailureKind? failure)  $default,) {final _that = this;
switch (_that) {
case _CluePhotoState():
return $default(_that.phase,_that.alt,_that.path,_that.width,_that.height,_that.progress,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CluePhotoPhase phase,  String? alt,  String? path,  int? width,  int? height,  double progress,  AssetFailureKind? failure)?  $default,) {final _that = this;
switch (_that) {
case _CluePhotoState() when $default != null:
return $default(_that.phase,_that.alt,_that.path,_that.width,_that.height,_that.progress,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _CluePhotoState implements CluePhotoState {
  const _CluePhotoState({this.phase = CluePhotoPhase.idle, this.alt, this.path, this.width, this.height, this.progress = 0, this.failure});
  

@override@JsonKey() final  CluePhotoPhase phase;
@override final  String? alt;
@override final  String? path;
@override final  int? width;
@override final  int? height;
@override@JsonKey() final  double progress;
@override final  AssetFailureKind? failure;

/// Create a copy of CluePhotoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CluePhotoStateCopyWith<_CluePhotoState> get copyWith => __$CluePhotoStateCopyWithImpl<_CluePhotoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CluePhotoState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.alt, alt) || other.alt == alt)&&(identical(other.path, path) || other.path == path)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,alt,path,width,height,progress,failure);
}

@override
String toString() {
    return 'CluePhotoState(phase: $phase, alt: $alt, path: $path, width: $width, height: $height, progress: $progress, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$CluePhotoStateCopyWith<$Res> implements $CluePhotoStateCopyWith<$Res> {
  factory _$CluePhotoStateCopyWith(_CluePhotoState value, $Res Function(_CluePhotoState) _then) = __$CluePhotoStateCopyWithImpl;
@override @useResult
$Res call({
 CluePhotoPhase phase, String? alt, String? path, int? width, int? height, double progress, AssetFailureKind? failure
});




}
/// @nodoc
class __$CluePhotoStateCopyWithImpl<$Res>
    implements _$CluePhotoStateCopyWith<$Res> {
  __$CluePhotoStateCopyWithImpl(this._self, this._then);

  final _CluePhotoState _self;
  final $Res Function(_CluePhotoState) _then;

/// Create a copy of CluePhotoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? alt = freezed,Object? path = freezed,Object? width = freezed,Object? height = freezed,Object? progress = null,Object? failure = freezed,}) {
  return _then(_CluePhotoState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as CluePhotoPhase,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AssetFailureKind?,
  ));
}


}

// dart format on
