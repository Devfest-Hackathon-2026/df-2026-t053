import 'package:photohunt_server/src/infrastructure/config/runtime_environment.dart';
import 'package:test/test.dart';

void main() {
  test('Cloud Runの識別子が未設定・空文字ならローカルとして扱う', () {
    expect(isCloudRun({}), isFalse);
    expect(isCloudRun({'K_SERVICE': '', 'CLOUD_RUN_JOB': ''}), isFalse);
  });

  for (final key in ['K_SERVICE', 'CLOUD_RUN_JOB']) {
    test('$keyが空でなければCloud Runとして扱い、emulatorをローカル扱いしない', () {
      final env = {key: 'runtime', 'STORAGE_EMULATOR_HOST': 'http://gcs:4443'};
      expect(isCloudRun(env), isTrue);
      expect(isLocalEmulator(env), isFalse);
    });
  }

  test('ローカルでもemulatorの指定がなければ緩和しない', () {
    expect(isLocalEmulator({}), isFalse);
    expect(isLocalEmulator({'STORAGE_EMULATOR_HOST': ''}), isFalse);
    expect(
      isLocalEmulator({'STORAGE_EMULATOR_HOST': 'http://gcs:4443'}),
      isTrue,
    );
    expect(
      isLocalEmulator({
        'K_SERVICE': '',
        'CLOUD_RUN_JOB': '',
        'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
      }),
      isTrue,
    );
  });

  test('未知・空のrun modeも配備環境として厳しく検証する', () {
    expect(isDeployedRunMode('custom'), isTrue);
    expect(isDeployedRunMode(''), isTrue);
  });
}
