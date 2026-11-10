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

/// 全パビリオン一覧の応答。
abstract class ListPavilionsResponse
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ListPavilionsResponse._({required this.pavilions});

  factory ListPavilionsResponse({required List<_ix5zeh3i.Pavilion> pavilions}) =
      _ListPavilionsResponseImpl;

  factory ListPavilionsResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ListPavilionsResponse(
      pavilions: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.Pavilion>>(
        jsonSerialization['pavilions'],
      ),
    );
  }

  List<_ix5zeh3i.Pavilion> pavilions;

  /// Returns a shallow copy of this [ListPavilionsResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ListPavilionsResponse copyWith({List<_ix5zeh3i.Pavilion>? pavilions});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListPavilionsResponse',
      'pavilions': pavilions.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListPavilionsResponse',
      'pavilions': pavilions.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ListPavilionsResponseImpl extends ListPavilionsResponse {
  _ListPavilionsResponseImpl({required List<_ix5zeh3i.Pavilion> pavilions})
    : super._(pavilions: pavilions);

  /// Returns a shallow copy of this [ListPavilionsResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ListPavilionsResponse copyWith({List<_ix5zeh3i.Pavilion>? pavilions}) {
    return ListPavilionsResponse(
      pavilions:
          pavilions ?? this.pavilions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
