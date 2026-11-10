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
import 'package:serverpod/serverpod.dart' as _is;

/// 素材ファイル。file は revision.yaml と同じディレクトリからの相対パス。
abstract class SeedAssetFileInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedAssetFileInput._({required this.file, required this.contentType});

  factory SeedAssetFileInput({
    required String file,
    required String contentType,
  }) = _SeedAssetFileInputImpl;

  factory SeedAssetFileInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedAssetFileInput(
      file: jsonSerialization['file'] as String,
      contentType: jsonSerialization['contentType'] as String,
    );
  }

  String file;

  String contentType;

  /// Returns a shallow copy of this [SeedAssetFileInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedAssetFileInput copyWith({String? file, String? contentType});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedAssetFileInput',
      'file': file,
      'contentType': contentType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SeedAssetFileInputImpl extends SeedAssetFileInput {
  _SeedAssetFileInputImpl({required String file, required String contentType})
    : super._(file: file, contentType: contentType);

  /// Returns a shallow copy of this [SeedAssetFileInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedAssetFileInput copyWith({String? file, String? contentType}) {
    return SeedAssetFileInput(
      file: file ?? this.file,
      contentType: contentType ?? this.contentType,
    );
  }
}
