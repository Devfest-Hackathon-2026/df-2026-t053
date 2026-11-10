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
import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// 公開中の出題。提出版は最大 1 件を id 昇順で返す。
abstract class ListChallengesResponse
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ListChallengesResponse._({required this.challenges});

  factory ListChallengesResponse({
    required List<_ix5zeh3i.Challenge> challenges,
  }) = _ListChallengesResponseImpl;

  factory ListChallengesResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ListChallengesResponse(
      challenges: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.Challenge>>(
        jsonSerialization['challenges'],
      ),
    );
  }

  List<_ix5zeh3i.Challenge> challenges;

  /// Returns a shallow copy of this [ListChallengesResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ListChallengesResponse copyWith({List<_ix5zeh3i.Challenge>? challenges});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListChallengesResponse',
      'challenges': challenges.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListChallengesResponse',
      'challenges': challenges.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ListChallengesResponseImpl extends ListChallengesResponse {
  _ListChallengesResponseImpl({required List<_ix5zeh3i.Challenge> challenges})
    : super._(challenges: challenges);

  /// Returns a shallow copy of this [ListChallengesResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ListChallengesResponse copyWith({List<_ix5zeh3i.Challenge>? challenges}) {
    return ListChallengesResponse(
      challenges:
          challenges ?? this.challenges.map((e0) => e0.copyWith()).toList(),
    );
  }
}
