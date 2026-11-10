import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../application/usecase/get_challenge.dart';
import '../../application/usecase/get_challenge_revision.dart';
import '../../application/usecase/list_challenges.dart';
import '../../domain/ports/asset_url_resolver.dart';
import '../../infrastructure/config/asset_url_settings.dart';
import '../../infrastructure/config/runtime_environment.dart';
import '../../infrastructure/database/repositories/orm_challenge_repository.dart';

ListChallenges listChallengesUseCase(Session session) =>
    ListChallenges(OrmChallengeRepository(session));

GetChallenge getChallengeUseCase(Session session) =>
    GetChallenge(OrmChallengeRepository(session));

GetChallengeRevision getChallengeRevisionUseCase(Session session) =>
    GetChallengeRevision(OrmChallengeRepository(session));

AssetUrls? _assetUrls;

/// 起動時（`createServer`）に `ASSET_BASE_URL` を検証して設定する。誤りなら起動を失敗させる。
///
/// migration Job（`--role=maintenance`）は素材 URL を配信しないので検証しない。
void configureAssetUrls(Serverpod pod) {
  if (pod.config.role.name == 'maintenance') return;
  _assetUrls = AssetUrls.fromEnvironment(
    Platform.environment,
    production: isDeployedRunMode(pod.runMode),
  );
}

/// 素材の公開 URL を作る実装。[configureAssetUrls]（`createServer` が起動時に呼ぶ）で
/// 検証した値だけを使う。設定を読む経路を 1 つにし、遅れて設定の誤りが 500 になるのを防ぐ。
AssetUrlResolver assetUrlResolver(Session session) =>
    _assetUrls ??
    (throw StateError(
      'configureAssetUrls が呼ばれていない（createServer を通さずにサーバーを作った）',
    ));
