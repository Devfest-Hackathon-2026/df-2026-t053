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
mixin _$ProfileFailure {

 ProfileFailureKind get kind; String? get nicknameReason;
/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFailureCopyWith<ProfileFailure> get copyWith => _$ProfileFailureCopyWithImpl<ProfileFailure>(this as ProfileFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfileFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFailure&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.nicknameReason, _this.nicknameReason) || other.nicknameReason == _this.nicknameReason));
}


@override
int get hashCode {
  final _this = this as ProfileFailure;
  return Object.hash(runtimeType,_this.kind,_this.nicknameReason);
}

@override
String toString() {
  final _this = this as ProfileFailure;
  return 'ProfileFailure(kind: ${_this.kind}, nicknameReason: ${_this.nicknameReason})';
}


}

/// @nodoc
abstract mixin class $ProfileFailureCopyWith<$Res>  {
  factory $ProfileFailureCopyWith(ProfileFailure value, $Res Function(ProfileFailure) _then) = _$ProfileFailureCopyWithImpl;
@useResult
$Res call({
 ProfileFailureKind kind, String? nicknameReason
});




}
/// @nodoc
class _$ProfileFailureCopyWithImpl<$Res>
    implements $ProfileFailureCopyWith<$Res> {
  _$ProfileFailureCopyWithImpl(this._self, this._then);

  final ProfileFailure _self;
  final $Res Function(ProfileFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? nicknameReason = freezed,}) {
  return _then(ProfileFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ProfileFailureKind,nicknameReason: freezed == nicknameReason ? _self.nicknameReason : nicknameReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileFailure].
extension ProfileFailurePatterns on ProfileFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileFailure value)  $default,){
final _that = this;
switch (_that) {
case _ProfileFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileFailure value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileFailureKind kind,  String? nicknameReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileFailure() when $default != null:
return $default(_that.kind,_that.nicknameReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileFailureKind kind,  String? nicknameReason)  $default,) {final _that = this;
switch (_that) {
case _ProfileFailure():
return $default(_that.kind,_that.nicknameReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileFailureKind kind,  String? nicknameReason)?  $default,) {final _that = this;
switch (_that) {
case _ProfileFailure() when $default != null:
return $default(_that.kind,_that.nicknameReason);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileFailure implements ProfileFailure {
  const _ProfileFailure(this.kind, {this.nicknameReason});
  

@override final  ProfileFailureKind kind;
@override final  String? nicknameReason;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileFailureCopyWith<_ProfileFailure> get copyWith => __$ProfileFailureCopyWithImpl<_ProfileFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileFailure&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.nicknameReason, nicknameReason) || other.nicknameReason == nicknameReason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,nicknameReason);
}

@override
String toString() {
    return 'ProfileFailure(kind: $kind, nicknameReason: $nicknameReason)';
}


}

/// @nodoc
abstract mixin class _$ProfileFailureCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory _$ProfileFailureCopyWith(_ProfileFailure value, $Res Function(_ProfileFailure) _then) = __$ProfileFailureCopyWithImpl;
@override @useResult
$Res call({
 ProfileFailureKind kind, String? nicknameReason
});




}
/// @nodoc
class __$ProfileFailureCopyWithImpl<$Res>
    implements _$ProfileFailureCopyWith<$Res> {
  __$ProfileFailureCopyWithImpl(this._self, this._then);

  final _ProfileFailure _self;
  final $Res Function(_ProfileFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? nicknameReason = freezed,}) {
  return _then(_ProfileFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ProfileFailureKind,nicknameReason: freezed == nicknameReason ? _self.nicknameReason : nicknameReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
