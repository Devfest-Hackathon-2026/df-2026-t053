/// Serverpod の認証の秘密。器だけを作り、値（版）は人が `gcloud secrets versions add` で入れる。
library;

import 'package:terradart_google/secret_manager.dart';

import 'env.dart';

/// Cloud Run に注入する secret。環境変数名は `api/config/passwords.yaml.example` のとおり。
enum ServerpodSecret({
  required final String secretId,
  required final String variable,
}) {
  jwtHmacKey(
    secretId: 'serverpod-jwt-hmac-key',
    variable: 'SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey',
  ),
  jwtRefreshPepper(
    secretId: 'serverpod-jwt-refresh-pepper',
    variable: 'SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper',
  );

  /// Cloud Run と Job が参照する版（Env で固定する）。
  int versionIn(Env env) => switch (this) {
    jwtHmacKey => env.jwtHmacKeyVersion,
    jwtRefreshPepper => env.jwtRefreshPepperVersion,
  };
}

GoogleSecretManagerSecret buildSecret(ServerpodSecret secret) =>
    GoogleSecretManagerSecret(
      secret.name,
      secretId: .literal(secret.secretId),
      replication: const .auto(.new()),
      labels: .literal({'app': 'photohunt'}),
    );

GoogleSecretManagerSecretIamMember buildSecretAccessor({
  required ServerpodSecret secret,
  required GoogleSecretManagerSecret resource,
  required String accessorName,
  required String serviceAccountEmail,
}) => GoogleSecretManagerSecretIamMember(
  '${secret.name}_$accessorName',
  secret: resource.ref,
  role: .literal('roles/secretmanager.secretAccessor'),
  member: .serviceAccount(serviceAccountEmail),
);
