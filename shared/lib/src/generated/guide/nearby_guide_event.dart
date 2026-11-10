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
import 'dart:typed_data' as _idt;

import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
part 'guide_audio_chunk.dart';
part 'guide_audio_unavailable.dart';
part 'guide_text.dart';

/// guide.explainNearby の stream で流れるイベントの基底。guideId は呼出し単位で全イベントに共通。
sealed class NearbyGuideEvent
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  NearbyGuideEvent({required this.guideId});

  _iss.UuidValue guideId;

  /// Returns a shallow copy of this [NearbyGuideEvent]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  NearbyGuideEvent copyWith({_iss.UuidValue? guideId});
}
