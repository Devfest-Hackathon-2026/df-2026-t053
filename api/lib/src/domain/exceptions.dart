/// 一意制約に違反した。同じ要求の再送（requestId など）か、競合かを
/// ユースケース側で判断するために、汎用の 500 にはせず専用の例外にする。
class const DuplicateEntityException({
  /// 違反したテーブル（例 `play_session`）。
  required final String entity,

  /// 違反した一意制約の名前（例 `play_session_profile_request_uk`）。
  /// 既知の制約に当てはまらないときは、違反した列をカンマでつないだもの。
  required final String constraint,
}) implements Exception {
  @override
  String toString() =>
      'DuplicateEntityException(entity: $entity, constraint: $constraint)';
}

enum RankingFailure() {
  invalidRequest,
  revisionNotFound,
  profileNotInitialized,
  entryNotFound,
}

class const RankingException(final RankingFailure reason) implements Exception;

/// DB の値がドメインの前提を満たさない（壊れた JSON、未知の列挙値など）。
/// 壊れたデータを素通しでドメインへ渡さず、読み出しの時点で止める。
class const CorruptedDataException({
  required final String entity,
  required final String field,
  required final String message,
}) implements Exception {
  @override
  String toString() =>
      'CorruptedDataException(entity: $entity, field: $field, $message)';
}

/// 出題・版の取得（challenge エンドポイント）の失敗理由。
enum ChallengeFailure() {
  /// 引数が不正（0 以下の ID など）。
  invalidRequest,

  /// 出題がない。
  challengeNotFound,

  /// 版がない。未公開の下書き版も同じ扱いにする（下書きの存在を公開しない）。
  revisionNotFound,
}

class const ChallengeException(final ChallengeFailure reason)
    implements Exception;

/// プレイの開始・取得（play エンドポイント）の失敗理由。
enum PlayFailure() {
  /// 引数が不正（mode が unknown など）。
  invalidRequest,

  /// 同じ requestId で、別の入力（版・モード）が届いた。
  requestIdReused,

  /// 版がない。
  revisionNotFound,

  /// 現在の公開版ではない（旧版・未公開・公開終了）。新規開始はできない。
  revisionNotPlayable,

  /// 開始の頻度が上限を超えた。[PlayException.retryAfterSeconds] を見る。
  sessionRateLimited,

  /// プレイがない。
  sessionNotFound,

  /// 他人のプレイ。
  notSessionOwner,

  /// 認証主体のプロフィールがない（認証フローが作る）。
  profileNotInitialized,
}

class const PlayException(
  final PlayFailure reason, {
  final int? retryAfterSeconds,
}) implements Exception {
  @override
  String toString() => 'PlayException($reason)';
}

/// 登録資料に案内可能な候補がない。presentationでNO_GUIDE_TARGETへ変換する。
class const NoGuideTargetException() implements Exception;

/// 非有限のガイド姿勢。位置などの入力値は保持しない。
class const InvalidGuidePoseException() implements Exception;

enum GuidePrecondition() {
  completed,
  expired,
  disabled,
  unsupportedLocale,
  deadline,
}

class const GuidePreconditionException(final GuidePrecondition reason)
    implements Exception;

/// 同じ認証主体のプロフィールが既に存在する。
class const ProfileAlreadyExistsException() implements Exception;

/// 認証主体に対応するプロフィールがない。認証フローでの復旧が必要。
class const ProfileMissingException() implements Exception;

class const UnsupportedScoringVersionException(final String version)
    implements Exception {
  @override
  String toString() => 'UnsupportedScoringVersionException(version: $version)';
}

/// 項目名だけを保持し、正解姿勢や入力値を含めない。
class const InvalidScoringPoseException(final String field)
    implements Exception {
  @override
  String toString() => 'InvalidScoringPoseException(field: $field)';
}

/// 撮影の事前検査。入力値や正解は保持しない。
enum ShotFailure() {
  invalidCamera,
  alreadySubmitted,
  sessionExpired,
}

class const ShotException(
  final ShotFailure reason, {
  final List<String> fields = const [],
}) implements Exception;
