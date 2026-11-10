import 'dart:async';

import 'package:app/model/profile/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/profile/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_client/serverpod_client.dart';

import '../../support/api_client.dart';

ApiException missing() => ApiException(
  code: .failedPrecondition,
  reason: 'PROFILE_NOT_INITIALIZED',
  message: '内部説明',
);

ProfileNotifier connect([TestApiClient? client]) {
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(
        client ??
            TestApiClient(
              getProfile: (_) async =>
                  throw ServerpodClientNetworkException('offline'),
              setNickname: (_) async =>
                  throw ServerpodClientNetworkException('offline'),
              refreshAuthentication: () async => fail('通信失敗で更新しない'),
            ),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(profileProvider, (_, _) {});
  return container.read(profileProvider.notifier);
}

void main() {
  for (final save in [false, true]) {
    testWidgets('${save ? '保存' : '取得'}の認証更新も10秒で打ち切り、遅い完了から再送しない', (
      tester,
    ) async {
      final refresh = Completer<RefreshAuthKeyResult>();
      final authentication = PendingAuthentication(refresh.future);
      var calls = 0;
      Future<Profile> request() async {
        calls++;
        throw missing();
      }

      final notifier = connect(
        TestApiClient(
          getProfile: (_) => request(),
          setNickname: (_) => request(),
          refreshAuthentication: () async => fail('専用の認証ダブルを使う'),
        )..authKeyProvider = authentication,
      );
      final pending = save
          ? notifier.updateNickname('新しい名前')
          : notifier.getMyProfile();
      final check = expectLater(
        pending,
        throwsA(
          isA<ProfileFailure>().having(
            (e) => e.kind,
            'kind',
            ProfileFailureKind.unavailable,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      await check;
      refresh.complete(.success);
      await tester.pump();
      expect(calls, 1);
      expect(authentication.forces, [true]);
    });
  }

  testWidgets('取得自体が10秒を超えた後のプロフィール欠落で認証更新しない', (tester) async {
    final response = Completer<Profile>();
    var calls = 0;
    final notifier = connect(
      TestApiClient(
        getProfile: (_) {
          calls++;
          return response.future;
        },
        setNickname: (_) async => fail('改名しない'),
        refreshAuthentication: () async => fail('期限超過後に認証更新しない'),
      ),
    );
    final check = expectLater(
      notifier.getMyProfile(),
      throwsA(
        isA<ProfileFailure>().having(
          (e) => e.kind,
          'kind',
          ProfileFailureKind.unavailable,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 10));
    await check;
    response.completeError(missing());
    await tester.pump();
    expect(calls, 1);
  });

  test('同じClientでProviderを再生成しても旧要求を再送しない', () async {
    final refresh = Completer<void>();
    var calls = 0;
    final client = TestApiClient(
      getProfile: (_) async {
        calls++;
        throw missing();
      },
      setNickname: (_) async => fail('改名しない'),
      refreshAuthentication: () => refresh.future,
    );
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    container.listen(profileProvider, (_, _) {});
    final pending = container.read(profileProvider.notifier).getMyProfile();
    final check = expectLater(pending, throwsA(isA<ProfileFailure>()));
    await Future<void>.delayed(Duration.zero);
    container.invalidate(profileProvider);
    await container.pump();
    refresh.complete();
    await check;
    expect(calls, 1);
  });

  test('標準の未認証例外を通信失敗と区別する', () async {
    final notifier = connect(
      TestApiClient(
        getProfile: (_) async => throw ServerpodClientUnauthorized(),
        setNickname: (_) async => fail('改名しない'),
        refreshAuthentication: () async => fail('SDKが扱う未認証をここでは再試行しない'),
      ),
    );
    await expectLater(
      notifier.getMyProfile(),
      throwsA(
        isA<ProfileFailure>().having(
          (e) => e.kind,
          'kind',
          ProfileFailureKind.authentication,
        ),
      ),
    );
  });
  test('未接続では架空の名前や保存成功を返さない', () async {
    final notifier = connect();
    await expectLater(notifier.getMyProfile(), throwsA(isA<ProfileFailure>()));
    await expectLater(
      notifier.updateNickname('名前'),
      throwsA(isA<ProfileFailure>()),
    );
  });

  test('公開DTOの要求を渡し、サーバーのプロフィールを返す', () async {
    final requests = <UpdateNicknameRequest>[];
    final profile = Profile(nickname: '旅人0042', anonymous: true);
    final notifier = connect(
      TestApiClient(
        getProfile: (request) async {
          expect(request, isA<GetMyProfileRequest>());
          return profile;
        },
        setNickname: (request) async {
          requests.add(request);
          return profile;
        },
        refreshAuthentication: () async => fail('通常は認証更新しない'),
      ),
    );
    expect(await notifier.getMyProfile(), same(profile));
    expect(await notifier.updateNickname('新しい旅人'), same(profile));
    expect(requests.single.nickname, '新しい旅人');
  });

  test('欠落時だけ認証を一度更新し、同じ取得を再実行する', () async {
    var calls = 0;
    var refreshes = 0;
    final notifier = connect(
      TestApiClient(
        getProfile: (_) async {
          if (++calls == 1) throw missing();
          return Profile(nickname: '復旧後', anonymous: true);
        },
        setNickname: (_) async => fail('改名しない'),
        refreshAuthentication: () async {
          refreshes++;
        },
      ),
    );
    expect((await notifier.getMyProfile()).nickname, '復旧後');
    expect(calls, 2);
    expect(refreshes, 1);
  });

  test('改名の復旧でも同じ名前を再送し、再度欠落してもループしない', () async {
    var refreshes = 0;
    final requests = <String>[];
    final notifier = connect(
      TestApiClient(
        getProfile: (_) async => fail('取得しない'),
        setNickname: (request) async {
          requests.add(request.nickname);
          throw missing();
        },
        refreshAuthentication: () async {
          refreshes++;
        },
      ),
    );
    await expectLater(
      notifier.updateNickname('そのままの名前'),
      throwsA(
        isA<ProfileFailure>().having(
          (e) => e.kind,
          'kind',
          ProfileFailureKind.authentication,
        ),
      ),
    );
    expect(requests, ['そのままの名前', 'そのままの名前']);
    expect(refreshes, 1);
  });

  test('ニックネームのfieldViolationsを安全な入力エラーに変換する', () async {
    final notifier = connect(
      TestApiClient(
        getProfile: (_) async => fail('取得しない'),
        setNickname: (_) async => throw ApiException(
          code: .invalidArgument,
          reason: ApiErrorReasons.invalidNickname,
          message: '秘密の内部説明',
          fieldViolations: [
            FieldViolation(field: 'nickname', reason: 'FORMAT_CHARACTER'),
          ],
        ),
        refreshAuthentication: () async => fail('入力不備で認証更新しない'),
      ),
    );
    await expectLater(
      notifier.updateNickname('不正な名前'),
      throwsA(
        isA<ProfileFailure>()
            .having((e) => e.kind, 'kind', ProfileFailureKind.invalidNickname)
            .having(
              (e) => e.nicknameReason,
              'nicknameReason',
              'FORMAT_CHARACTER',
            ),
      ),
    );
  });

  test('通信失敗では自動再送・認証更新せず、安全なエラーにする', () async {
    var calls = 0;
    final notifier = connect(
      TestApiClient(
        getProfile: (_) async {
          calls++;
          throw TimeoutException('秘密の応答');
        },
        setNickname: (_) async => fail('改名しない'),
        refreshAuthentication: () async => fail('通信失敗で認証更新しない'),
      ),
    );
    await expectLater(
      notifier.getMyProfile(),
      throwsA(
        isA<ProfileFailure>()
            .having((e) => e.kind, 'kind', ProfileFailureKind.unavailable)
            .having((e) => e.nicknameReason, 'nicknameReason', isNull),
      ),
    );
    expect(calls, 1);
  });

  test('内部例外の詳細を失敗モデルへ含めない', () async {
    final notifier = connect(
      TestApiClient(
        getProfile: (_) async => throw StateError('秘密の値'),
        setNickname: (_) async => fail('改名しない'),
        refreshAuthentication: () async => fail('内部例外で認証更新しない'),
      ),
    );
    await expectLater(
      notifier.getMyProfile(),
      throwsA(
        isA<ProfileFailure>()
            .having((e) => e.kind, 'kind', ProfileFailureKind.rejected)
            .having((e) => e.nicknameReason, 'nicknameReason', isNull),
      ),
    );
  });
  test('認証更新機構がない場合は再送せず認証エラーにする', () async {
    var calls = 0;
    final client = TestApiClient(
      getProfile: (_) async {
        calls++;
        throw missing();
      },
      setNickname: (_) async => fail('改名しない'),
      refreshAuthentication: () async => fail('更新しない'),
    )..authKeyProvider = null;
    await expectLater(
      connect(client).getMyProfile(),
      throwsA(
        isA<ProfileFailure>().having(
          (e) => e.kind,
          'kind',
          ProfileFailureKind.authentication,
        ),
      ),
    );
    expect(calls, 1);
  });

  test('認証更新中に接続先が切り替わったら旧要求を再送しない', () async {
    final refreshed = Completer<void>();
    final refreshing = Completer<void>();
    var calls = 0;
    final old = TestApiClient(
      getProfile: (_) async {
        calls++;
        throw missing();
      },
      setNickname: (_) async => fail('改名しない'),
      refreshAuthentication: () {
        refreshing.complete();
        return refreshed.future;
      },
    );
    final next = TestApiClient(
      getProfile: (_) async => Profile(nickname: '次の利用者', anonymous: true),
      setNickname: (_) async => fail('改名しない'),
      refreshAuthentication: () async => fail('更新しない'),
    );
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(old)],
    );
    addTearDown(container.dispose);
    container.listen(profileProvider, (_, _) {});
    final pending = container.read(profileProvider.notifier).getMyProfile();
    final assertion = expectLater(pending, throwsA(isA<ProfileFailure>()));
    await refreshing.future;
    container.updateOverrides([apiClientProvider.overrideWithValue(next)]);
    await container.pump();
    refreshed.complete();
    await assertion;
    expect(calls, 1);
    expect(
      (await container.read(profileProvider.notifier).getMyProfile()).nickname,
      '次の利用者',
    );
  });
  for (final result in [
    RefreshAuthKeyResult.skipped,
    RefreshAuthKeyResult.failedUnauthorized,
    RefreshAuthKeyResult.failedOther,
  ]) {
    test('認証更新が${result.name}なら再送しない', () async {
      var calls = 0;
      final client = TestApiClient(
        getProfile: (_) async {
          calls++;
          throw missing();
        },
        setNickname: (_) async => fail('改名しない'),
        refreshAuthentication: () async => fail('別の更新機構を使う'),
      )..authKeyProvider = ResultAuthentication(result);
      await expectLater(
        connect(client).getMyProfile(),
        throwsA(
          isA<ProfileFailure>().having(
            (e) => e.kind,
            'kind',
            result == RefreshAuthKeyResult.failedOther
                ? ProfileFailureKind.unavailable
                : ProfileFailureKind.authentication,
          ),
        ),
      );
      expect(calls, 1);
    });
  }
}

class ResultAuthentication(final RefreshAuthKeyResult result)
    extends Fake
    implements RefresherClientAuthKeyProvider {
  @override
  Future<RefreshAuthKeyResult> refreshAuthKey({bool force = false}) async {
    expect(force, isTrue);
    return result;
  }
}

class PendingAuthentication(final Future<RefreshAuthKeyResult> result)
    extends Fake
    implements RefresherClientAuthKeyProvider {
  final forces = <bool>[];

  @override
  Future<RefreshAuthKeyResult> refreshAuthKey({bool force = false}) {
    forces.add(force);
    return result;
  }
}
