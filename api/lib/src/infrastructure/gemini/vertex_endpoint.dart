/// Vertex AI のロケーション（`VERTEX_LOCATION`）。Interactions と TTS モデルが使えるのは
/// この 3 つだけで、東京などの単一リージョンは使えない（docs/specs.md「モデル・本文・音声の検証」）。
enum VertexLocation(final String host) {
  global('aiplatform.googleapis.com'),
  us('aiplatform.us.rep.googleapis.com'),
  eu('aiplatform.eu.rep.googleapis.com');

  /// 設定値の文字列から読む。対応しない値なら null。
  static VertexLocation? parse(String value) =>
      values.where((l) => l.name == value).firstOrNull;
}

/// Vertex AI の送り先。プロジェクトとロケーションから URL を作る。
class const VertexEndpoint({
  required final String project,
  required final VertexLocation location,
}) {
  Uri get _base => Uri(
    scheme: 'https',
    host: location.host,
    pathSegments: ['v1', 'projects', project, 'locations', location.name],
  );

  /// 文生成で使う Interactions（`POST …/interactions`）。
  Uri get interactions =>
      _base.replace(pathSegments: [..._base.pathSegments, 'interactions']);

  /// TTS で使う generateContent（`POST …/publishers/google/models/{model}:generateContent`）。
  Uri generateContent(String model) => _base.replace(
    pathSegments: [
      ..._base.pathSegments,
      'publishers',
      'google',
      'models',
      '$model:generateContent',
    ],
  );
}
