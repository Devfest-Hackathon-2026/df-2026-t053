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

/// 配信する素材の参照。端末は sha256 と byteLength で検証する。
abstract class AssetRef
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  AssetRef._({
    required this.url,
    required this.sha256,
    required this.byteLength,
    required this.contentType,
  });

  factory AssetRef({
    required String url,
    required String sha256,
    required int byteLength,
    required String contentType,
  }) = _AssetRefImpl;

  factory AssetRef.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetRef(
      url: jsonSerialization['url'] as String,
      sha256: jsonSerialization['sha256'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      contentType: jsonSerialization['contentType'] as String,
    );
  }

  String url;

  String sha256;

  int byteLength;

  String contentType;

  /// Returns a shallow copy of this [AssetRef]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  AssetRef copyWith({
    String? url,
    String? sha256,
    int? byteLength,
    String? contentType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetRef',
      'url': url,
      'sha256': sha256,
      'byteLength': byteLength,
      'contentType': contentType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssetRef',
      'url': url,
      'sha256': sha256,
      'byteLength': byteLength,
      'contentType': contentType,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _AssetRefImpl extends AssetRef {
  _AssetRefImpl({
    required String url,
    required String sha256,
    required int byteLength,
    required String contentType,
  }) : super._(
         url: url,
         sha256: sha256,
         byteLength: byteLength,
         contentType: contentType,
       );

  /// Returns a shallow copy of this [AssetRef]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  AssetRef copyWith({
    String? url,
    String? sha256,
    int? byteLength,
    String? contentType,
  }) {
    return AssetRef(
      url: url ?? this.url,
      sha256: sha256 ?? this.sha256,
      byteLength: byteLength ?? this.byteLength,
      contentType: contentType ?? this.contentType,
    );
  }
}
