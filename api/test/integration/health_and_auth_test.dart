import 'dart:io';

import 'package:photohunt_client/photohunt_client.dart';
import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/infrastructure/auth/profile_repairing_jwt.dart';
import 'package:photohunt_server/src/generated/protocol.dart'
    show UserProfileRow;
import 'package:photohunt_server/src/infrastructure/config/anonymous_signup_settings.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:serverpod_auth_idp_server/core.dart' as auth_server;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        AnonymousAccountBlockedException,
        AnonymousAccountBlockedExceptionReason,
        RefreshTokenInvalidSecretException,
        RefreshTokenNotFoundException,
        RefreshTokenExpiredException;
import 'package:test/test.dart';

/// Authorization ヘッダーに JWT を載せるだけの最小の provider。
class _BearerProvider() implements ClientAuthKeyProvider {
  String? token;

  @override
  Future<String?> get authHeaderValue async =>
      token == null ? null : wrapAsBearerAuthHeaderValue(token!);
}

/// 実サーバーを test モード（SQLite）で起動し、生成 client から呼ぶ。
void main() {
  Serverpod? pod;
  Client? testClient;
  Client client() => testClient!;
  final auth = _BearerProvider();
  String? refreshToken;
  String? secondRefreshToken;

  setUpAll(() async {
    final dbFile = File('data/test.sqlite');
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('${dbFile.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    pod = createServer([
      '--mode',
      'test',
      '--apply-migrations',
    ], anonymousSignupSettings: const AnonymousSignupSettings(limitPerHour: 2));
    await pod!.start();
    testClient = Client('http://localhost:8180/')..authKeyProvider = auth;
  });

  tearDownAll(() async {
    testClient?.close();
    await pod?.shutdown(exitProcess: false);
  });

  test('health.ping は認証なしで成功する', () async {
    final response = await client().health.ping(HealthRequest());
    expect(response.releaseId, isNotEmpty);
    expect(response.time.isUtc, isTrue);
  });

  test('匿名ログインで JWT が発行される', () async {
    final success = await client().anonymousIdp.login();
    auth.token = success.token;
    refreshToken = success.refreshToken;
    expect(success.token, isNotEmpty);
  });

  // 業務 endpoint の未認証の拒否（ServerpodClientUnauthorized）と、型付きの ApiException は
  // challenge_api_test.dart で確かめる。

  test('認証主体ごとに初期プロフィールは1行で、内部IDは公開しない', () async {
    final first = await client().profile.getMyProfile(GetMyProfileRequest());
    final second = await client().profile.getMyProfile(GetMyProfileRequest());
    expect(first.nickname, matches(RegExp(r'^旅人[0-9]{4}$')));
    expect(second.nickname, first.nickname);
    expect(first.anonymous, isTrue);
    expect(first.toJson().keys.toSet(), {
      '__className__',
      'nickname',
      'anonymous',
    });
    await pod!.withSession((session) async {
      expect(await UserProfileRow.db.count(session), 1);
    });
  });

  test('ニックネームの更新と型付き入力エラー', () async {
    final changed = await client().profile.updateNickname(
      UpdateNicknameRequest(nickname: '　新しい旅人 '),
    );
    expect(changed.nickname, '新しい旅人');
    expect(
      (await client().profile.updateNickname(
        UpdateNicknameRequest(nickname: '新しい旅人'),
      )).nickname,
      '新しい旅人',
    );
    for (final name in [
      ' ',
      'あ' * 21,
      '名前\n',
      '名\u200b前',
      'a${'\u0301' * 512}',
    ]) {
      await expectLater(
        client().profile.updateNickname(UpdateNicknameRequest(nickname: name)),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.invalidArgument)
              .having((e) => e.reason, 'reason', 'INVALID_NICKNAME')
              .having(
                (e) => e.fieldViolations?.single.field,
                'field',
                'nickname',
              ),
        ),
      );
    }
    expect(
      (await client().profile.getMyProfile(GetMyProfileRequest())).nickname,
      '新しい旅人',
    );
  });

  test('プロフィールAPIは未認証を拒否する', () async {
    final saved = auth.token;
    auth.token = null;
    try {
      await expectLater(
        client().profile.getMyProfile(GetMyProfileRequest()),
        throwsA(isA<ServerpodClientUnauthorized>()),
      );
      await expectLater(
        client().profile.updateNickname(UpdateNicknameRequest(nickname: '旅人')),
        throwsA(isA<ServerpodClientUnauthorized>()),
      );
    } finally {
      auth.token = saved;
    }
  });

  test('トークン更新は同じ認証主体のまま名前を維持し、欠落プロフィールを復旧する', () async {
    await pod!.withSession((session) async {
      final jwt = ProfileRepairingJwt(
        delegate:
            auth_server
                    .AuthServices.getTokenManager<auth_server.JwtTokenManager>()
                .jwt,
        ensureProfile: (_, _, _) async => throw StateError('復旧失敗のテスト'),
      );
      final credential = refreshToken;
      if (credential == null) fail('更新トークンが必要です');
      await session.db.transaction((tx) async {
        await expectLater(
          jwt.refreshAccessToken(
            session,
            refreshToken: credential,
            transaction: tx,
          ),
          throwsArgumentError,
        );
      });
      await expectLater(
        jwt.refreshAccessToken(session, refreshToken: credential),
        throwsStateError,
      );
    });
    // 復旧に失敗しても、同じ更新トークンで再試行できる。
    final refreshed = await client().jwtRefresh.refreshAccessToken(
      refreshToken: refreshToken,
    );
    auth.token = refreshed.token;
    refreshToken = refreshed.refreshToken;
    expect(
      (await client().profile.getMyProfile(GetMyProfileRequest())).nickname,
      '新しい旅人',
    );
    await pod!.withSession((session) async {
      await UserProfileRow.db.deleteWhere(
        session,
        where: (t) => t.authUserId.equals(refreshed.authUserId),
      );
    });
    await expectLater(
      client().profile.getMyProfile(GetMyProfileRequest()),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.failedPrecondition)
            .having((e) => e.reason, 'reason', 'PROFILE_NOT_INITIALIZED')
            .having((e) => e.retryAfterSeconds, 'retryAfterSeconds', isNull),
      ),
    );
    await expectLater(
      client().profile.updateNickname(UpdateNicknameRequest(nickname: '復旧しない')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.reason,
          'reason',
          'PROFILE_NOT_INITIALIZED',
        ),
      ),
    );
    await pod!.withSession((session) async {
      expect(await UserProfileRow.db.count(session), 0);
    });
    final recovered = await client().jwtRefresh.refreshAccessToken(
      refreshToken: refreshToken,
    );
    auth.token = recovered.token;
    refreshToken = recovered.refreshToken;
    expect(recovered.authUserId, refreshed.authUserId);
    expect(
      (await client().profile.getMyProfile(GetMyProfileRequest())).nickname,
      matches(RegExp(r'^旅人[0-9]{4}$')),
    );
    await pod!.withSession((session) async {
      expect(await UserProfileRow.db.count(session), 1);
    });
  });

  test('上限を超えた匿名作成を拒否し、余分なプロフィールを作らない', () async {
    auth.token = null;
    secondRefreshToken = (await client().anonymousIdp.login()).refreshToken;
    await expectLater(
      client().anonymousIdp.login(),
      throwsA(
        isA<AnonymousAccountBlockedException>().having(
          (e) => e.reason,
          'reason',
          AnonymousAccountBlockedExceptionReason.tooManyAttempts,
        ),
      ),
    );
    await pod!.withSession((session) async {
      expect(await UserProfileRow.db.count(session), 2);
    });
    // 任意の代理ヘッダーで、同一接続元の制限をリセットできない。
    final http = HttpClient();
    try {
      final request = await http.postUrl(
        Uri.parse('http://localhost:8180/anonymousIdp/login'),
      );
      request.headers.contentType = ContentType.json;
      request.headers.set('X-Forwarded-For', '203.0.113.1');
      request.write('{}');
      final response = await request.close();
      expect(response.statusCode, isNot(200));
      await response.drain<void>();
    } finally {
      http.close(force: true);
    }
  });

  test('古い更新トークンの再利用による失効はrollbackしない', () async {
    final original = refreshToken;
    final rotated = await client().jwtRefresh.refreshAccessToken(
      refreshToken: original,
    );
    await expectLater(
      client().jwtRefresh.refreshAccessToken(refreshToken: original),
      throwsA(isA<RefreshTokenInvalidSecretException>()),
    );
    await expectLater(
      client().jwtRefresh.refreshAccessToken(
        refreshToken: rotated.refreshToken,
      ),
      throwsA(isA<RefreshTokenNotFoundException>()),
    );
  });

  test('期限切れ更新トークンの削除はrollbackしない', () async {
    await pod!.withSession((session) async {
      final tokens = await auth_server.RefreshToken.db.find(session);
      expect(tokens, hasLength(1));
      await auth_server.RefreshToken.db.updateRow(
        session,
        tokens.single.copyWith(lastUpdatedAt: DateTime.utc(2000)),
        columns: (t) => [t.lastUpdatedAt],
      );
    });
    await expectLater(
      client().jwtRefresh.refreshAccessToken(refreshToken: secondRefreshToken),
      throwsA(isA<RefreshTokenExpiredException>()),
    );
    await pod!.withSession((session) async {
      expect(await auth_server.RefreshToken.db.count(session), 0);
    });
  });
}
