import 'dart:math';

import 'package:photohunt_server/src/application/usecase/ensure_user_profile.dart';
import 'package:photohunt_server/src/application/usecase/get_my_profile.dart';
import 'package:photohunt_server/src/application/usecase/update_nickname.dart';
import 'package:photohunt_server/src/domain/repositories/auth_account_repository.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/user_profile.dart';
import 'package:photohunt_server/src/domain/repositories/user_profile_repository.dart';
import 'package:photohunt_server/src/domain/services/nickname.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('ニックネーム', () {
    test('初期名は旅人とゼロ埋め4桁で、重複は許容する', () {
      for (var seed = 0; seed < 100; seed++) {
        expect(generateInitialNickname(Random(seed)), matches(r'^旅人[0-9]{4}$'));
      }
      expect(
        generateInitialNickname(Random(42)),
        generateInitialNickname(Random(42)),
      );
    });
    test('書式文字と不正なサロゲートを拒否する', () {
      for (final code in [
        0xad,
        0x200b,
        0x200c,
        0x200e,
        0x200f,
        0x202a,
        0x202e,
        0x2066,
        0x2069,
        0xfeff,
      ]) {
        expect(
          () => normalizeNickname('旅${String.fromCharCode(code)}人'),
          throwsA(
            isA<InvalidNicknameException>().having(
              (e) => e.reason,
              'reason',
              'FORMAT_CHARACTER',
            ),
          ),
        );
      }
      for (final units in [
        [0xd800],
        [0xdc00],
        [0xd800, 0x61],
        [0xdc00, 0xd800],
      ]) {
        expect(
          () => normalizeNickname(String.fromCharCodes(units)),
          throwsA(
            isA<InvalidNicknameException>().having(
              (e) => e.reason,
              'reason',
              'INVALID_UNICODE',
            ),
          ),
        );
      }
    });
    test('ZWJ・結合文字・異体字セレクタだけの名前を拒否し、絵文字内では保持する', () {
      for (final input in ['\u200d', '\u0301', '\ufe0f', ' \u200d\ufe0e ']) {
        expect(
          () => normalizeNickname(input),
          throwsA(isA<InvalidNicknameException>()),
        );
      }
      expect(normalizeNickname('❤\ufe0f'), '❤\ufe0f');
      expect(normalizeNickname('❤\ufe0e'), '❤\ufe0e');
    });
    test('空白に見えるフィラーだけの名前を拒否する', () {
      for (final filler in ['\u115f', '\u1160', '\u2800', '\u3164', '\uffa0']) {
        expect(
          () => normalizeNickname(' $filler\u0301 '),
          throwsA(isA<InvalidNicknameException>()),
        );
        expect(normalizeNickname('旅$filler'), '旅$filler');
      }
    });
    test('タグ文字を使うサブディビジョン旗は対象外', () {
      expect(
        () => normalizeNickname(
          '\u{1f3f4}\u{e0067}\u{e0062}\u{e0065}\u{e006e}\u{e0067}\u{e007f}',
        ),
        throwsA(isA<InvalidNicknameException>()),
      );
    });
    test('書記素数に関係なく512 code unitsを上限とする', () {
      final boundary = 'a${'\u0301' * 511}';
      expect(normalizeNickname(boundary), boundary);
      for (final length in [512, 100000]) {
        expect(
          () => normalizeNickname('a${'\u0301' * length}'),
          throwsA(
            isA<InvalidNicknameException>().having(
              (e) => e.reason,
              'reason',
              'TOO_LONG_CODE_UNITS',
            ),
          ),
        );
      }
    });
    test('前後の空白を除く', () {
      expect(normalizeNickname('　 旅人　 '), '旅人');
    });
    test('20書記素まで受け付け、21書記素は拒否する', () {
      for (final grapheme in ['あ', '👨‍👩‍👧‍👦', 'e\u0301']) {
        expect(normalizeNickname(grapheme * 20), grapheme * 20);
        expect(
          () => normalizeNickname(grapheme * 21),
          throwsA(
            isA<InvalidNicknameException>().having(
              (e) => e.reason,
              'reason',
              'TOO_LONG',
            ),
          ),
        );
      }
    });
    test('空白のみは拒否する', () {
      expect(
        () => normalizeNickname('　 '),
        throwsA(
          isA<InvalidNicknameException>().having(
            (e) => e.reason,
            'reason',
            'EMPTY',
          ),
        ),
      );
    });
    test('前後も含め改行・制御文字・Unicode改行を拒否する', () {
      for (final control in [
        '\n',
        '\r',
        '\t',
        '\u0000',
        '\u007f',
        '\u0085',
        '\u2028',
        '\u2029',
      ]) {
        for (final value in ['$control旅人', '旅$control人', '旅人$control']) {
          expect(
            () => normalizeNickname(value),
            throwsA(
              isA<InvalidNicknameException>().having(
                (e) => e.reason,
                'reason',
                'CONTROL_CHARACTER',
              ),
            ),
          );
        }
      }
    });
  });

  group('プロフィール', () {
    final userId = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
    late _Repository repository;
    late EnsureUserProfile ensure;
    late _Accounts accounts;
    late GetMyProfile get;
    late UpdateNickname update;
    setUp(() {
      repository = _Repository();
      accounts = _Accounts();
      get = GetMyProfile(repository, accounts);
      update = UpdateNickname(repository, accounts);
      ensure = EnsureUserProfile(
        repository,
        createNickname: () => '旅人0042',
        now: () => DateTime.utc(2026, 11, 8),
      );
    });
    test('認証フローで作成し、繰り返しても同じ行を返す', () async {
      final first = await ensure.execute(userId);
      final second = await ensure.execute(userId);
      expect(first.nickname, '旅人0042');
      expect(first.createdAt.isUtc, isTrue);
      expect(second.id, first.id);
      expect(repository.inserts, 1);
    });
    test('認証主体の一意制約の競合だけ既存行で復旧する', () async {
      repository.conflict = true;
      final result = await ensure.execute(userId);
      expect(result.nickname, '先に作成済み');
      expect(repository.inserts, 1);
    });
    test('別の制約違反を握りつぶさない', () async {
      repository.otherConflict = true;
      await expectLater(
        ensure.execute(userId),
        throwsA(isA<DuplicateEntityException>()),
      );
    });
    test('getは欠落しても行を作成しない', () async {
      await expectLater(
        get.execute(userId),
        throwsA(isA<ProfileMissingException>()),
      );
      expect(repository.inserts, 0);
    });
    test('updateも欠落プロフィールを作成しない', () async {
      await expectLater(
        update.execute(userId, '新しい旅人'),
        throwsA(isA<ProfileMissingException>()),
      );
      expect(repository.inserts, 0);
      expect(repository.updates, 0);
      expect(accounts.reads, 0);
    });
    test('不正な入力はDBへアクセスする前に拒否する', () async {
      await expectLater(
        update.execute(userId, ' '),
        throwsA(isA<InvalidNicknameException>()),
      );
      expect(repository.reads, 0);
      expect(repository.updates, 0);
      expect(accounts.reads, 0);
    });
    test('匿名判定をポート経由で返す', () async {
      await ensure.execute(userId);
      expect((await get.execute(userId)).anonymous, isTrue);
      accounts.anonymous = false;
      expect((await get.execute(userId)).anonymous, isFalse);
      expect((await update.execute(userId, '登録済み')).anonymous, isFalse);
      expect(accounts.reads, 3);
    });
    test('改名でのプロフィール取得・更新・匿名判定はそれぞれ1回', () async {
      await ensure.execute(userId);
      repository.reads = 0;
      await update.execute(userId, '変更後');
      expect(repository.reads, 1);
      expect(repository.updates, 1);
      expect(accounts.reads, 1);
    });
    test('同じ名前の再設定は成功し、不要な更新をしない', () async {
      await ensure.execute(userId);
      expect((await update.execute(userId, '　旅人0042 ')).nickname, '旅人0042');
      expect(repository.updates, 0);
      expect((await update.execute(userId, '新しい旅人')).nickname, '新しい旅人');
      expect(repository.updates, 1);
    });
  });
}

class _Repository() implements UserProfileRepository {
  UserProfile? row;
  var reads = 0;
  var inserts = 0;
  var updates = 0;
  var conflict = false;
  var otherConflict = false;

  @override
  Future<UserProfile?> findByAuthUserId(UuidValue id) async {
    reads++;
    return row;
  }

  @override
  Future<UserProfile> insert(UserProfile profile) async {
    inserts++;
    if (otherConflict) {
      throw const DuplicateEntityException(
        entity: 'other',
        constraint: 'other',
      );
    }
    final saved = UserProfile(
      id: 1,
      authUserId: profile.authUserId,
      nickname: conflict ? '先に作成済み' : profile.nickname,
      createdAt: profile.createdAt,
    );
    row = saved;
    if (conflict) {
      throw const ProfileAlreadyExistsException();
    }
    return saved;
  }

  @override
  Future<UserProfile?> updateNickname(int id, String nickname) async {
    final current = row;
    if (current == null) return null;
    updates++;
    return row = UserProfile(
      id: current.id,
      authUserId: current.authUserId,
      nickname: nickname,
      createdAt: current.createdAt,
    );
  }
}

class _Accounts() implements AuthAccountRepository {
  var reads = 0;
  var anonymous = true;

  @override
  Future<bool> isAnonymous(UuidValue authUserId) async {
    reads++;
    return anonymous;
  }
}
