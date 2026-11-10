import 'dart:typed_data';

import '../../domain/ports/guide_cancellation.dart';
import '../../domain/ports/guide_speech_generator.dart';
import '../audio/wav.dart';
import 'gemini_transport.dart';
import 'vertex_endpoint.dart';

/// 読み上げの言語。ガイドは ja-JP だけを扱う（docs/specs.md「AI多文化音声ガイド」）。
const String kGuideSpeechLanguageCode = 'ja-JP';

/// 音声生成（generateContent）の要求本文を作る。TTS へは、確定した本文だけを渡す。
///
/// モデルは URL で指定する。Vertex の TTS は `systemInstruction`・`temperature`・`topP`・
/// `topK`・`candidateCount` を受け付けない（`INVALID_ARGUMENT`）ので送らない。
Map<String, Object?> buildGuideSpeechRequest(
  String text, {
  required String voice,
}) => {
  'contents': [
    {
      'role': 'user',
      'parts': [
        {'text': text},
      ],
    },
  ],
  // 1 回の要求（ストリーミングでない）の出力は、完成した WAV（audio/wav）。
  'generationConfig': {
    'responseModalities': ['AUDIO'],
    'speechConfig': {
      'voiceConfig': {'voice': voice},
      'languageCode': kGuideSpeechLanguageCode,
    },
  },
};

/// Gemini の TTS モデル（`GEMINI_TTS_MODEL`・`GUIDE_VOICE_ID`）で、Vertex AI の
/// generateContent を使って音声を作る（TTS モデルは Interactions に対応していない）。
///
/// 出力が WAV ならそのまま、ヘッダーのない PCM なら WAV ヘッダーを付ける（二重にしない）。
/// 失敗しても呼び直さない（呼び出し側は音声なしで本文だけを返す）。
class GeminiGuideSpeechGenerator({
  required final GeminiTransport _transport,
  required final VertexEndpoint _vertex,
  required final String model,
  required final String voice,
}) implements GuideSpeechGenerator {
  @override
  Future<Uint8List> synthesize(
    String text, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) async {
    final Map<String, Object?> response;
    try {
      response = await callGemini(
        _transport,
        _vertex.generateContent(model),
        buildGuideSpeechRequest(text, voice: voice),
        timeout: timeout,
        cancellation: cancellation,
      );
    } on GeminiCallException catch (e) {
      throw GuideSpeechException(switch (e.kind) {
        .timeout => GuideSpeechFailure.timeout,
        .malformed => GuideSpeechFailure.invalidFormat,
        .tooLarge => GuideSpeechFailure.tooLarge,
        .http || .network || .credentials => GuideSpeechFailure.unavailable,
      }, detail: e.detail);
    }

    // 入力が安全性などで止められた。
    if (response case {
      'promptFeedback': {'blockReason': final String reason},
    }) {
      throw GuideSpeechException(
        GuideSpeechFailure.unavailable,
        detail: 'blockReason=$reason',
      );
    }
    final audio = lastInlineAudio(response);
    final bytes = decodeBase64(audio?.data);
    if (audio == null || bytes == null) {
      throw GuideSpeechException(
        GuideSpeechFailure.invalidFormat,
        detail: '音声がない（finishReason=${firstFinishReason(response)}）',
      );
    }
    // 応答の読み込みは transport が上限で止めている。ここでは復号後の大きさを先に確かめる
    // （10 MiB はデコード後の WAV の上限。PCM はヘッダーの分だけ増える）。
    if (bytes.length > kGuideAudioMaxBytes) {
      throw const GuideSpeechException(GuideSpeechFailure.tooLarge);
    }
    return toWav(
      bytes,
      mimeType: audio.mimeType,
      reservedHeader: audio.data is Uint8List,
    );
  }
}

/// generateContent の応答の最初の候補から、最後の `inlineData`（音声）を取り出す。なければ null。
({String mimeType, Object data})? lastInlineAudio(
  Map<String, Object?> response,
) {
  if (response case {
    'candidates': [{'content': {'parts': final List<Object?> parts}}, ...],
  }) {
    for (final part in parts.reversed) {
      if (part case {
        'inlineData': {
          'mimeType': final String mimeType,
          'data': final Object data,
        },
      }) {
        return (mimeType: mimeType, data: data);
      }
    }
  }
  return null;
}

/// 最初の候補の `finishReason`。なければ null（失敗の記録に使う）。
String? firstFinishReason(Map<String, Object?> response) => switch (response) {
  {'candidates': [{'finishReason': final String reason}, ...]} => reason,
  _ => null,
};
