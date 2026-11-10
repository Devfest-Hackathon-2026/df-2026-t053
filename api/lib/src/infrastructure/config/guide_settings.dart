import '../gemini/fake_guide_generators.dart';
import '../gemini/gemini_guide_text_generator.dart' show GeminiThinkingLevel;
import '../gemini/vertex_endpoint.dart';
import 'replication_settings.dart'
    show ConfigurationException, rejectEmulatorOnCloudRun;
import 'runtime_environment.dart';

enum GuideBackend() {
  fake,
  gemini,
}

/// ガイドの設定（docs/specs.md「設定値」）。値は環境変数から読み、起動時に検証する。
///
/// gemini は Vertex AI に、実行サービスアカウントの認証（ADC）で接続する。キーは使わない。
///
/// エラーメッセージには、足りない設定の名前だけを出し、値は出さない。
class const GuideSettings({
  required final bool enabled,
  required final GuideBackend backend,
  required final String promptVersion,
  final String? projectId,
  final VertexLocation location = VertexLocation.global,
  final String? textModel,
  final GeminiThinkingLevel? textThinkingLevel,
  final String? ttsModel,
  final String? voiceId,
  final FakeGuideBehavior fakeBehavior = FakeGuideBehavior.normal,
  final Duration fakeDelay = Duration.zero,
}) {
  /// [deployed] は配備された環境（development・test 以外）か。配備された環境でガイドを
  /// 有効にするなら、`GUIDE_BACKEND` の明示を必須にし、fake はローカルの GCS エミュレーター
  /// （`STORAGE_EMULATOR_HOST`）を使うときだけ許す。本番で設定を書き忘れて、利用者に
  /// fake の文と電子音を返さないようにする（docs/specs.md「設定値」：提出構成は gemini）。
  /// Gemini の設定。gemini を使うのに必要な値がすべてそろっているときだけ非 null。
  ({
    VertexEndpoint vertex,
    String textModel,
    GeminiThinkingLevel textThinkingLevel,
    String ttsModel,
    String voiceId,
  })?
  get gemini =>
      switch ((projectId, textModel, textThinkingLevel, ttsModel, voiceId)) {
        (
          final String project,
          final String text,
          final GeminiThinkingLevel thinking,
          final String tts,
          final String voice,
        ) =>
          (
            vertex: VertexEndpoint(project: project, location: location),
            textModel: text,
            textThinkingLevel: thinking,
            ttsModel: tts,
            voiceId: voice,
          ),
        _ => null,
      };

  factory fromEnvironment(Map<String, String> env, {required bool deployed}) {
    rejectEmulatorOnCloudRun(env);
    String? read(String key) {
      final value = env[key]?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    final enabledRaw = read('GUIDES_ENABLED');
    final bool enabled;
    switch (enabledRaw) {
      case null || 'false':
        enabled = false;
      case 'true':
        enabled = true;
      default:
        throw const ConfigurationException('GUIDES_ENABLED は true か false にする');
    }

    final backendSet = read('GUIDE_BACKEND');
    final backendRaw = backendSet ?? 'fake';
    final backend = GuideBackend.values
        .where((b) => b.name == backendRaw)
        .firstOrNull;
    if (backend == null) {
      throw const ConfigurationException('GUIDE_BACKEND は fake か gemini にする');
    }

    final fakeBehavior = FakeGuideBehavior.parse(read('GUIDE_FAKE_BEHAVIOR'));
    if (fakeBehavior == null) {
      throw ConfigurationException(
        'GUIDE_FAKE_BEHAVIOR は ${FakeGuideBehavior.values.map((b) => b.name).join('・')} のどれかにする',
      );
    }
    final delayRaw = read('GUIDE_FAKE_DELAY_MS') ?? '0';
    final delayMs = int.tryParse(delayRaw);
    if (delayMs == null || delayMs < 0) {
      throw const ConfigurationException('GUIDE_FAKE_DELAY_MS は 0 以上の整数にする');
    }

    // 未設定なら global（docs/specs.md「設定値」）。値の誤りは、ガイドを止めていても起動時に知らせる。
    final locationRaw = read('VERTEX_LOCATION');
    final location = locationRaw == null
        ? VertexLocation.global
        : VertexLocation.parse(locationRaw);
    if (location == null) {
      throw ConfigurationException(
        'VERTEX_LOCATION は ${VertexLocation.values.map((l) => l.name).join('・')} のどれかにする',
      );
    }
    final thinkingRaw = read('GEMINI_TEXT_THINKING_LEVEL');
    final thinkingLevel = thinkingRaw == null
        ? null
        : GeminiThinkingLevel.parse(thinkingRaw);
    if (thinkingRaw != null && thinkingLevel == null) {
      throw ConfigurationException(
        'GEMINI_TEXT_THINKING_LEVEL は ${GeminiThinkingLevel.values.map((l) => l.name).join('・')} のどれかにする',
      );
    }

    final settings = GuideSettings(
      enabled: enabled,
      backend: backend,
      promptVersion: read('GUIDE_PROMPT_VERSION') ?? 'unset',
      projectId: read('VERTEX_PROJECT_ID'),
      location: location,
      textModel: read('GEMINI_TEXT_MODEL'),
      textThinkingLevel: thinkingLevel,
      ttsModel: read('GEMINI_TTS_MODEL'),
      voiceId: read('GUIDE_VOICE_ID'),
      fakeBehavior: fakeBehavior,
      fakeDelay: Duration(milliseconds: delayMs),
    );

    if (enabled && deployed) {
      final local =
          isLocalEmulator(env) && read('STORAGE_EMULATOR_HOST') != null;
      if (backendSet == null) {
        throw const ConfigurationException(
          '配備された環境でガイドを有効にするなら、GUIDE_BACKEND を明示する',
        );
      }
      if (backend == GuideBackend.fake && !local) {
        throw const ConfigurationException(
          '配備された環境では GUIDE_BACKEND=fake を使えない（ローカルのエミュレーターのときだけ）',
        );
      }
    }

    // gemini を使うのに必要な設定がなければ、起動時に分かるようにする。
    // ガイドを止めている（GUIDES_ENABLED=false）なら、未設定でも起動は許す。
    if (enabled && backend == GuideBackend.gemini) {
      final missing = [
        if (settings.projectId == null) 'VERTEX_PROJECT_ID',
        if (settings.textModel == null) 'GEMINI_TEXT_MODEL',
        if (settings.textThinkingLevel == null) 'GEMINI_TEXT_THINKING_LEVEL',
        if (settings.ttsModel == null) 'GEMINI_TTS_MODEL',
        if (settings.voiceId == null) 'GUIDE_VOICE_ID',
        if (read('GUIDE_PROMPT_VERSION') == null) 'GUIDE_PROMPT_VERSION',
      ];
      if (missing.isNotEmpty) {
        throw ConfigurationException(
          'GUIDE_BACKEND=gemini に必要な設定がない: ${missing.join(', ')}',
        );
      }
    }
    return settings;
  }
}
