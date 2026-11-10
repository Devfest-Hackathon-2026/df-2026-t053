/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// プレイの状態。未知の値は unknown として受け取り、撮影を無効にする。
enum PlaySessionState implements _iss.SerializableModel {
  unknown,
  active,
  completed;

  static PlaySessionState fromJson(String name) {
    switch (name) {
      case 'unknown':
        return PlaySessionState.unknown;
      case 'active':
        return PlaySessionState.active;
      case 'completed':
        return PlaySessionState.completed;
      default:
        return PlaySessionState.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
