// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingShot _$PendingShotFromJson(Map<String, dynamic> json) => _PendingShot(
  authUserId: json['authUserId'] as String,
  playSessionId: json['playSessionId'] as String,
  revisionId: (json['revisionId'] as num).toInt(),
  shot: ShotInput.fromJson(json['shot'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$PendingShotToJson(_PendingShot instance) =>
    <String, dynamic>{
      'authUserId': instance.authUserId,
      'playSessionId': instance.playSessionId,
      'revisionId': instance.revisionId,
      'shot': instance.shot,
      'requestId': instance.requestId,
    };
