import 'dart:convert';
import 'dart:typed_data';

import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_serialization/serverpod_serialization.dart';
import 'package:test/test.dart';

final protocol = Protocol();
final uuid = UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000');
final uuid2 = UuidValue.fromString('6ba7b810-9dad-41d1-80b4-00c04fd430c8');
final t0 = DateTime.utc(2026, 11, 8, 1, 2, 3);

/// JSON 文字列を経由して戻す（通信と同じ経路）。
T roundTrip<T>(Object value) =>
    protocol.deserialize<T>(jsonDecode(SerializationManager.encode(value)));

/// 往復の前後で JSON が一致することを確かめる。
void expectRoundTrip<T extends SerializableModel>(T value) {
  final back = roundTrip<T>(value);
  expect(back.runtimeType.toString(), value.runtimeType.toString());
  expect(jsonEncode(back.toJson()), jsonEncode(value.toJson()));
}

AssetRef asset() => AssetRef(
  url: 'https://example.com/a.png',
  sha256: 'a' * 64,
  byteLength: 1024,
  contentType: 'image/png',
);

CameraPose camera() => CameraPose(
  positionX: 1.5,
  positionY: 1.6,
  positionZ: -2.5,
  yawDegrees: 90,
  pitchDegrees: -10,
  verticalFovDegrees: 60,
);

Shot shot() => Shot(
  id: 7,
  camera: camera(),
  score: 513,
  distanceMeters: 2.0,
  yawDiffDegrees: 0,
  pitchDiffDegrees: 0,
  createTime: t0,
);

Reveal reveal() => Reveal(goalCamera: camera(), story: '物語', highlight: '見どころ');

RankingEntry entry() => RankingEntry(
  rank: 1,
  nickname: '旅人1234',
  score: 900,
  achieveTime: t0,
  mine: true,
);

WalkableArea walkable() => WalkableArea(
  outer: [PointXZ(x: 0, z: 0), PointXZ(x: 10, z: 0), PointXZ(x: 10, z: 10)],
  holes: [
    [PointXZ(x: 1, z: 1), PointXZ(x: 2, z: 1), PointXZ(x: 2, z: 2)],
  ],
);

void main() {
  group('リソース', () {
    test('Challenge（currentRevisionId が null でも往復する）', () {
      expectRoundTrip(Challenge(id: 1, title: 't', currentRevisionId: 3));
      final back = roundTrip<Challenge>(Challenge(id: 1, title: 't'));
      expect(back.currentRevisionId, isNull);
    });

    test('ChallengeRevision（入れ子の素材・地図・モード・出典）', () {
      final revision = ChallengeRevision(
        id: 2,
        challengeId: 1,
        sceneProfile: 'default',
        photo: asset(),
        photoAlt: '代替文',
        map: VenueMap(
          image: asset(),
          bounds: MapBounds(minX: 0, minZ: 0, maxX: 100, maxZ: 80),
          landmarks: [
            Landmark(id: 1, name: 'A', positionX: 1, positionZ: 2),
            Landmark(
              id: 2,
              name: 'B',
              positionX: 3,
              positionZ: 4,
              latitude: 34.65,
              longitude: 135.43,
            ),
          ],
        ),
        modes: [
          ModeConfig(
            mode: PlayMode.free,
            walkable: walkable(),
            entrances: const [],
          ),
          ModeConfig(
            mode: PlayMode.near,
            walkable: walkable(),
            entrances: const [],
          ),
        ],
        eyeHeightMeters: 1.6,
        shotVerticalFovDegrees: 60,
        credits: [
          Credit(name: 'c', url: 'https://example.com'),
          Credit(name: 'd'),
        ],
      );
      expectRoundTrip(revision);
      final back = roundTrip<ChallengeRevision>(revision);
      expect(back.modes.first.walkable.holes.single, hasLength(3));
      expect(back.map.landmarks.first.latitude, isNull);
      expect(back.map.landmarks.last.latitude, 34.65);
      expect(back.credits.last.url, isNull);
    });

    test('PlaySession（active は結果が null、completed は 3 つとも返る）', () {
      final active = PlaySession(
        id: uuid,
        revisionId: 2,
        mode: PlayMode.near,
        spawnPointId: 4,
        spawn: Spawn(positionX: 1, positionY: 0, positionZ: 2, yawDegrees: 45),
        state: PlaySessionState.active,
        createTime: t0,
        expireTime: t0.add(const Duration(hours: 2)),
      );
      final backActive = roundTrip<PlaySession>(active);
      expect(backActive.id, uuid);
      expect(backActive.state, PlaySessionState.active);
      expect(backActive.shot, isNull);
      expect(backActive.reveal, isNull);
      expect(backActive.myRankingEntry, isNull);
      expect(backActive.expireTime, active.expireTime);

      final completed = PlaySession(
        id: uuid,
        revisionId: 2,
        mode: PlayMode.free,
        spawnPointId: 4,
        spawn: active.spawn,
        state: PlaySessionState.completed,
        createTime: t0,
        expireTime: t0,
        shot: shot(),
        reveal: reveal(),
        myRankingEntry: entry(),
      );
      expectRoundTrip(completed);
      final back = roundTrip<PlaySession>(completed);
      expect(back.shot!.score, 513);
      expect(back.reveal!.story, '物語');
      expect(back.myRankingEntry!.mine, isTrue);
    });

    test('Shot / Reveal / RankingEntry / Profile / Spawn / ShotInput', () {
      expectRoundTrip(shot());
      expectRoundTrip(reveal());
      expectRoundTrip(entry());
      expectRoundTrip(Profile(nickname: '旅人0001', anonymous: true));
      expectRoundTrip(
        Spawn(positionX: 1, positionY: 2, positionZ: 3, yawDegrees: 4),
      );
      expectRoundTrip(
        ShotInput(positionX: 1, positionZ: 2, yawDegrees: 3, pitchDegrees: 4),
      );
      expectRoundTrip(FieldViolation(field: 'nickname', reason: 'TOO_LONG'));
      expectRoundTrip(GuideSource(title: 't', url: 'https://example.com'));
    });

    test('整数に見える double も double のまま往復する', () {
      final back = roundTrip<ShotInput>(
        ShotInput(positionX: 1, positionZ: 2, yawDegrees: 3, pitchDegrees: 4),
      );
      expect(back.positionX, 1.0);
      expect(back.pitchDegrees, 4.0);
    });
  });

  group('Request', () {
    test('空の Request も専用モデルとして往復する', () {
      expectRoundTrip(ListChallengesRequest());
      expectRoundTrip(GetMyProfileRequest());
    });

    test('項目を持つ Request', () {
      expectRoundTrip(GetChallengeRequest(challengeId: 1));
      expectRoundTrip(GetChallengeRevisionRequest(revisionId: 2));
      expectRoundTrip(
        CreatePlaySessionRequest(
          revisionId: 2,
          mode: PlayMode.near,
          requestId: uuid,
        ),
      );
      expectRoundTrip(GetPlaySessionRequest(playSessionId: uuid));
      expectRoundTrip(
        SubmitShotRequest(
          playSessionId: uuid,
          camera: ShotInput(
            positionX: 1,
            positionZ: 2,
            yawDegrees: 3,
            pitchDegrees: 4,
          ),
          requestId: uuid2,
        ),
      );
      expectRoundTrip(
        ListRankingEntriesRequest(revisionId: 2, mode: PlayMode.free),
      );
      expectRoundTrip(
        GetMyRankingEntryRequest(revisionId: 2, mode: PlayMode.near),
      );
      expectRoundTrip(UpdateNicknameRequest(nickname: '名前'));
      expectRoundTrip(
        ExplainNearbyRequest(
          playSessionId: uuid,
          positionX: 1,
          positionZ: 2,
          yawDegrees: 3,
          locale: 'ja-JP',
        ),
      );
    });

    test('UuidValue と enum が値のまま往復する', () {
      final back = roundTrip<CreatePlaySessionRequest>(
        CreatePlaySessionRequest(
          revisionId: 2,
          mode: PlayMode.near,
          requestId: uuid,
        ),
      );
      expect(back.requestId, uuid);
      expect(back.mode, PlayMode.near);
    });
  });

  group('Response', () {
    test('ListChallengesResponse（空も往復する）', () {
      expectRoundTrip(
        ListChallengesResponse(challenges: [Challenge(id: 1, title: 't')]),
      );
      expect(
        roundTrip<ListChallengesResponse>(
          ListChallengesResponse(challenges: []),
        ).challenges,
        isEmpty,
      );
    });

    test('SubmitShotResponse', () {
      final response = SubmitShotResponse(
        shot: shot(),
        reveal: reveal(),
        myRankingEntry: entry(),
      );
      expectRoundTrip(response);
      expect(roundTrip<SubmitShotResponse>(response).shot.id, 7);
    });

    test('ListRankingEntriesResponse', () {
      expectRoundTrip(ListRankingEntriesResponse(entries: [entry(), entry()]));
      expect(
        roundTrip<ListRankingEntriesResponse>(
          ListRankingEntriesResponse(entries: []),
        ).entries,
        isEmpty,
      );
    });
  });

  group('ApiException', () {
    test('すべての項目が往復する', () {
      final back = roundTrip<ApiException>(
        ApiException(
          code: ApiErrorCode.resourceExhausted,
          reason: ApiErrorReasons.sessionRateLimited,
          message: 'm',
          retryAfterSeconds: 30,
          fieldViolations: [FieldViolation(field: 'nickname', reason: 'EMPTY')],
        ),
      );
      expect(back.code, ApiErrorCode.resourceExhausted);
      expect(back.reason, 'SESSION_RATE_LIMITED');
      expect(back.retryAfterSeconds, 30);
      expect(back.fieldViolations!.single.field, 'nickname');
    });

    test('nullable の項目は省略できる', () {
      final back = roundTrip<ApiException>(
        ApiException(
          code: ApiErrorCode.internal,
          reason: ApiErrorReasons.internal,
          message: 'm',
        ),
      );
      expect(back.retryAfterSeconds, isNull);
      expect(back.fieldViolations, isNull);
    });

    test('例外として投げて捕まえられる', () {
      expect(
        () => throw ApiException(
          code: ApiErrorCode.notFound,
          reason: ApiErrorReasons.challengeNotFound,
          message: 'm',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ApiErrorReasons', () {
    test('仕様書の表のとおり 23 個で、重複しない', () {
      expect(ApiErrorReasons.all, hasLength(23));
      expect(ApiErrorReasons.all.toSet(), hasLength(23));
    });

    test('定数名と値が対応する（UPPER_SNAKE_CASE）', () {
      expect(ApiErrorReasons.invalidNickname, 'INVALID_NICKNAME');
      expect(ApiErrorReasons.profileNotInitialized, 'PROFILE_NOT_INITIALIZED');
      expect(ApiErrorReasons.requestIdReused, 'REQUEST_ID_REUSED');
      expect(ApiErrorReasons.schemaTooNew, 'SCHEMA_TOO_NEW');
      for (final reason in ApiErrorReasons.all) {
        expect(reason, matches(RegExp(r'^[A-Z]+(_[A-Z]+)*$')));
      }
    });
  });

  group('enum', () {
    test('未知の値は unknown になる', () {
      expect(protocol.deserialize<PlayMode>('future'), PlayMode.unknown);
      expect(
        protocol.deserialize<PlaySessionState>('future'),
        PlaySessionState.unknown,
      );
      expect(
        protocol.deserialize<ApiErrorCode>('future'),
        ApiErrorCode.unknown,
      );
    });

    test('GuideAudioUnavailableReason の既定は UNKNOWN', () {
      expect(
        protocol.deserialize<GuideAudioUnavailableReason>('future'),
        GuideAudioUnavailableReason.UNKNOWN,
      );
    });

    test('既知の値は名前で往復する', () {
      expect(SerializationManager.encode(PlayMode.near), '"near"');
      expect(
        SerializationManager.encode(GuideAudioUnavailableReason.TTS_FAILED),
        '"TTS_FAILED"',
      );
      for (final v in PlayMode.values) {
        expect(roundTrip<PlayMode>(v), v);
      }
      for (final v in GuideAudioUnavailableReason.values) {
        expect(roundTrip<GuideAudioUnavailableReason>(v), v);
      }
    });

    test('値の一覧が仕様書のとおり', () {
      expect(PlayMode.values.map((e) => e.name), ['unknown', 'free', 'near']);
      expect(PlaySessionState.values.map((e) => e.name), [
        'unknown',
        'active',
        'completed',
      ]);
      expect(ApiErrorCode.values.map((e) => e.name), [
        'unknown',
        'invalidArgument',
        'notFound',
        'alreadyExists',
        'permissionDenied',
        'failedPrecondition',
        'resourceExhausted',
        'unavailable',
        'internal',
      ]);
      expect(GuideAudioUnavailableReason.values.map((e) => e.name), [
        'UNKNOWN',
        'TTS_FAILED',
        'AUDIO_TIMEOUT',
        'TEXT_FALLBACK',
      ]);
    });
  });

  group('NearbyGuideEvent（sealed）', () {
    final events = <NearbyGuideEvent>[
      GuideText(
        guideId: uuid,
        text: '本文',
        structures: ['a', 'b'],
        sources: [GuideSource(title: 't', url: 'https://example.com')],
        aiGenerated: true,
      ),
      GuideAudioChunk(
        guideId: uuid,
        sequence: 0,
        data: ByteData.sublistView(Uint8List.fromList([1, 2, 3])),
        contentType: 'audio/wav',
        last: true,
      ),
      GuideAudioUnavailable(
        guideId: uuid,
        reason: GuideAudioUnavailableReason.TEXT_FALLBACK,
      ),
    ];

    test('すべてのサブ型が NearbyGuideEvent として往復し、型が保たれる', () {
      final backs = [for (final e in events) roundTrip<NearbyGuideEvent>(e)];
      expect(backs[0], isA<GuideText>());
      expect(backs[1], isA<GuideAudioChunk>());
      expect(backs[2], isA<GuideAudioUnavailable>());
      for (final b in backs) {
        expect(b.guideId, uuid);
      }
    });

    test('GuideText の項目', () {
      final back = roundTrip<NearbyGuideEvent>(events[0]) as GuideText;
      expect(back.text, '本文');
      expect(back.structures, ['a', 'b']);
      expect(back.sources.single.title, 't');
      expect(back.aiGenerated, isTrue);
    });

    test('GuideAudioChunk の ByteData は Base64 で往復する', () {
      final json = SerializationManager.encode(events[1]);
      expect(jsonDecode(json)['data'], isA<String>());
      final back = roundTrip<NearbyGuideEvent>(events[1]) as GuideAudioChunk;
      expect(back.data.buffer.asUint8List(), [1, 2, 3]);
      expect(back.sequence, 0);
      expect(back.contentType, 'audio/wav');
      expect(back.last, isTrue);
    });

    test('GuideAudioUnavailable の未知の reason は UNKNOWN', () {
      final json = jsonDecode(
        SerializationManager.encode(events[2]),
      ) as Map<String, dynamic>;
      json['reason'] = 'FUTURE_REASON';
      final back = protocol.deserialize<NearbyGuideEvent>(json);
      expect(
        (back as GuideAudioUnavailable).reason,
        GuideAudioUnavailableReason.UNKNOWN,
      );
    });

    test('switch がすべてのサブ型を網羅できる', () {
      String name(NearbyGuideEvent e) => switch (e) {
        GuideText() => 'text',
        GuideAudioChunk() => 'chunk',
        GuideAudioUnavailable() => 'unavailable',
      };
      expect(events.map(name), ['text', 'chunk', 'unavailable']);
    });
  });

  group('公開しない情報', () {
    test('ChallengeRevision は正解・解説・開始候補・モデル素材参照を持たない', () {
      final json = ChallengeRevision(
        id: 1,
        challengeId: 1,
        sceneProfile: 's',
        photo: asset(),
        photoAlt: 'a',
        map: VenueMap(
          image: asset(),
          bounds: MapBounds(minX: 0, minZ: 0, maxX: 1, maxZ: 1),
          landmarks: [],
        ),
        modes: [],
        eyeHeightMeters: 1.6,
        shotVerticalFovDegrees: 60,
        credits: [],
      ).toJson();
      for (final secret in [
        'goal',
        'goalCamera',
        'story',
        'highlight',
        'spawnPoints',
        'secrets',
        'model',
      ]) {
        expect(json.keys, isNot(contains(secret)));
      }
      final restored = Protocol().deserialize<ChallengeRevision>(json);
      expect(restored.sceneProfile, 's');
    });

    test('active の PlaySession は結果の項目を null で返す', () {
      final json = PlaySession(
        id: uuid,
        revisionId: 1,
        mode: PlayMode.free,
        spawnPointId: 1,
        spawn: Spawn(positionX: 0, positionY: 0, positionZ: 0, yawDegrees: 0),
        state: PlaySessionState.active,
        createTime: t0,
        expireTime: t0,
      ).toJson();
      expect(json['shot'], isNull);
      expect(json['reveal'], isNull);
    });
  });
}
