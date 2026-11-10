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
mixin _$AssetFailure {

 AssetFailureKind get kind;
/// Create a copy of AssetFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetFailureCopyWith<AssetFailure> get copyWith => _$AssetFailureCopyWithImpl<AssetFailure>(this as AssetFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssetFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetFailure&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}


@override
int get hashCode {
  final _this = this as AssetFailure;
  return Object.hash(runtimeType,_this.kind);
}

@override
String toString() {
  final _this = this as AssetFailure;
  return 'AssetFailure(kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $AssetFailureCopyWith<$Res>  {
  factory $AssetFailureCopyWith(AssetFailure value, $Res Function(AssetFailure) _then) = _$AssetFailureCopyWithImpl;
@useResult
$Res call({
 AssetFailureKind kind
});




}
/// @nodoc
class _$AssetFailureCopyWithImpl<$Res>
    implements $AssetFailureCopyWith<$Res> {
  _$AssetFailureCopyWithImpl(this._self, this._then);

  final AssetFailure _self;
  final $Res Function(AssetFailure) _then;

/// Create a copy of AssetFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,}) {
  return _then(AssetFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AssetFailureKind,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetFailure].
extension AssetFailurePatterns on AssetFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetFailure value)  $default,){
final _that = this;
switch (_that) {
case _AssetFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetFailure value)?  $default,){
final _that = this;
switch (_that) {
case _AssetFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AssetFailureKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetFailure() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AssetFailureKind kind)  $default,) {final _that = this;
switch (_that) {
case _AssetFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AssetFailureKind kind)?  $default,) {final _that = this;
switch (_that) {
case _AssetFailure() when $default != null:
return $default(_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _AssetFailure implements AssetFailure {
  const _AssetFailure(this.kind);
  

@override final  AssetFailureKind kind;

/// Create a copy of AssetFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetFailureCopyWith<_AssetFailure> get copyWith => __$AssetFailureCopyWithImpl<_AssetFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetFailure&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind);
}

@override
String toString() {
    return 'AssetFailure(kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$AssetFailureCopyWith<$Res> implements $AssetFailureCopyWith<$Res> {
  factory _$AssetFailureCopyWith(_AssetFailure value, $Res Function(_AssetFailure) _then) = __$AssetFailureCopyWithImpl;
@override @useResult
$Res call({
 AssetFailureKind kind
});




}
/// @nodoc
class __$AssetFailureCopyWithImpl<$Res>
    implements _$AssetFailureCopyWith<$Res> {
  __$AssetFailureCopyWithImpl(this._self, this._then);

  final _AssetFailure _self;
  final $Res Function(_AssetFailure) _then;

/// Create a copy of AssetFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(_AssetFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AssetFailureKind,
  ));
}


}

/// @nodoc
mixin _$AssetProgress {

 int get received; int get total;
/// Create a copy of AssetProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetProgressCopyWith<AssetProgress> get copyWith => _$AssetProgressCopyWithImpl<AssetProgress>(this as AssetProgress, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssetProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetProgress&&(identical(other.received, _this.received) || other.received == _this.received)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as AssetProgress;
  return Object.hash(runtimeType,_this.received,_this.total);
}

@override
String toString() {
  final _this = this as AssetProgress;
  return 'AssetProgress(received: ${_this.received}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $AssetProgressCopyWith<$Res>  {
  factory $AssetProgressCopyWith(AssetProgress value, $Res Function(AssetProgress) _then) = _$AssetProgressCopyWithImpl;
@useResult
$Res call({
 int received, int total
});




}
/// @nodoc
class _$AssetProgressCopyWithImpl<$Res>
    implements $AssetProgressCopyWith<$Res> {
  _$AssetProgressCopyWithImpl(this._self, this._then);

  final AssetProgress _self;
  final $Res Function(AssetProgress) _then;

/// Create a copy of AssetProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? received = null,Object? total = null,}) {
  return _then(AssetProgress(
received: null == received ? _self.received : received // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetProgress].
extension AssetProgressPatterns on AssetProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetProgress value)  $default,){
final _that = this;
switch (_that) {
case _AssetProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetProgress value)?  $default,){
final _that = this;
switch (_that) {
case _AssetProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int received,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetProgress() when $default != null:
return $default(_that.received,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int received,  int total)  $default,) {final _that = this;
switch (_that) {
case _AssetProgress():
return $default(_that.received,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int received,  int total)?  $default,) {final _that = this;
switch (_that) {
case _AssetProgress() when $default != null:
return $default(_that.received,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _AssetProgress implements AssetProgress {
  const _AssetProgress({required this.received, required this.total});
  

@override final  int received;
@override final  int total;

/// Create a copy of AssetProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetProgressCopyWith<_AssetProgress> get copyWith => __$AssetProgressCopyWithImpl<_AssetProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetProgress&&(identical(other.received, received) || other.received == received)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,received,total);
}

@override
String toString() {
    return 'AssetProgress(received: $received, total: $total)';
}


}

/// @nodoc
abstract mixin class _$AssetProgressCopyWith<$Res> implements $AssetProgressCopyWith<$Res> {
  factory _$AssetProgressCopyWith(_AssetProgress value, $Res Function(_AssetProgress) _then) = __$AssetProgressCopyWithImpl;
@override @useResult
$Res call({
 int received, int total
});




}
/// @nodoc
class __$AssetProgressCopyWithImpl<$Res>
    implements _$AssetProgressCopyWith<$Res> {
  __$AssetProgressCopyWithImpl(this._self, this._then);

  final _AssetProgress _self;
  final $Res Function(_AssetProgress) _then;

/// Create a copy of AssetProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? received = null,Object? total = null,}) {
  return _then(_AssetProgress(
received: null == received ? _self.received : received // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AssetCacheSettings {

 Uri get baseUrl; int get capacityBytes; Duration get connectTimeout; Duration get idleTimeout; Duration get totalTimeout;
/// Create a copy of AssetCacheSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetCacheSettingsCopyWith<AssetCacheSettings> get copyWith => _$AssetCacheSettingsCopyWithImpl<AssetCacheSettings>(this as AssetCacheSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssetCacheSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetCacheSettings&&(identical(other.baseUrl, _this.baseUrl) || other.baseUrl == _this.baseUrl)&&(identical(other.capacityBytes, _this.capacityBytes) || other.capacityBytes == _this.capacityBytes)&&(identical(other.connectTimeout, _this.connectTimeout) || other.connectTimeout == _this.connectTimeout)&&(identical(other.idleTimeout, _this.idleTimeout) || other.idleTimeout == _this.idleTimeout)&&(identical(other.totalTimeout, _this.totalTimeout) || other.totalTimeout == _this.totalTimeout));
}


@override
int get hashCode {
  final _this = this as AssetCacheSettings;
  return Object.hash(runtimeType,_this.baseUrl,_this.capacityBytes,_this.connectTimeout,_this.idleTimeout,_this.totalTimeout);
}

@override
String toString() {
  final _this = this as AssetCacheSettings;
  return 'AssetCacheSettings(baseUrl: ${_this.baseUrl}, capacityBytes: ${_this.capacityBytes}, connectTimeout: ${_this.connectTimeout}, idleTimeout: ${_this.idleTimeout}, totalTimeout: ${_this.totalTimeout})';
}


}

/// @nodoc
abstract mixin class $AssetCacheSettingsCopyWith<$Res>  {
  factory $AssetCacheSettingsCopyWith(AssetCacheSettings value, $Res Function(AssetCacheSettings) _then) = _$AssetCacheSettingsCopyWithImpl;
@useResult
$Res call({
 Uri baseUrl, int capacityBytes, Duration connectTimeout, Duration idleTimeout, Duration totalTimeout
});




}
/// @nodoc
class _$AssetCacheSettingsCopyWithImpl<$Res>
    implements $AssetCacheSettingsCopyWith<$Res> {
  _$AssetCacheSettingsCopyWithImpl(this._self, this._then);

  final AssetCacheSettings _self;
  final $Res Function(AssetCacheSettings) _then;

/// Create a copy of AssetCacheSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseUrl = null,Object? capacityBytes = null,Object? connectTimeout = null,Object? idleTimeout = null,Object? totalTimeout = null,}) {
  return _then(AssetCacheSettings(
baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as Uri,capacityBytes: null == capacityBytes ? _self.capacityBytes : capacityBytes // ignore: cast_nullable_to_non_nullable
as int,connectTimeout: null == connectTimeout ? _self.connectTimeout : connectTimeout // ignore: cast_nullable_to_non_nullable
as Duration,idleTimeout: null == idleTimeout ? _self.idleTimeout : idleTimeout // ignore: cast_nullable_to_non_nullable
as Duration,totalTimeout: null == totalTimeout ? _self.totalTimeout : totalTimeout // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetCacheSettings].
extension AssetCacheSettingsPatterns on AssetCacheSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetCacheSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetCacheSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetCacheSettings value)  $default,){
final _that = this;
switch (_that) {
case _AssetCacheSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetCacheSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AssetCacheSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri baseUrl,  int capacityBytes,  Duration connectTimeout,  Duration idleTimeout,  Duration totalTimeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetCacheSettings() when $default != null:
return $default(_that.baseUrl,_that.capacityBytes,_that.connectTimeout,_that.idleTimeout,_that.totalTimeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri baseUrl,  int capacityBytes,  Duration connectTimeout,  Duration idleTimeout,  Duration totalTimeout)  $default,) {final _that = this;
switch (_that) {
case _AssetCacheSettings():
return $default(_that.baseUrl,_that.capacityBytes,_that.connectTimeout,_that.idleTimeout,_that.totalTimeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri baseUrl,  int capacityBytes,  Duration connectTimeout,  Duration idleTimeout,  Duration totalTimeout)?  $default,) {final _that = this;
switch (_that) {
case _AssetCacheSettings() when $default != null:
return $default(_that.baseUrl,_that.capacityBytes,_that.connectTimeout,_that.idleTimeout,_that.totalTimeout);case _:
  return null;

}
}

}

/// @nodoc


class _AssetCacheSettings implements AssetCacheSettings {
  const _AssetCacheSettings({required this.baseUrl, this.capacityBytes = 100 * 1024 * 1024, this.connectTimeout = const Duration(seconds: 10), this.idleTimeout = const Duration(seconds: 15), this.totalTimeout = const Duration(seconds: 120)});
  

@override final  Uri baseUrl;
@override@JsonKey() final  int capacityBytes;
@override@JsonKey() final  Duration connectTimeout;
@override@JsonKey() final  Duration idleTimeout;
@override@JsonKey() final  Duration totalTimeout;

/// Create a copy of AssetCacheSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetCacheSettingsCopyWith<_AssetCacheSettings> get copyWith => __$AssetCacheSettingsCopyWithImpl<_AssetCacheSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetCacheSettings&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.capacityBytes, capacityBytes) || other.capacityBytes == capacityBytes)&&(identical(other.connectTimeout, connectTimeout) || other.connectTimeout == connectTimeout)&&(identical(other.idleTimeout, idleTimeout) || other.idleTimeout == idleTimeout)&&(identical(other.totalTimeout, totalTimeout) || other.totalTimeout == totalTimeout));
}


@override
int get hashCode {
    return Object.hash(runtimeType,baseUrl,capacityBytes,connectTimeout,idleTimeout,totalTimeout);
}

@override
String toString() {
    return 'AssetCacheSettings(baseUrl: $baseUrl, capacityBytes: $capacityBytes, connectTimeout: $connectTimeout, idleTimeout: $idleTimeout, totalTimeout: $totalTimeout)';
}


}

/// @nodoc
abstract mixin class _$AssetCacheSettingsCopyWith<$Res> implements $AssetCacheSettingsCopyWith<$Res> {
  factory _$AssetCacheSettingsCopyWith(_AssetCacheSettings value, $Res Function(_AssetCacheSettings) _then) = __$AssetCacheSettingsCopyWithImpl;
@override @useResult
$Res call({
 Uri baseUrl, int capacityBytes, Duration connectTimeout, Duration idleTimeout, Duration totalTimeout
});




}
/// @nodoc
class __$AssetCacheSettingsCopyWithImpl<$Res>
    implements _$AssetCacheSettingsCopyWith<$Res> {
  __$AssetCacheSettingsCopyWithImpl(this._self, this._then);

  final _AssetCacheSettings _self;
  final $Res Function(_AssetCacheSettings) _then;

/// Create a copy of AssetCacheSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseUrl = null,Object? capacityBytes = null,Object? connectTimeout = null,Object? idleTimeout = null,Object? totalTimeout = null,}) {
  return _then(_AssetCacheSettings(
baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as Uri,capacityBytes: null == capacityBytes ? _self.capacityBytes : capacityBytes // ignore: cast_nullable_to_non_nullable
as int,connectTimeout: null == connectTimeout ? _self.connectTimeout : connectTimeout // ignore: cast_nullable_to_non_nullable
as Duration,idleTimeout: null == idleTimeout ? _self.idleTimeout : idleTimeout // ignore: cast_nullable_to_non_nullable
as Duration,totalTimeout: null == totalTimeout ? _self.totalTimeout : totalTimeout // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
