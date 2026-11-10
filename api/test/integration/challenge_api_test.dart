import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_client/photohunt_client.dart';
import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/infrastructure/config/asset_url_settings.dart';
import 'package:photohunt_server/src/infrastructure/database/seed/sqlite_seed_store.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// Authorization ヘッダーに JWT を載せるだけの最小の provider。
class _BearerProvider() implements ClientAuthKeyProvider {
  String? token;

  @override
  Future<String?> get authHeaderValue async =>
      token == null ? null : wrapAsBearerAuthHeaderValue(token!);
}

/// 素材置き場の代わり（この試験では素材の配置は確かめない）。
class const _NoopMedia() implements SeedMediaStore {
  @override
  Future<bool> putIfAbsent(
    String objectPath,
    Uint8List bytes,
    String contentType,
  ) async => true;
}

Matcher _apiFailure(ApiErrorCode code, String reason) => throwsA(
  isA<ApiException>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.reason, 'reason', reason),
);

const _sampleDir = 'test/fixtures/seeds/sample-plaza/r1';
const _pavilions = 'test/fixtures/seeds/pavilions.yaml';
const _dbPath = 'data/test.sqlite';

/// 公開 DTO（版）が持ってよい項目。これ以外が出たら、秘密が漏れている。
const _revisionKeys = {
  '__className__',
  'id',
  'challengeId',
  'sceneProfile',
  'photo',
  'photoAlt',
  'map',
  'modes',
  'eyeHeightMeters',
  'shotVerticalFovDegrees',
  'credits',
};

/// 実サーバーを test モードで起動し、#26 の seed で登録・公開した出題を生成 client から取得する。
///
/// 各テストは自分の slug の出題を作り、終わったら公開を外す（公開中の出題は 1 件までのため）。
/// テスト同士の順序や、単独の実行（`--name`）に依存しない。
void main() {
  late Serverpod pod;
  late Client client;
  final auth = _BearerProvider();
  final sample = readSeedBundle(dir: _sampleDir, pavilionsPath: _pavilions);
  final now = DateTime.utc(2026, 11, 9);
  final slugs = <String>{};

  /// 出題の slug だけを変えた seed。素材と内容はサンプルと同じ。
  SeedBundle bundleFor(String slug) {
    final raw = readSeedRevisionInput(_sampleDir);
    final input = seedRevisionFromInput(
      raw.copyWith(challenge: raw.challenge.copyWith(slug: slug)),
    );
    return SeedBundle(
      input: input,
      pavilions: sample.pavilions,
      photo: sample.photo,
      map: sample.map,
      digest: seedDigest(
        input,
        photoSha256: sample.photo.sha256,
        mapSha256: sample.map.sha256,
      ),
    );
  }

  /// サーバーと同じ DB ファイルへ、seed の CLI と同じ実装で書く。
  Future<T> withSeedStore<T>(Future<T> Function(SqliteSeedStore s) body) async {
    final store = SqliteSeedStore.open(_dbPath);
    try {
      return await body(store);
    } finally {
      store.close();
    }
  }

  /// [slug] の出題を下書きとして登録し、版の id を返す。[publish] なら公開する。
  Future<int> seedChallenge(String slug, {bool publish = false}) async {
    slugs.add(slug);
    final result = await withSeedStore(
      (store) => LoadSeedRevision(
        store: store,
        media: const _NoopMedia(),
        clock: () => now,
      ).execute(bundleFor(slug), publish: publish),
    );
    return (result as LoadSeedLoaded).revisionId;
  }

  int challengeIdOf(String slug) {
    final db = sqlite3.open(_dbPath, mode: OpenMode.readOnly);
    try {
      return db.select('SELECT id FROM challenge WHERE slug = ?', [
            slug,
          ]).single['id']
          as int;
    } finally {
      db.close();
    }
  }

  setUpAll(() async {
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('$_dbPath$suffix');
      if (file.existsSync()) file.deleteSync();
    }
    pod = createServer(['--mode', 'test', '--apply-migrations']);
    await pod.start();
    client = Client('http://localhost:8180/')..authKeyProvider = auth;
    auth.token = (await client.anonymousIdp.login()).token;
  });

  tearDown(() async {
    // 公開中の出題は 1 件までなので、次のテストのために公開を外す。
    await withSeedStore((store) async {
      for (final slug in slugs) {
        try {
          await store.unpublish(slug: slug);
        } on SeedNotFoundException {
          // 登録まで進まなかったテスト。
        }
      }
    });
  });

  tearDownAll(() async {
    client.close();
    await pod.shutdown(exitProcess: false);
  });

  test('未ログインでは 3 メソッドとも拒否する', () async {
    final anonymous = Client('http://localhost:8180/');
    addTearDown(anonymous.close);
    final unauthorized = throwsA(isA<ServerpodClientUnauthorized>());
    await expectLater(
      anonymous.challenge.listChallenges(ListChallengesRequest()),
      unauthorized,
    );
    await expectLater(
      anonymous.challenge.getChallenge(GetChallengeRequest(challengeId: 1)),
      unauthorized,
    );
    await expectLater(
      anonymous.challenge.getChallengeRevision(
        GetChallengeRevisionRequest(revisionId: 1),
      ),
      unauthorized,
    );
  });

  test('公開中の出題が無ければ listChallenges は空配列', () async {
    final response = await client.challenge.listChallenges(
      ListChallengesRequest(),
    );
    expect(response.challenges, isEmpty);
  });

  test('下書きだけの出題・版は、ない場合と同じ応答で、一覧にも出ない', () async {
    final revisionId = await seedChallenge('draft-only');
    final challengeId = challengeIdOf('draft-only');

    await expectLater(
      client.challenge.getChallengeRevision(
        GetChallengeRevisionRequest(revisionId: revisionId),
      ),
      _apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
    );
    await expectLater(
      client.challenge.getChallenge(
        GetChallengeRequest(challengeId: challengeId),
      ),
      _apiFailure(.notFound, ApiErrorReasons.challengeNotFound),
    );
    expect(
      (await client.challenge.listChallenges(ListChallengesRequest()))
          .challenges,
      isEmpty,
    );

    // 下書きの歩行領域が壊れていても、読み込みに失敗せず（internal にならず）、
    // 版がない場合と同じ応答になる（下書きの存在を応答の差で知らせない）。
    final db = sqlite3.open(_dbPath);
    final original = db
        .select('SELECT id, walkable FROM mode_config WHERE revision_id = ?', [
          revisionId,
        ])
        .map((r) => (r['id'], r['walkable']))
        .toList();
    db.execute('UPDATE mode_config SET walkable = ? WHERE revision_id = ?', [
      '{"outer": "x"}',
      revisionId,
    ]);
    try {
      await expectLater(
        client.challenge.getChallengeRevision(
          GetChallengeRevisionRequest(revisionId: revisionId),
        ),
        _apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
      );
    } finally {
      for (final (id, walkable) in original) {
        db.execute('UPDATE mode_config SET walkable = ? WHERE id = ?', [
          walkable,
          id,
        ]);
      }
      db.close();
    }
  });

  test('seed で公開した出題を list → get → getRevision の順に取得できる', () async {
    await seedChallenge('live', publish: true);

    final list = await client.challenge.listChallenges(ListChallengesRequest());
    expect(list.challenges, hasLength(1));
    final summary = list.challenges.single;
    expect(summary.title, sample.input.title);

    final challenge = await client.challenge.getChallenge(
      GetChallengeRequest(challengeId: summary.id),
    );
    expect(challenge.currentRevisionId, isNotNull);

    final revision = await client.challenge.getChallengeRevision(
      GetChallengeRevisionRequest(revisionId: challenge.currentRevisionId!),
    );
    final input = sample.input;
    expect(revision.challengeId, challenge.id);
    expect(revision.sceneProfile, input.sceneProfile);
    expect(revision.photoAlt, input.photoAlt);
    expect(revision.eyeHeightMeters, input.eyeHeightMeters);
    expect(revision.shotVerticalFovDegrees, input.shotVerticalFovDegrees);

    // 素材は ASSET_BASE_URL（test モードの既定はローカルの値）と内容アドレスから作る。
    expect(revision.photo.sha256, sample.photo.sha256);
    expect(revision.photo.byteLength, sample.photo.byteLength);
    expect(revision.photo.contentType, input.photo.contentType);
    expect(
      revision.photo.url,
      '${kLocalAssetBaseUrl}media/${sample.photo.sha256}/photo.png',
    );
    expect(revision.map.image.sha256, sample.map.sha256);
    expect(revision.map.bounds.maxX, input.bounds.maxX);

    // モードは seed の順（free・near）。歩行領域は型付きで往復する。
    expect(revision.modes.map((m) => m.mode), [PlayMode.free, PlayMode.near]);
    expect(
      revision.modes.first.walkable.outer.length,
      input.modes.first.walkable.outer.length,
    );
    expect(
      revision.modes.first.walkable.holes,
      hasLength(input.modes.first.walkable.holes.length),
    );

    // 地点は表示名を name に、任意の緯度経度も seed の値を保持する。
    expect(
      revision.map.landmarks.map((l) => l.name),
      input.landmarks.map((l) => l.displayName),
    );
    expect(
      revision.map.landmarks.map((l) => (l.latitude, l.longitude)),
      input.landmarks.map((l) => (l.latitude, l.longitude)),
    );
    expect(
      revision.credits.map((c) => c.name),
      input.credits.map((c) => c.name),
    );
  });

  test('版の JSON は公開してよい項目だけで、正解姿勢・解説・開始点・構造物資料・モデルが出ない', () async {
    final revisionId = await seedChallenge('secrets', publish: true);
    final revision = await client.challenge.getChallengeRevision(
      GetChallengeRevisionRequest(revisionId: revisionId),
    );
    final json = revision.toJson();

    // 項目の集合を厳密に比べる。goal・spawn・story・structure・scoringVersion・
    // objectPath・model などが、どの階層にも増えていないこと。
    expect(json.keys.toSet(), _revisionKeys);
    expect((json['photo'] as Map).keys.toSet(), {
      '__className__',
      'url',
      'sha256',
      'byteLength',
      'contentType',
    });
    expect((json['map'] as Map).keys.toSet(), {
      '__className__',
      'image',
      'bounds',
      'landmarks',
    });
    for (final mode in json['modes'] as List) {
      final map = mode as Map;
      expect(map.keys.toSet(), {
        '__className__',
        'mode',
        'walkable',
        'entrances',
      });
      // 入口は id と表示名だけ。開始点の座標は公開しない。
      for (final entrance in map['entrances'] as List) {
        expect((entrance as Map).keys.toSet(), {
          '__className__',
          'id',
          'label',
        });
      }
    }
    final landmarks = (json['map'] as Map)['landmarks'] as List;
    expect(landmarks, hasLength(sample.input.landmarks.length));
    for (final (index, landmark) in landmarks.indexed) {
      final input = sample.input.landmarks[index];
      expect((landmark as Map).keys.toSet(), {
        '__className__',
        'id',
        'name',
        'positionX',
        'positionZ',
        if (input.latitude != null) 'latitude',
        if (input.longitude != null) 'longitude',
      });
    }

    // seed の文章（正解の解説・構造物資料・出典）は、値としても現れない。
    final text = jsonEncode(json);
    final input = sample.input;
    for (final secret in [input.story, input.highlight]) {
      expect(text, isNot(contains(secret)));
    }
    for (final structure in input.structures) {
      expect(text, isNot(contains(structure.facts)));
      expect(text, isNot(contains(structure.fallbackText)));
      for (final source in structure.sources) {
        expect(text, isNot(contains(source.url)));
      }
    }
  });

  test('公開終了した出題は currentRevisionId が null で、公開済みの旧版は取得できる', () async {
    final revisionId = await seedChallenge('ended', publish: true);
    final challengeId = challengeIdOf('ended');
    await withSeedStore((store) => store.unpublish(slug: 'ended'));

    expect(
      (await client.challenge.listChallenges(ListChallengesRequest()))
          .challenges,
      isEmpty,
    );
    final ended = await client.challenge.getChallenge(
      GetChallengeRequest(challengeId: challengeId),
    );
    expect(ended.currentRevisionId, isNull);
    final old = await client.challenge.getChallengeRevision(
      GetChallengeRevisionRequest(revisionId: revisionId),
    );
    expect(old.id, revisionId);
  });

  test('ない ID と不正な ID は型付きの ApiException', () async {
    await expectLater(
      client.challenge.getChallenge(GetChallengeRequest(challengeId: 99999)),
      _apiFailure(.notFound, ApiErrorReasons.challengeNotFound),
    );
    await expectLater(
      client.challenge.getChallengeRevision(
        GetChallengeRevisionRequest(revisionId: 99999),
      ),
      _apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
    );
    await expectLater(
      client.challenge.getChallenge(GetChallengeRequest(challengeId: 0)),
      _apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest),
    );
    await expectLater(
      client.challenge.getChallengeRevision(
        GetChallengeRevisionRequest(revisionId: -1),
      ),
      _apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest),
    );
  });
}
