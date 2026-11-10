import 'package:serverpod/serverpod.dart';

import '../../domain/exceptions.dart';

/// SQLite の UNIQUE 違反を [DuplicateEntityException] へ変換して実行する。
///
/// SQLite のメッセージは `UNIQUE constraint failed: table.col1, table.col2`。
/// 違反した列の並びから、migration で付けた制約の名前を引く。
/// 汎用の 500 にはせず、ユースケースが再送か競合かを判断できるようにする。
Future<T> translateUniqueViolation<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DatabaseQueryException catch (e) {
    // 主キーの重複（SQLITE_CONSTRAINT_PRIMARYKEY）は [DatabaseUniqueViolationException]
    // ではなく親の型で届くので、メッセージで判別する。
    throw _toDuplicate(e.message) ?? e;
  }
}

DuplicateEntityException? _toDuplicate(String message) {
  const prefix = 'UNIQUE constraint failed: ';
  final start = message.indexOf(prefix);
  if (start < 0) return null;
  final columns = message
      .substring(start + prefix.length)
      .split(',')
      .map((c) => c.trim())
      .where((c) => c.isNotEmpty)
      .toList();
  if (columns.isEmpty) return null;
  final table = columns.first.split('.').first;
  final names = columns.map((c) => c.split('.').last).toList();
  final key = '$table(${names.join(',')})';
  return DuplicateEntityException(
    entity: table,
    constraint: _uniqueConstraints[key] ?? key,
  );
}

/// `table(col1,col2)` → migration の一意制約の名前。
const _uniqueConstraints = {
  'challenge(slug)': 'challenge_slug_uk',
  'challenge_revision(challenge_id,revision_no)':
      'challenge_revision_challenge_no_uk',
  'mode_config(revision_id,mode)': 'mode_config_revision_mode_uk',
  'spawn_point(mode_config_id,sort_order)': 'spawn_point_mode_config_order_uk',
  'asset(sha256)': 'asset_sha256_uk',
  'pavilion(source_key)': 'pavilion_source_key_uk',
  'landmark(revision_id,pavilion_id)': 'landmark_revision_pavilion_uk',
  'user_profile(auth_user_id)': 'user_profile_auth_user_uk',
  'play_session(id)': 'play_session_pkey',
  'play_session(user_profile_id,request_id)': 'play_session_profile_request_uk',
  'shot(play_session_id)': 'shot_play_session_uk',
  'best_score(user_profile_id,revision_id,mode)':
      'best_score_profile_revision_mode_uk',
  'best_score(shot_id)': 'best_score_shot_uk',
};
