import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../application/usecase/compose_guide_text.dart';
import '../../domain/ports/guide_speech_generator.dart';
import '../../domain/ports/guide_text_generator.dart';
import '../../infrastructure/config/guide_settings.dart';
import '../../infrastructure/config/runtime_environment.dart';
import '../../infrastructure/gemini/fake_guide_generators.dart';
import '../../infrastructure/gemini/gemini_guide_speech_generator.dart';
import '../../infrastructure/gemini/gemini_guide_text_generator.dart';
import '../../infrastructure/gemini/gemini_transport.dart';
import '../../infrastructure/google/access_token_provider.dart';

/// ガイドの生成に使う部品。`GUIDES_ENABLED=false` なら作らない。
class const GuideGenerators({
  required final GuideSettings settings,
  required final GuideTextGenerator text,
  required final GuideSpeechGenerator speech,
}) {
  /// 選定済みの構造物から本文を確定する（失敗時は固定文へ切り替える）。#32 が使う。
  ComposeGuideText composeText() => ComposeGuideText(text);
}

GuideSettings? _settings;
GuideGenerators? _generators;

/// 起動時（`createServer`）にガイドの設定を検証し、実装を選ぶ。誤りなら起動を失敗させる。
///
/// migration Job（`--role=maintenance`）はガイドを使わないので検証しない。
void configureGuides(Serverpod pod, {Map<String, String>? environment}) {
  if (pod.config.role.name == 'maintenance') return;
  final settings = GuideSettings.fromEnvironment(
    environment ?? Platform.environment,
    deployed: isDeployedRunMode(pod.runMode),
  );
  _settings = settings;
  _generators = settings.enabled ? _build(settings) : null;
}

GuideGenerators _build(GuideSettings settings) {
  switch (settings.backend) {
    case .fake:
      return GuideGenerators(
        settings: settings,
        text: FakeGuideTextGenerator(
          behavior: settings.fakeBehavior,
          delay: settings.fakeDelay,
        ),
        speech: FakeGuideSpeechGenerator(
          behavior: settings.fakeBehavior,
          delay: settings.fakeDelay,
        ),
      );
    case .gemini:
      // 必要な値がそろっていることは GuideSettings.fromEnvironment が起動時に確かめている。
      final gemini =
          settings.gemini ??
          (throw StateError('GUIDE_BACKEND=gemini の設定がそろっていない'));
      // 要求ごとに作らず、接続とトークンを使い回す。認証は実行サービスアカウント（ADC）。
      final transport = HttpGeminiTransport(
        tokens: MetadataServerAccessTokenProvider(),
      );
      return GuideGenerators(
        settings: settings,
        text: GeminiGuideTextGenerator(
          transport: transport,
          vertex: gemini.vertex,
          model: gemini.textModel,
          thinkingLevel: gemini.textThinkingLevel,
        ),
        speech: GeminiGuideSpeechGenerator(
          transport: transport,
          vertex: gemini.vertex,
          model: gemini.ttsModel,
          voice: gemini.voiceId,
        ),
      );
  }
}

/// ガイドの部品。ガイドを止めている（`GUIDES_ENABLED=false`）なら null（#32 は
/// `GUIDE_DISABLED` を返す）。[configureGuides] を通らずにサーバーを作ったら StateError。
GuideGenerators? guideGenerators() {
  if (_settings == null) {
    throw StateError('configureGuides が呼ばれていない（createServer を通さずにサーバーを作った）');
  }
  return _generators;
}
