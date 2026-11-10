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
mixin _$HealthFailure {

 HealthFailureKind get kind;
/// Create a copy of HealthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthFailureCopyWith<HealthFailure> get copyWith => _$HealthFailureCopyWithImpl<HealthFailure>(this as HealthFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthFailure&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}


@override
int get hashCode {
  final _this = this as HealthFailure;
  return Object.hash(runtimeType,_this.kind);
}

@override
String toString() {
  final _this = this as HealthFailure;
  return 'HealthFailure(kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $HealthFailureCopyWith<$Res>  {
  factory $HealthFailureCopyWith(HealthFailure value, $Res Function(HealthFailure) _then) = _$HealthFailureCopyWithImpl;
@useResult
$Res call({
 HealthFailureKind kind
});




}
/// @nodoc
class _$HealthFailureCopyWithImpl<$Res>
    implements $HealthFailureCopyWith<$Res> {
  _$HealthFailureCopyWithImpl(this._self, this._then);

  final HealthFailure _self;
  final $Res Function(HealthFailure) _then;

/// Create a copy of HealthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,}) {
  return _then(HealthFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HealthFailureKind,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthFailure].
extension HealthFailurePatterns on HealthFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthFailure value)  $default,){
final _that = this;
switch (_that) {
case _HealthFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthFailure value)?  $default,){
final _that = this;
switch (_that) {
case _HealthFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthFailureKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthFailure() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthFailureKind kind)  $default,) {final _that = this;
switch (_that) {
case _HealthFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthFailureKind kind)?  $default,) {final _that = this;
switch (_that) {
case _HealthFailure() when $default != null:
return $default(_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _HealthFailure implements HealthFailure {
  const _HealthFailure(this.kind);
  

@override final  HealthFailureKind kind;

/// Create a copy of HealthFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthFailureCopyWith<_HealthFailure> get copyWith => __$HealthFailureCopyWithImpl<_HealthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthFailure&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind);
}

@override
String toString() {
    return 'HealthFailure(kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$HealthFailureCopyWith<$Res> implements $HealthFailureCopyWith<$Res> {
  factory _$HealthFailureCopyWith(_HealthFailure value, $Res Function(_HealthFailure) _then) = __$HealthFailureCopyWithImpl;
@override @useResult
$Res call({
 HealthFailureKind kind
});




}
/// @nodoc
class __$HealthFailureCopyWithImpl<$Res>
    implements _$HealthFailureCopyWith<$Res> {
  __$HealthFailureCopyWithImpl(this._self, this._then);

  final _HealthFailure _self;
  final $Res Function(_HealthFailure) _then;

/// Create a copy of HealthFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(_HealthFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HealthFailureKind,
  ));
}


}

// dart format on
