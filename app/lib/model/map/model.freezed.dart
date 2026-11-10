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
mixin _$MapPinData {

 int get id; String get name; String? get sourceKey; double? get latitude; double? get longitude;
/// Create a copy of MapPinData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapPinDataCopyWith<MapPinData> get copyWith => _$MapPinDataCopyWithImpl<MapPinData>(this as MapPinData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapPinData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapPinData&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sourceKey, _this.sourceKey) || other.sourceKey == _this.sourceKey)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}


@override
int get hashCode {
  final _this = this as MapPinData;
  return Object.hash(runtimeType,_this.id,_this.name,_this.sourceKey,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as MapPinData;
  return 'MapPinData(id: ${_this.id}, name: ${_this.name}, sourceKey: ${_this.sourceKey}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $MapPinDataCopyWith<$Res>  {
  factory $MapPinDataCopyWith(MapPinData value, $Res Function(MapPinData) _then) = _$MapPinDataCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? sourceKey, double? latitude, double? longitude
});




}
/// @nodoc
class _$MapPinDataCopyWithImpl<$Res>
    implements $MapPinDataCopyWith<$Res> {
  _$MapPinDataCopyWithImpl(this._self, this._then);

  final MapPinData _self;
  final $Res Function(MapPinData) _then;

/// Create a copy of MapPinData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sourceKey = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(MapPinData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [MapPinData].
extension MapPinDataPatterns on MapPinData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapPinData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapPinData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapPinData value)  $default,){
final _that = this;
switch (_that) {
case _MapPinData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapPinData value)?  $default,){
final _that = this;
switch (_that) {
case _MapPinData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? sourceKey,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapPinData() when $default != null:
return $default(_that.id,_that.name,_that.sourceKey,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? sourceKey,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _MapPinData():
return $default(_that.id,_that.name,_that.sourceKey,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? sourceKey,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _MapPinData() when $default != null:
return $default(_that.id,_that.name,_that.sourceKey,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc


class _MapPinData extends MapPinData {
  const _MapPinData({required this.id, required this.name, this.sourceKey, this.latitude, this.longitude}): super._();
  

@override final  int id;
@override final  String name;
@override final  String? sourceKey;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of MapPinData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapPinDataCopyWith<_MapPinData> get copyWith => __$MapPinDataCopyWithImpl<_MapPinData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapPinData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sourceKey, sourceKey) || other.sourceKey == sourceKey)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,sourceKey,latitude,longitude);
}

@override
String toString() {
    return 'MapPinData(id: $id, name: $name, sourceKey: $sourceKey, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$MapPinDataCopyWith<$Res> implements $MapPinDataCopyWith<$Res> {
  factory _$MapPinDataCopyWith(_MapPinData value, $Res Function(_MapPinData) _then) = __$MapPinDataCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? sourceKey, double? latitude, double? longitude
});




}
/// @nodoc
class __$MapPinDataCopyWithImpl<$Res>
    implements _$MapPinDataCopyWith<$Res> {
  __$MapPinDataCopyWithImpl(this._self, this._then);

  final _MapPinData _self;
  final $Res Function(_MapPinData) _then;

/// Create a copy of MapPinData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sourceKey = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_MapPinData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
