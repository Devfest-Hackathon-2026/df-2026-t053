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
mixin _$RankingFailure {

 RankingFailureKind get kind;
/// Create a copy of RankingFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankingFailureCopyWith<RankingFailure> get copyWith => _$RankingFailureCopyWithImpl<RankingFailure>(this as RankingFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RankingFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankingFailure&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}


@override
int get hashCode {
  final _this = this as RankingFailure;
  return Object.hash(runtimeType,_this.kind);
}

@override
String toString() {
  final _this = this as RankingFailure;
  return 'RankingFailure(kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $RankingFailureCopyWith<$Res>  {
  factory $RankingFailureCopyWith(RankingFailure value, $Res Function(RankingFailure) _then) = _$RankingFailureCopyWithImpl;
@useResult
$Res call({
 RankingFailureKind kind
});




}
/// @nodoc
class _$RankingFailureCopyWithImpl<$Res>
    implements $RankingFailureCopyWith<$Res> {
  _$RankingFailureCopyWithImpl(this._self, this._then);

  final RankingFailure _self;
  final $Res Function(RankingFailure) _then;

/// Create a copy of RankingFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,}) {
  return _then(RankingFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RankingFailureKind,
  ));
}

}


/// Adds pattern-matching-related methods to [RankingFailure].
extension RankingFailurePatterns on RankingFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankingFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankingFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankingFailure value)  $default,){
final _that = this;
switch (_that) {
case _RankingFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankingFailure value)?  $default,){
final _that = this;
switch (_that) {
case _RankingFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RankingFailureKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankingFailure() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RankingFailureKind kind)  $default,) {final _that = this;
switch (_that) {
case _RankingFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RankingFailureKind kind)?  $default,) {final _that = this;
switch (_that) {
case _RankingFailure() when $default != null:
return $default(_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _RankingFailure implements RankingFailure {
  const _RankingFailure(this.kind);
  

@override final  RankingFailureKind kind;

/// Create a copy of RankingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankingFailureCopyWith<_RankingFailure> get copyWith => __$RankingFailureCopyWithImpl<_RankingFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankingFailure&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind);
}

@override
String toString() {
    return 'RankingFailure(kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$RankingFailureCopyWith<$Res> implements $RankingFailureCopyWith<$Res> {
  factory _$RankingFailureCopyWith(_RankingFailure value, $Res Function(_RankingFailure) _then) = __$RankingFailureCopyWithImpl;
@override @useResult
$Res call({
 RankingFailureKind kind
});




}
/// @nodoc
class __$RankingFailureCopyWithImpl<$Res>
    implements _$RankingFailureCopyWith<$Res> {
  __$RankingFailureCopyWithImpl(this._self, this._then);

  final _RankingFailure _self;
  final $Res Function(_RankingFailure) _then;

/// Create a copy of RankingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(_RankingFailure(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RankingFailureKind,
  ));
}


}

/// @nodoc
mixin _$RankingState {

 ExplorationMode get mode; int? get revisionId; String get challengeTitle; bool get isLoading; bool get noPublishedChallenge; List<RankingEntry> get entries; RankingEntry? get myEntry; DateTime? get fetchedAt; String? get errorMessage;
/// Create a copy of RankingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankingStateCopyWith<RankingState> get copyWith => _$RankingStateCopyWithImpl<RankingState>(this as RankingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RankingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankingState&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.revisionId, _this.revisionId) || other.revisionId == _this.revisionId)&&(identical(other.challengeTitle, _this.challengeTitle) || other.challengeTitle == _this.challengeTitle)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.noPublishedChallenge, _this.noPublishedChallenge) || other.noPublishedChallenge == _this.noPublishedChallenge)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.myEntry, _this.myEntry) || other.myEntry == _this.myEntry)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as RankingState;
  return Object.hash(runtimeType,_this.mode,_this.revisionId,_this.challengeTitle,_this.isLoading,_this.noPublishedChallenge,const DeepCollectionEquality().hash(_this.entries),_this.myEntry,_this.fetchedAt,_this.errorMessage);
}

@override
String toString() {
  final _this = this as RankingState;
  return 'RankingState(mode: ${_this.mode}, revisionId: ${_this.revisionId}, challengeTitle: ${_this.challengeTitle}, isLoading: ${_this.isLoading}, noPublishedChallenge: ${_this.noPublishedChallenge}, entries: ${_this.entries}, myEntry: ${_this.myEntry}, fetchedAt: ${_this.fetchedAt}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $RankingStateCopyWith<$Res>  {
  factory $RankingStateCopyWith(RankingState value, $Res Function(RankingState) _then) = _$RankingStateCopyWithImpl;
@useResult
$Res call({
 ExplorationMode mode, int? revisionId, String challengeTitle, bool isLoading, bool noPublishedChallenge, List<RankingEntry> entries, RankingEntry? myEntry, DateTime? fetchedAt, String? errorMessage
});




}
/// @nodoc
class _$RankingStateCopyWithImpl<$Res>
    implements $RankingStateCopyWith<$Res> {
  _$RankingStateCopyWithImpl(this._self, this._then);

  final RankingState _self;
  final $Res Function(RankingState) _then;

/// Create a copy of RankingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? revisionId = freezed,Object? challengeTitle = null,Object? isLoading = null,Object? noPublishedChallenge = null,Object? entries = null,Object? myEntry = freezed,Object? fetchedAt = freezed,Object? errorMessage = freezed,}) {
  return _then(RankingState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,revisionId: freezed == revisionId ? _self.revisionId : revisionId // ignore: cast_nullable_to_non_nullable
as int?,challengeTitle: null == challengeTitle ? _self.challengeTitle : challengeTitle // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,noPublishedChallenge: null == noPublishedChallenge ? _self.noPublishedChallenge : noPublishedChallenge // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<RankingEntry>,myEntry: freezed == myEntry ? _self.myEntry : myEntry // ignore: cast_nullable_to_non_nullable
as RankingEntry?,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RankingState].
extension RankingStatePatterns on RankingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankingState value)  $default,){
final _that = this;
switch (_that) {
case _RankingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankingState value)?  $default,){
final _that = this;
switch (_that) {
case _RankingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExplorationMode mode,  int? revisionId,  String challengeTitle,  bool isLoading,  bool noPublishedChallenge,  List<RankingEntry> entries,  RankingEntry? myEntry,  DateTime? fetchedAt,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankingState() when $default != null:
return $default(_that.mode,_that.revisionId,_that.challengeTitle,_that.isLoading,_that.noPublishedChallenge,_that.entries,_that.myEntry,_that.fetchedAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExplorationMode mode,  int? revisionId,  String challengeTitle,  bool isLoading,  bool noPublishedChallenge,  List<RankingEntry> entries,  RankingEntry? myEntry,  DateTime? fetchedAt,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _RankingState():
return $default(_that.mode,_that.revisionId,_that.challengeTitle,_that.isLoading,_that.noPublishedChallenge,_that.entries,_that.myEntry,_that.fetchedAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExplorationMode mode,  int? revisionId,  String challengeTitle,  bool isLoading,  bool noPublishedChallenge,  List<RankingEntry> entries,  RankingEntry? myEntry,  DateTime? fetchedAt,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RankingState() when $default != null:
return $default(_that.mode,_that.revisionId,_that.challengeTitle,_that.isLoading,_that.noPublishedChallenge,_that.entries,_that.myEntry,_that.fetchedAt,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RankingState implements RankingState {
  const _RankingState({required this.mode, this.revisionId, this.challengeTitle = '', this.isLoading = true, this.noPublishedChallenge = false,  List<RankingEntry> entries = const <RankingEntry>[], this.myEntry, this.fetchedAt, this.errorMessage}): _entries = entries;
  

@override final  ExplorationMode mode;
@override final  int? revisionId;
@override@JsonKey() final  String challengeTitle;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool noPublishedChallenge;
 final  List<RankingEntry> _entries;
@override@JsonKey() List<RankingEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  RankingEntry? myEntry;
@override final  DateTime? fetchedAt;
@override final  String? errorMessage;

/// Create a copy of RankingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankingStateCopyWith<_RankingState> get copyWith => __$RankingStateCopyWithImpl<_RankingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankingState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.revisionId, revisionId) || other.revisionId == revisionId)&&(identical(other.challengeTitle, challengeTitle) || other.challengeTitle == challengeTitle)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.noPublishedChallenge, noPublishedChallenge) || other.noPublishedChallenge == noPublishedChallenge)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.myEntry, myEntry) || other.myEntry == myEntry)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,revisionId,challengeTitle,isLoading,noPublishedChallenge,const DeepCollectionEquality().hash(_entries),myEntry,fetchedAt,errorMessage);
}

@override
String toString() {
    return 'RankingState(mode: $mode, revisionId: $revisionId, challengeTitle: $challengeTitle, isLoading: $isLoading, noPublishedChallenge: $noPublishedChallenge, entries: $entries, myEntry: $myEntry, fetchedAt: $fetchedAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$RankingStateCopyWith<$Res> implements $RankingStateCopyWith<$Res> {
  factory _$RankingStateCopyWith(_RankingState value, $Res Function(_RankingState) _then) = __$RankingStateCopyWithImpl;
@override @useResult
$Res call({
 ExplorationMode mode, int? revisionId, String challengeTitle, bool isLoading, bool noPublishedChallenge, List<RankingEntry> entries, RankingEntry? myEntry, DateTime? fetchedAt, String? errorMessage
});




}
/// @nodoc
class __$RankingStateCopyWithImpl<$Res>
    implements _$RankingStateCopyWith<$Res> {
  __$RankingStateCopyWithImpl(this._self, this._then);

  final _RankingState _self;
  final $Res Function(_RankingState) _then;

/// Create a copy of RankingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? revisionId = freezed,Object? challengeTitle = null,Object? isLoading = null,Object? noPublishedChallenge = null,Object? entries = null,Object? myEntry = freezed,Object? fetchedAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_RankingState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,revisionId: freezed == revisionId ? _self.revisionId : revisionId // ignore: cast_nullable_to_non_nullable
as int?,challengeTitle: null == challengeTitle ? _self.challengeTitle : challengeTitle // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,noPublishedChallenge: null == noPublishedChallenge ? _self.noPublishedChallenge : noPublishedChallenge // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<RankingEntry>,myEntry: freezed == myEntry ? _self.myEntry : myEntry // ignore: cast_nullable_to_non_nullable
as RankingEntry?,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
