import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

enum HealthFailureKind { unreachable, releaseMismatch }

@freezed
abstract class HealthFailure with _$HealthFailure implements Exception {
  const factory HealthFailure(HealthFailureKind kind) = _HealthFailure;
}
