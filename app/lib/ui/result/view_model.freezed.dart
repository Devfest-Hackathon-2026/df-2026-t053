// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResultState {

 ExplorationMode get mode; int get score; int get maxScore; bool get isPersonalBest; double get distanceMeters; int get yawDegrees; int get pitchDegrees; int get rank; String get episode; String get highlight;
/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultStateCopyWith<ResultState> get copyWith => _$ResultStateCopyWithImpl<ResultState>(this as ResultState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ResultState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultState&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.maxScore, _this.maxScore) || other.maxScore == _this.maxScore)&&(identical(other.isPersonalBest, _this.isPersonalBest) || other.isPersonalBest == _this.isPersonalBest)&&(identical(other.distanceMeters, _this.distanceMeters) || other.distanceMeters == _this.distanceMeters)&&(identical(other.yawDegrees, _this.yawDegrees) || other.yawDegrees == _this.yawDegrees)&&(identical(other.pitchDegrees, _this.pitchDegrees) || other.pitchDegrees == _this.pitchDegrees)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.episode, _this.episode) || other.episode == _this.episode)&&(identical(other.highlight, _this.highlight) || other.highlight == _this.highlight));
}


@override
int get hashCode {
  final _this = this as ResultState;
  return Object.hash(runtimeType,_this.mode,_this.score,_this.maxScore,_this.isPersonalBest,_this.distanceMeters,_this.yawDegrees,_this.pitchDegrees,_this.rank,_this.episode,_this.highlight);
}

@override
String toString() {
  final _this = this as ResultState;
  return 'ResultState(mode: ${_this.mode}, score: ${_this.score}, maxScore: ${_this.maxScore}, isPersonalBest: ${_this.isPersonalBest}, distanceMeters: ${_this.distanceMeters}, yawDegrees: ${_this.yawDegrees}, pitchDegrees: ${_this.pitchDegrees}, rank: ${_this.rank}, episode: ${_this.episode}, highlight: ${_this.highlight})';
}


}

/// @nodoc
abstract mixin class $ResultStateCopyWith<$Res>  {
  factory $ResultStateCopyWith(ResultState value, $Res Function(ResultState) _then) = _$ResultStateCopyWithImpl;
@useResult
$Res call({
 ExplorationMode mode, int score, int maxScore, bool isPersonalBest, double distanceMeters, int yawDegrees, int pitchDegrees, int rank, String episode, String highlight
});




}
/// @nodoc
class _$ResultStateCopyWithImpl<$Res>
    implements $ResultStateCopyWith<$Res> {
  _$ResultStateCopyWithImpl(this._self, this._then);

  final ResultState _self;
  final $Res Function(ResultState) _then;

/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? score = null,Object? maxScore = null,Object? isPersonalBest = null,Object? distanceMeters = null,Object? yawDegrees = null,Object? pitchDegrees = null,Object? rank = null,Object? episode = null,Object? highlight = null,}) {
  return _then(ResultState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,maxScore: null == maxScore ? _self.maxScore : maxScore // ignore: cast_nullable_to_non_nullable
as int,isPersonalBest: null == isPersonalBest ? _self.isPersonalBest : isPersonalBest // ignore: cast_nullable_to_non_nullable
as bool,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,yawDegrees: null == yawDegrees ? _self.yawDegrees : yawDegrees // ignore: cast_nullable_to_non_nullable
as int,pitchDegrees: null == pitchDegrees ? _self.pitchDegrees : pitchDegrees // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as String,highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultState].
extension ResultStatePatterns on ResultState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultState value)  $default,){
final _that = this;
switch (_that) {
case _ResultState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultState value)?  $default,){
final _that = this;
switch (_that) {
case _ResultState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExplorationMode mode,  int score,  int maxScore,  bool isPersonalBest,  double distanceMeters,  int yawDegrees,  int pitchDegrees,  int rank,  String episode,  String highlight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultState() when $default != null:
return $default(_that.mode,_that.score,_that.maxScore,_that.isPersonalBest,_that.distanceMeters,_that.yawDegrees,_that.pitchDegrees,_that.rank,_that.episode,_that.highlight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExplorationMode mode,  int score,  int maxScore,  bool isPersonalBest,  double distanceMeters,  int yawDegrees,  int pitchDegrees,  int rank,  String episode,  String highlight)  $default,) {final _that = this;
switch (_that) {
case _ResultState():
return $default(_that.mode,_that.score,_that.maxScore,_that.isPersonalBest,_that.distanceMeters,_that.yawDegrees,_that.pitchDegrees,_that.rank,_that.episode,_that.highlight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExplorationMode mode,  int score,  int maxScore,  bool isPersonalBest,  double distanceMeters,  int yawDegrees,  int pitchDegrees,  int rank,  String episode,  String highlight)?  $default,) {final _that = this;
switch (_that) {
case _ResultState() when $default != null:
return $default(_that.mode,_that.score,_that.maxScore,_that.isPersonalBest,_that.distanceMeters,_that.yawDegrees,_that.pitchDegrees,_that.rank,_that.episode,_that.highlight);case _:
  return null;

}
}

}

/// @nodoc


class _ResultState implements ResultState {
  const _ResultState({required this.mode, this.score = 842, this.maxScore = 1000, this.isPersonalBest = true, this.distanceMeters = 2.3, this.yawDegrees = 8, this.pitchDegrees = 3, this.rank = 12, this.episode = '開会前の朝、人がいない広場で輪の影が柱の列と重なる瞬間を待って撮られました。', this.highlight = '木造の梁を組み上げた輪の構造は、下から見上げると継ぎ目のリズムが続いて見えます。'});
  

@override final  ExplorationMode mode;
@override@JsonKey() final  int score;
@override@JsonKey() final  int maxScore;
@override@JsonKey() final  bool isPersonalBest;
@override@JsonKey() final  double distanceMeters;
@override@JsonKey() final  int yawDegrees;
@override@JsonKey() final  int pitchDegrees;
@override@JsonKey() final  int rank;
@override@JsonKey() final  String episode;
@override@JsonKey() final  String highlight;

/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultStateCopyWith<_ResultState> get copyWith => __$ResultStateCopyWithImpl<_ResultState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.score, score) || other.score == score)&&(identical(other.maxScore, maxScore) || other.maxScore == maxScore)&&(identical(other.isPersonalBest, isPersonalBest) || other.isPersonalBest == isPersonalBest)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.yawDegrees, yawDegrees) || other.yawDegrees == yawDegrees)&&(identical(other.pitchDegrees, pitchDegrees) || other.pitchDegrees == pitchDegrees)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.highlight, highlight) || other.highlight == highlight));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,score,maxScore,isPersonalBest,distanceMeters,yawDegrees,pitchDegrees,rank,episode,highlight);
}

@override
String toString() {
    return 'ResultState(mode: $mode, score: $score, maxScore: $maxScore, isPersonalBest: $isPersonalBest, distanceMeters: $distanceMeters, yawDegrees: $yawDegrees, pitchDegrees: $pitchDegrees, rank: $rank, episode: $episode, highlight: $highlight)';
}


}

/// @nodoc
abstract mixin class _$ResultStateCopyWith<$Res> implements $ResultStateCopyWith<$Res> {
  factory _$ResultStateCopyWith(_ResultState value, $Res Function(_ResultState) _then) = __$ResultStateCopyWithImpl;
@override @useResult
$Res call({
 ExplorationMode mode, int score, int maxScore, bool isPersonalBest, double distanceMeters, int yawDegrees, int pitchDegrees, int rank, String episode, String highlight
});




}
/// @nodoc
class __$ResultStateCopyWithImpl<$Res>
    implements _$ResultStateCopyWith<$Res> {
  __$ResultStateCopyWithImpl(this._self, this._then);

  final _ResultState _self;
  final $Res Function(_ResultState) _then;

/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? score = null,Object? maxScore = null,Object? isPersonalBest = null,Object? distanceMeters = null,Object? yawDegrees = null,Object? pitchDegrees = null,Object? rank = null,Object? episode = null,Object? highlight = null,}) {
  return _then(_ResultState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ExplorationMode,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,maxScore: null == maxScore ? _self.maxScore : maxScore // ignore: cast_nullable_to_non_nullable
as int,isPersonalBest: null == isPersonalBest ? _self.isPersonalBest : isPersonalBest // ignore: cast_nullable_to_non_nullable
as bool,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,yawDegrees: null == yawDegrees ? _self.yawDegrees : yawDegrees // ignore: cast_nullable_to_non_nullable
as int,pitchDegrees: null == pitchDegrees ? _self.pitchDegrees : pitchDegrees // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as String,highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
