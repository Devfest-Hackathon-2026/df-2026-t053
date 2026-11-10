/// [ApiException.reason] に入れる固定の文字列定数。
///
/// 画面は code と reason を日本語の案内へ対応付ける。
/// 一覧は仕様書「共通エラーと再試行」の表のとおり。
abstract final class ApiErrorReasons() {
  // invalidArgument
  static const invalidNickname = 'INVALID_NICKNAME';
  static const invalidCamera = 'INVALID_CAMERA';
  static const invalidRequest = 'INVALID_REQUEST';
  static const unsupportedLocale = 'UNSUPPORTED_LOCALE';
  static const requestIdReused = 'REQUEST_ID_REUSED';

  // failedPrecondition
  static const profileNotInitialized = 'PROFILE_NOT_INITIALIZED';
  static const sessionCompleted = 'SESSION_COMPLETED';
  static const guideDisabled = 'GUIDE_DISABLED';
  static const noGuideTarget = 'NO_GUIDE_TARGET';
  static const revisionNotPlayable = 'REVISION_NOT_PLAYABLE';
  static const sessionExpired = 'SESSION_EXPIRED';

  // resourceExhausted
  static const sessionRateLimited = 'SESSION_RATE_LIMITED';
  static const guideRateLimited = 'GUIDE_RATE_LIMITED';

  // notFound
  static const challengeNotFound = 'CHALLENGE_NOT_FOUND';
  static const revisionNotFound = 'REVISION_NOT_FOUND';
  static const playSessionNotFound = 'PLAY_SESSION_NOT_FOUND';
  static const rankingEntryNotFound = 'RANKING_ENTRY_NOT_FOUND';

  // permissionDenied
  static const notSessionOwner = 'NOT_SESSION_OWNER';

  // alreadyExists
  static const shotAlreadySubmitted = 'SHOT_ALREADY_SUBMITTED';

  // unavailable
  static const temporarilyUnavailable = 'TEMPORARILY_UNAVAILABLE';
  static const maintenance = 'MAINTENANCE';
  static const schemaTooNew = 'SCHEMA_TOO_NEW';

  // internal
  static const internal = 'INTERNAL';

  /// すべての reason。重複や取りこぼしをテストで確かめるために公開する。
  static const all = <String>[
    invalidNickname,
    invalidCamera,
    invalidRequest,
    unsupportedLocale,
    requestIdReused,
    sessionCompleted,
    profileNotInitialized,
    guideDisabled,
    noGuideTarget,
    revisionNotPlayable,
    sessionExpired,
    sessionRateLimited,
    guideRateLimited,
    challengeNotFound,
    revisionNotFound,
    playSessionNotFound,
    rankingEntryNotFound,
    notSessionOwner,
    shotAlreadySubmitted,
    temporarilyUnavailable,
    maintenance,
    schemaTooNew,
    internal,
  ];
}
