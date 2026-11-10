import 'dart:io';

import 'package:photohunt_server/src/infrastructure/config/anonymous_signup_settings.dart';
import 'package:test/test.dart';

void main() {
  test('直接作成した設定も同じ検証で不正な上限を拒否する', () {
    for (final limit in [0, -1]) {
      expect(
        () => AnonymousSignupSettings(limitPerHour: limit).validate(),
        throwsFormatException,
      );
    }
    expect(() => const AnonymousSignupSettings().validate(), returnsNormally);
  });
  test('Cloud Runはサービス・Jobの空でない識別子から組み立てる', () {
    expect(AnonymousSignupSettings.fromEnvironment({}).cloudRun, isFalse);
    for (final key in ['K_SERVICE', 'CLOUD_RUN_JOB']) {
      expect(
        AnonymousSignupSettings.fromEnvironment({key: 'runtime'}).cloudRun,
        isTrue,
      );
      expect(
        AnonymousSignupSettings.fromEnvironment({key: ''}).cloudRun,
        isFalse,
      );
      expect(
        () => AnonymousSignupSettings.fromEnvironment({
          key: 'runtime',
          'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
          'ANON_SIGNUP_LIMIT_PER_HOUR': '1000',
        }),
        throwsFormatException,
      );
    }
  });
  test('envサンプルの匿名作成上限は一箇所だけで定義する', () {
    final definitions = File('../infrastructure/local/.env.example')
        .readAsLinesSync()
        .where((line) => line.startsWith('ANON_SIGNUP_LIMIT_PER_HOUR='));
    expect(definitions, ['ANON_SIGNUP_LIMIT_PER_HOUR=1000']);
  });
  test('既定値は100件/時', () {
    expect(AnonymousSignupSettings.fromEnvironment({}).limitPerHour, 100);
  });
  test('不正値と本番での緩和を拒否する', () {
    for (final value in ['0', '-1', '', 'abc', '101']) {
      expect(
        () => AnonymousSignupSettings.fromEnvironment({
          'ANON_SIGNUP_LIMIT_PER_HOUR': value,
        }),
        throwsFormatException,
      );
    }
    expect(
      () => AnonymousSignupSettings.fromEnvironment({
        'ANON_SIGNUP_LIMIT_PER_HOUR': '1000',
        'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
        'K_SERVICE': 'photohunt',
      }),
      throwsFormatException,
    );
  });
  test('ローカルのemulator環境だけ制限を緩められる', () {
    expect(
      AnonymousSignupSettings.fromEnvironment({
        'ANON_SIGNUP_LIMIT_PER_HOUR': '1000',
        'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
      }).limitPerHour,
      1000,
    );
  });
}
