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

/// 出題。slug は英小文字・数字・ハイフン。
abstract class SeedChallengeInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedChallengeInput._({required this.slug, required this.title});

  factory SeedChallengeInput({required String slug, required String title}) =
      _SeedChallengeInputImpl;

  factory SeedChallengeInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedChallengeInput(
      slug: jsonSerialization['slug'] as String,
      title: jsonSerialization['title'] as String,
    );
  }

  String slug;

  String title;

  /// Returns a shallow copy of this [SeedChallengeInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedChallengeInput copyWith({String? slug, String? title});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedChallengeInput',
      'slug': slug,
      'title': title,
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

class _SeedChallengeInputImpl extends SeedChallengeInput {
  _SeedChallengeInputImpl({required String slug, required String title})
    : super._(slug: slug, title: title);

  /// Returns a shallow copy of this [SeedChallengeInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedChallengeInput copyWith({String? slug, String? title}) {
    return SeedChallengeInput(
      slug: slug ?? this.slug,
      title: title ?? this.title,
    );
  }
}
