import 'package:serverpod/serverpod.dart' show ServerpodRunMode;

/// サービス・Job のどちらも、Cloud Run が渡す識別子が空でなければ実行環境とみなす。
bool isCloudRun(Map<String, String> env) =>
    (env['K_SERVICE'] ?? '').isNotEmpty ||
    (env['CLOUD_RUN_JOB'] ?? '').isNotEmpty;

/// Cloud Run 外で GCS エミュレーターを指定した環境だけをローカルとみなす。
bool isLocalEmulator(Map<String, String> env) =>
    !isCloudRun(env) && (env['STORAGE_EMULATOR_HOST'] ?? '').isNotEmpty;

/// development・test 以外（未知のモードを含む）は配備環境として厳しく検証する。
bool isDeployedRunMode(String mode) =>
    mode != ServerpodRunMode.development && mode != ServerpodRunMode.test;
