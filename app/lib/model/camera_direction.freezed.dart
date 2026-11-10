// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_direction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraDirection {

 double get n; double get e; double get w; double get s;
/// Create a copy of CameraDirection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraDirectionCopyWith<CameraDirection> get copyWith => _$CameraDirectionCopyWithImpl<CameraDirection>(this as CameraDirection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraDirection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraDirection&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.e, _this.e) || other.e == _this.e)&&(identical(other.w, _this.w) || other.w == _this.w)&&(identical(other.s, _this.s) || other.s == _this.s));
}


@override
int get hashCode {
  final _this = this as CameraDirection;
  return Object.hash(runtimeType,_this.n,_this.e,_this.w,_this.s);
}

@override
String toString() {
  final _this = this as CameraDirection;
  return 'CameraDirection(n: ${_this.n}, e: ${_this.e}, w: ${_this.w}, s: ${_this.s})';
}


}

/// @nodoc
abstract mixin class $CameraDirectionCopyWith<$Res>  {
  factory $CameraDirectionCopyWith(CameraDirection value, $Res Function(CameraDirection) _then) = _$CameraDirectionCopyWithImpl;
@useResult
$Res call({
 double n, double e, double w, double s
});




}
/// @nodoc
class _$CameraDirectionCopyWithImpl<$Res>
    implements $CameraDirectionCopyWith<$Res> {
  _$CameraDirectionCopyWithImpl(this._self, this._then);

  final CameraDirection _self;
  final $Res Function(CameraDirection) _then;

/// Create a copy of CameraDirection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = null,Object? e = null,Object? w = null,Object? s = null,}) {
  return _then(CameraDirection(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as double,e: null == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as double,w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as double,s: null == s ? _self.s : s // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraDirection].
extension CameraDirectionPatterns on CameraDirection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraDirection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraDirection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraDirection value)  $default,){
final _that = this;
switch (_that) {
case _CameraDirection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraDirection value)?  $default,){
final _that = this;
switch (_that) {
case _CameraDirection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double n,  double e,  double w,  double s)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraDirection() when $default != null:
return $default(_that.n,_that.e,_that.w,_that.s);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double n,  double e,  double w,  double s)  $default,) {final _that = this;
switch (_that) {
case _CameraDirection():
return $default(_that.n,_that.e,_that.w,_that.s);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double n,  double e,  double w,  double s)?  $default,) {final _that = this;
switch (_that) {
case _CameraDirection() when $default != null:
return $default(_that.n,_that.e,_that.w,_that.s);case _:
  return null;

}
}

}

/// @nodoc


class _CameraDirection implements CameraDirection {
  const _CameraDirection({required this.n, required this.e, required this.w, required this.s});
  

@override final  double n;
@override final  double e;
@override final  double w;
@override final  double s;

/// Create a copy of CameraDirection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraDirectionCopyWith<_CameraDirection> get copyWith => __$CameraDirectionCopyWithImpl<_CameraDirection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraDirection&&(identical(other.n, n) || other.n == n)&&(identical(other.e, e) || other.e == e)&&(identical(other.w, w) || other.w == w)&&(identical(other.s, s) || other.s == s));
}


@override
int get hashCode {
    return Object.hash(runtimeType,n,e,w,s);
}

@override
String toString() {
    return 'CameraDirection(n: $n, e: $e, w: $w, s: $s)';
}


}

/// @nodoc
abstract mixin class _$CameraDirectionCopyWith<$Res> implements $CameraDirectionCopyWith<$Res> {
  factory _$CameraDirectionCopyWith(_CameraDirection value, $Res Function(_CameraDirection) _then) = __$CameraDirectionCopyWithImpl;
@override @useResult
$Res call({
 double n, double e, double w, double s
});




}
/// @nodoc
class __$CameraDirectionCopyWithImpl<$Res>
    implements _$CameraDirectionCopyWith<$Res> {
  __$CameraDirectionCopyWithImpl(this._self, this._then);

  final _CameraDirection _self;
  final $Res Function(_CameraDirection) _then;

/// Create a copy of CameraDirection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = null,Object? e = null,Object? w = null,Object? s = null,}) {
  return _then(_CameraDirection(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as double,e: null == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as double,w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as double,s: null == s ? _self.s : s // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
