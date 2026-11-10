/// 配備のたびに変わる値。Terraform 変数にはせず、`bin/infra.dart` が環境変数から読んで
/// Stack へ渡す（docs/infrastructure.md 5.3）。
library;

import 'env.dart';

final class const Release({
  required final String apiImage,
  required final String releaseId,
  required final bool maintenanceMode,
}) {
  /// 環境変数 `API_IMAGE`・`RELEASE_ID`・`MAINTENANCE_MODE` を読む。
  ///
  /// 不正な値は [ReleaseException] にする。synth の時点で止め、plan・apply に進ませない。
  factory fromEnvironment(Map<String, String> environment, Env env) {
    String? read(String key) {
      final value = environment[key]?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    final apiImage = read('API_IMAGE');
    if (apiImage == null) {
      throw const ReleaseException(
        'API_IMAGE を指定する（稼働中の digest か、新しくビルドした digest）',
      );
    }
    final imagePattern = RegExp(
      '^${RegExp.escape(env.imageRepository)}/api@sha256:[0-9a-f]{64}\$',
    );
    if (!imagePattern.hasMatch(apiImage)) {
      throw ReleaseException(
        'API_IMAGE は ${env.imageRepository}/api@sha256:<64桁> の digest 指定にする（タグは使わない）: $apiImage',
      );
    }

    final releaseId = read('RELEASE_ID');
    if (releaseId == null || !RegExp(r'^[0-9a-f]{7,40}$').hasMatch(releaseId)) {
      throw ReleaseException(
        'RELEASE_ID はコミット SHA にする: ${releaseId ?? '(未設定)'}',
      );
    }

    final bool maintenanceMode;
    switch (read('MAINTENANCE_MODE')) {
      case null || 'false':
        maintenanceMode = false;
      case 'true':
        maintenanceMode = true;
      case final other:
        throw ReleaseException('MAINTENANCE_MODE は true か false にする: $other');
    }

    return Release(
      apiImage: apiImage,
      releaseId: releaseId,
      maintenanceMode: maintenanceMode,
    );
  }

  /// 資格情報なしの検査（`mise check` の validate）用の値。plan・apply には使わない。
  factory placeholder(Env env) => Release(
    apiImage: '${env.imageRepository}/api@sha256:${'0' * 64}',
    releaseId: '0' * 40,
    maintenanceMode: false,
  );
}

final class const ReleaseException(final String message) implements Exception {
  @override
  String toString() => message;
}
