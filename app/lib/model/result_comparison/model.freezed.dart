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
mixin _$ResultComparisonImages {

 ui.Image get shot; ui.Image get goal;
/// Create a copy of ResultComparisonImages
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultComparisonImagesCopyWith<ResultComparisonImages> get copyWith => _$ResultComparisonImagesCopyWithImpl<ResultComparisonImages>(this as ResultComparisonImages, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ResultComparisonImages;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultComparisonImages&&(identical(other.shot, _this.shot) || other.shot == _this.shot)&&(identical(other.goal, _this.goal) || other.goal == _this.goal));
}


@override
int get hashCode {
  final _this = this as ResultComparisonImages;
  return Object.hash(runtimeType,_this.shot,_this.goal);
}

@override
String toString() {
  final _this = this as ResultComparisonImages;
  return 'ResultComparisonImages(shot: ${_this.shot}, goal: ${_this.goal})';
}


}

/// @nodoc
abstract mixin class $ResultComparisonImagesCopyWith<$Res>  {
  factory $ResultComparisonImagesCopyWith(ResultComparisonImages value, $Res Function(ResultComparisonImages) _then) = _$ResultComparisonImagesCopyWithImpl;
@useResult
$Res call({
 ui.Image shot, ui.Image goal
});




}
/// @nodoc
class _$ResultComparisonImagesCopyWithImpl<$Res>
    implements $ResultComparisonImagesCopyWith<$Res> {
  _$ResultComparisonImagesCopyWithImpl(this._self, this._then);

  final ResultComparisonImages _self;
  final $Res Function(ResultComparisonImages) _then;

/// Create a copy of ResultComparisonImages
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shot = null,Object? goal = null,}) {
  return _then(ResultComparisonImages(
shot: null == shot ? _self.shot : shot // ignore: cast_nullable_to_non_nullable
as ui.Image,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as ui.Image,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultComparisonImages].
extension ResultComparisonImagesPatterns on ResultComparisonImages {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultComparisonImages value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultComparisonImages() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultComparisonImages value)  $default,){
final _that = this;
switch (_that) {
case _ResultComparisonImages():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultComparisonImages value)?  $default,){
final _that = this;
switch (_that) {
case _ResultComparisonImages() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ui.Image shot,  ui.Image goal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultComparisonImages() when $default != null:
return $default(_that.shot,_that.goal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ui.Image shot,  ui.Image goal)  $default,) {final _that = this;
switch (_that) {
case _ResultComparisonImages():
return $default(_that.shot,_that.goal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ui.Image shot,  ui.Image goal)?  $default,) {final _that = this;
switch (_that) {
case _ResultComparisonImages() when $default != null:
return $default(_that.shot,_that.goal);case _:
  return null;

}
}

}

/// @nodoc


class _ResultComparisonImages implements ResultComparisonImages {
  const _ResultComparisonImages({required this.shot, required this.goal});
  

@override final  ui.Image shot;
@override final  ui.Image goal;

/// Create a copy of ResultComparisonImages
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultComparisonImagesCopyWith<_ResultComparisonImages> get copyWith => __$ResultComparisonImagesCopyWithImpl<_ResultComparisonImages>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultComparisonImages&&(identical(other.shot, shot) || other.shot == shot)&&(identical(other.goal, goal) || other.goal == goal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,shot,goal);
}

@override
String toString() {
    return 'ResultComparisonImages(shot: $shot, goal: $goal)';
}


}

/// @nodoc
abstract mixin class _$ResultComparisonImagesCopyWith<$Res> implements $ResultComparisonImagesCopyWith<$Res> {
  factory _$ResultComparisonImagesCopyWith(_ResultComparisonImages value, $Res Function(_ResultComparisonImages) _then) = __$ResultComparisonImagesCopyWithImpl;
@override @useResult
$Res call({
 ui.Image shot, ui.Image goal
});




}
/// @nodoc
class __$ResultComparisonImagesCopyWithImpl<$Res>
    implements _$ResultComparisonImagesCopyWith<$Res> {
  __$ResultComparisonImagesCopyWithImpl(this._self, this._then);

  final _ResultComparisonImages _self;
  final $Res Function(_ResultComparisonImages) _then;

/// Create a copy of ResultComparisonImages
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shot = null,Object? goal = null,}) {
  return _then(_ResultComparisonImages(
shot: null == shot ? _self.shot : shot // ignore: cast_nullable_to_non_nullable
as ui.Image,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as ui.Image,
  ));
}


}

// dart format on
