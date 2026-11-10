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

/// 素材の出典表記。
abstract class Credit
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Credit._({required this.name, this.url});

  factory Credit({required String name, String? url}) = _CreditImpl;

  factory Credit.fromJson(Map<String, dynamic> jsonSerialization) {
    return Credit(
      name: jsonSerialization['name'] as String,
      url: jsonSerialization['url'] as String?,
    );
  }

  String name;

  String? url;

  /// Returns a shallow copy of this [Credit]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Credit copyWith({String? name, String? url});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Credit',
      'name': name,
      if (url != null) 'url': url,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Credit',
      'name': name,
      if (url != null) 'url': url,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreditImpl extends Credit {
  _CreditImpl({required String name, String? url})
    : super._(name: name, url: url);

  /// Returns a shallow copy of this [Credit]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Credit copyWith({String? name, Object? url = _Undefined}) {
    return Credit(
      name: name ?? this.name,
      url: url is String? ? url : this.url,
    );
  }
}
