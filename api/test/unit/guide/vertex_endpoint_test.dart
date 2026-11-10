import 'package:photohunt_server/src/infrastructure/gemini/vertex_endpoint.dart';
import 'package:test/test.dart';

void main() {
  test('ロケーションごとに、Interactions と generateContent の URL を作る', () {
    for (final (location, host) in [
      (VertexLocation.global, 'aiplatform.googleapis.com'),
      (VertexLocation.us, 'aiplatform.us.rep.googleapis.com'),
      (VertexLocation.eu, 'aiplatform.eu.rep.googleapis.com'),
    ]) {
      final vertex = VertexEndpoint(project: 'my-project', location: location);
      final l = location.name;
      expect(
        vertex.interactions.toString(),
        'https://$host/v1/projects/my-project/locations/$l/interactions',
      );
      expect(
        vertex.generateContent('gemini-3.8-flash-lite-tts').toString(),
        'https://$host/v1/projects/my-project/locations/$l/publishers/google/'
        'models/gemini-3.8-flash-lite-tts:generateContent',
      );
    }
  });

  test('設定値は global・us・eu だけを読む', () {
    expect(VertexLocation.parse('global'), VertexLocation.global);
    expect(VertexLocation.parse('us'), VertexLocation.us);
    expect(VertexLocation.parse('eu'), VertexLocation.eu);
    expect(VertexLocation.parse('asia-northeast1'), isNull);
    expect(VertexLocation.parse('GLOBAL'), isNull);
  });
}
