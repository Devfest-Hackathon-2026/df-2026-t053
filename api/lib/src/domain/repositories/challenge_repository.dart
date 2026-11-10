import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;

import '../models/models.dart';

/// 出題と版の読み取り。書き込み（seed・公開）は #26 が扱う。
abstract interface class ChallengeRepository() {
  /// 公開中（currentRevisionId が非 null）の出題を id の昇順で返す。
  Future<List<Challenge>> listPublished();

  Future<Challenge?> findById(int id);

  /// 一度でも公開された出題だけを返す。公開が終わった出題（`currentRevisionId` が null）も
  /// 返す。公開済みの版が 1 つもない出題（下書きだけ）は null。クライアント向けの取得が使う。
  Future<Challenge?> findPublicById(int id);

  /// 版を子データごと返す。[ChallengeRevision.secrets] は null。
  /// 未公開の下書き版も返す（管理用・プレイ中の版の読み取り）。
  Future<ChallengeRevision?> findRevision(int revisionId);

  /// 版の行だけを読み、出題 ID と公開済みかを返す（子データは読まない）。ない版は null。
  /// 開始のたびに版を丸ごと読まないよう、プレイの開始が使う。
  Future<({int challengeId, bool published})?> findRevisionStatus(
    int revisionId,
  );

  /// 版・モードの開始点を sortOrder の昇順で返す。モードの設定がなければ空。
  /// 抽選の候補と、選んだ開始点がその版・モードに属することの確認に使う。
  Future<List<SpawnPoint>> listSpawnPoints(int revisionId, PlayMode mode);

  /// 開始点 [spawnPointId] を返す。ない場合は null。プレイの再取得で、保存した開始点を読む。
  Future<SpawnPoint?> findSpawnPoint(int spawnPointId);

  /// 公開済み（`published_at` が非 null）の版だけを子データごと返す。[ChallengeRevision.secrets]
  /// は null。未公開の下書き版は、子データを読む前に null を返す（下書きの JSON が壊れていても、
  /// 存在しない版と区別がつかないようにする）。クライアント向けの版の取得が使う。
  Future<ChallengeRevision?> findPublishedRevision(int revisionId);

  /// [findRevision] に加えて、正解姿勢・story・highlight を読む。
  /// 撮影の採点と、撮影後の結果表示だけが使う。
  Future<ChallengeRevision?> findRevisionWithSecrets(int revisionId);
}
