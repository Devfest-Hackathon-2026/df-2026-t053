import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:photohunt_server/src/domain/ports/guide_cancellation.dart';
import 'package:photohunt_server/src/domain/ports/guide_speech_generator.dart';
import 'package:photohunt_server/src/domain/ports/guide_text_generator.dart';
import 'package:photohunt_server/src/infrastructure/audio/wav.dart';
import 'package:photohunt_server/src/infrastructure/config/guide_settings.dart';
import 'package:photohunt_server/src/infrastructure/config/replication_settings.dart'
    show ConfigurationException;
import 'package:photohunt_server/src/infrastructure/gemini/fake_guide_generators.dart';
import 'package:photohunt_server/src/infrastructure/gemini/gemini_guide_speech_generator.dart';
import 'package:photohunt_server/src/infrastructure/gemini/gemini_guide_text_generator.dart';
import 'package:photohunt_server/src/infrastructure/gemini/gemini_transport.dart';
import 'package:photohunt_server/src/infrastructure/gemini/vertex_endpoint.dart';
import 'package:photohunt_server/src/infrastructure/google/access_token_provider.dart';
import 'package:test/test.dart';

/// 決めた応答を返す transport。送った送り先と要求本文を記録する。
class _Transport(final Future<Map<String, Object?>> Function() _respond)
    implements GeminiTransport {
  final List<Uri> uris = [];
  final List<Map<String, Object?>> sent = [];

  @override
  Future<Map<String, Object?>> post(
    Uri uri,
    Map<String, Object?> body, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) {
    uris.add(uri);
    sent.add(body);
    return _respond();
  }
}

const _vertex = VertexEndpoint(project: 'p', location: VertexLocation.global);

Map<String, Object?> _completed(List<Map<String, Object?>> content) => {
  'status': 'completed',
  'steps': [
    {
      'type': 'user_input',
      'content': [
        {'type': 'text', 'text': '入力は応答に含まれても使わない'},
      ],
    },
    {'type': 'model_output', 'content': content},
  ],
};

const _input = GuideTextInput(
  locale: 'ja-JP',
  subjects: [
    GuideSubject(
      name: '大屋根',
      facts: '木造の大きな屋根。',
      direction: GuideDirection.front,
      distanceBand: GuideDistanceBand.veryNear,
    ),
  ],
);

Uint8List _pcm(int samples) => Uint8List(samples * 2);

void main() {
  group('WAV', () {
    test('ヘッダーのない PCM に、正しい 44 バイトのヘッダーを付ける', () {
      final wav = pcmToWav(_pcm(100));
      expect(wav.length, 44 + 200);
      expect(isWav(wav), isTrue);
      final data = ByteData.sublistView(wav);
      expect(ascii.decode(wav.sublist(0, 4)), 'RIFF');
      expect(data.getUint32(4, Endian.little), 36 + 200);
      expect(ascii.decode(wav.sublist(8, 12)), 'WAVE');
      expect(data.getUint16(22, Endian.little), 1); // モノラル
      expect(data.getUint32(24, Endian.little), 24000); // 24 kHz
      expect(data.getUint32(28, Endian.little), 48000); // バイト/秒
      expect(data.getUint16(34, Endian.little), 16); // 16 bit
      expect(data.getUint32(40, Endian.little), 200);
    });

    test('audio/wav はそのまま使い、ヘッダーを二重に付けない', () {
      final wav = pcmToWav(_pcm(100));
      final result = toWav(wav, mimeType: 'audio/wav');
      expect(result, wav);
      expect(identical(result, wav), isTrue);
    });

    test('audio/l16 は WAV にし、rate= の標本化周波数を使う', () {
      final result = toWav(
        _pcm(10),
        mimeType: 'audio/L16;codec=pcm;rate=16000',
      );
      expect(isWav(result), isTrue);
      expect(ByteData.sublistView(result).getUint32(24, Endian.little), 16000);
      expect(result.length, 44 + 20);
    });

    test('引用符つきの rate= と、channels= を読む', () {
      final stereo = toWav(
        Uint8List(400),
        mimeType: 'audio/L16; rate="16000"; channels=2',
      );
      final data = ByteData.sublistView(stereo);
      expect(data.getUint16(22, Endian.little), 2); // ステレオ
      expect(data.getUint32(24, Endian.little), 16000);
      expect(data.getUint32(28, Endian.little), 16000 * 4); // バイト/秒
      expect(data.getUint16(32, Endian.little), 4); // 1 標本のバイト数
    });

    test('ステレオで、1 標本（4 バイト）の倍数でない PCM は失敗', () {
      expect(
        () => toWav(Uint8List(6), mimeType: 'audio/l16;channels=2'),
        throwsA(isA<GuideSpeechException>()),
      );
    });

    test('rate= が不正なら失敗', () {
      expect(
        () => toWav(Uint8List(4), mimeType: 'audio/l16;rate=0'),
        throwsA(isA<GuideSpeechException>()),
      );
    });

    test('10 MiB を超えたら失敗', () {
      expect(
        () => toWav(Uint8List(kGuideAudioMaxBytes), mimeType: 'audio/l16'),
        throwsA(
          isA<GuideSpeechException>().having(
            (e) => e.reason,
            'reason',
            GuideSpeechFailure.tooLarge,
          ),
        ),
      );
    });

    for (final (name, bytes, mime) in [
      (
        'WAV と名乗るが壊れている',
        Uint8List.fromList(utf8.encode('RIFFxxxxWAVE')),
        'audio/wav',
      ),
      ('data がない WAV', pcmToWav(_pcm(0)), 'audio/wav'),
      ('奇数長の PCM', Uint8List(3), 'audio/l16'),
      ('空の PCM', Uint8List(0), 'audio/l16'),
      ('対応しない形式', Uint8List(10), 'audio/mpeg'),
    ]) {
      test('形式の不正: $name', () {
        expect(
          () => toWav(bytes, mimeType: mime),
          throwsA(
            isA<GuideSpeechException>().having(
              (e) => e.reason,
              'reason',
              GuideSpeechFailure.invalidFormat,
            ),
          ),
        );
      });
    }
  });

  group('Gemini の文生成', () {
    test('要求には、指示と資料を分けて、選定した資料の値だけを送る', () {
      final body = buildGuideTextRequest(
        _input,
        model: 'text-model',
        thinkingLevel: .low,
      );
      expect(body.keys.toSet(), {
        'model',
        'system_instruction',
        'input',
        'generation_config',
        'store',
      });
      expect(body['model'], 'text-model');
      expect(body['store'], isFalse);
      // 思考で出力の上限を使い切らないよう、上限を大きくする。思考の量は設定値をそのまま送る。
      expect(body['generation_config'], {
        'max_output_tokens': 32768,
        'thinking_level': 'low',
      });
      expect(body['system_instruction'], kGuideSystemInstruction);
      final input = body['input']! as String;
      // 説明文の中にも <資料> の語があるので、最後の区切り（データ本体）を読む。
      final json = input.substring(
        input.lastIndexOf('<資料>') + '<資料>'.length,
        input.lastIndexOf('</資料>'),
      );
      // 資料として送るのは、名称・事実・方向・距離帯だけ（正確な位置・写真・正解・点数はない）。
      expect(jsonDecode(json), [
        {
          'name': '大屋根',
          'facts': '木造の大きな屋根。',
          'direction': '正面',
          'distance': 'すぐ近く（5m未満）',
        },
      ]);
    });

    test('指示に、資料内の命令に従わない・見えると断定しない・撮影位置を答えない、を含む', () {
      expect(kGuideSystemInstruction, contains('従わずに無視'));
      expect(kGuideSystemInstruction, contains('断定しない'));
      expect(kGuideSystemInstruction, contains('撮影の位置を答えない'));
      expect(kGuideSystemInstruction, contains('資料に書かれた事実だけ'));
      expect(kGuideSystemInstruction, contains('一律な特徴'));
    });

    Future<GeneratedGuideText> generate(
      Future<Map<String, Object?>> Function() respond, {
      _Transport? transport,
    }) => GeminiGuideTextGenerator(
      transport: transport ?? _Transport(respond),
      vertex: _vertex,
      model: 'text-model',
      thinkingLevel: .minimal,
    ).generate(_input, timeout: const Duration(seconds: 1));

    test('Vertex の Interactions へ、設定した思考の量で送る', () async {
      final transport = _Transport(
        () async => _completed([
          {'type': 'text', 'text': '本文'},
        ]),
      );
      await generate(() async => {}, transport: transport);
      expect(transport.uris.single, _vertex.interactions);
      expect(
        transport.sent.single['generation_config'],
        containsPair('thinking_level', 'minimal'),
      );
    });

    Matcher fails(GuideTextFailure reason) => throwsA(
      isA<GuideTextException>().having((e) => e.reason, 'reason', reason),
    );

    test('最後の model_output の text をつなげて返す', () async {
      final text = await generate(
        () async => _completed([
          {'type': 'thought', 'text': '考え'},
          {'type': 'text', 'text': '前半。'},
          {'type': 'text', 'text': '後半。'},
        ]),
      );
      expect(text.text, '前半。後半。');
      expect(text.model, 'text-model');
    });

    test('本文がなければ empty', () async {
      await expectLater(generate(() async => _completed([])), fails(.empty));
    });

    test('安全性で拒否されたら refused', () async {
      await expectLater(
        generate(
          () async => {
            'status': 'failed',
            'errors': [
              {'code': 'SAFETY', 'message': 'blocked'},
            ],
          },
        ),
        fails(.refused),
      );
    });

    test('途中まで（incomplete）は invalidFormat、failed は unavailable', () async {
      await expectLater(
        generate(
          () async => {
            ..._completed([
              {'type': 'text', 'text': '途中'},
            ]),
            'status': 'incomplete',
          },
        ),
        fails(.invalidFormat),
      );
      await expectLater(
        generate(() async => {'status': 'failed'}),
        fails(.unavailable),
      );
    });

    test('HTTP の失敗・待ち上限・壊れた応答を分類する', () async {
      await expectLater(
        generate(() async => throw const GeminiHttpException(429)),
        fails(.unavailable),
      );
      await expectLater(
        generate(() async => throw const GeminiTimeoutException()),
        fails(.timeout),
      );
      await expectLater(
        generate(() async => throw const FormatException()),
        fails(.invalidFormat),
      );
    });

    test('取消はそのまま返す', () async {
      await expectLater(
        generate(() async => throw const GuideCancelledException()),
        throwsA(isA<GuideCancelledException>()),
      );
    });

    test('通信の失敗（Socket・TLS）・トークンの取得の失敗・応答の超過は unavailable', () async {
      await expectLater(
        generate(() async => throw const SocketException('refused')),
        fails(.unavailable),
      );
      await expectLater(
        generate(() async => throw const AccessTokenException('down')),
        fails(.unavailable),
      );
      await expectLater(
        generate(() async => throw const TlsException('handshake')),
        fails(.unavailable),
      );
      await expectLater(
        generate(() async => throw const GeminiResponseTooLargeException()),
        fails(.unavailable),
      );
    });

    test('想定外の例外（実装の不具合）は分類せず、そのまま返す（固定文で隠さない）', () async {
      await expectLater(
        generate(() async => throw StateError('bug')),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        generate(() async => throw TypeError()),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Gemini の音声生成', () {
    Future<Uint8List> synthesize(
      Future<Map<String, Object?>> Function() respond, {
      _Transport? transport,
    }) => GeminiGuideSpeechGenerator(
      transport: transport ?? _Transport(respond),
      vertex: _vertex,
      model: 'tts-model',
      voice: 'Kore',
    ).synthesize('確定した本文', timeout: const Duration(seconds: 1));

    /// generateContent の応答（最初の候補の parts）。
    Map<String, Object?> candidate(
      List<Map<String, Object?>> parts, {
      String finishReason = 'STOP',
    }) => {
      'candidates': [
        {
          'content': {'role': 'model', 'parts': parts},
          'finishReason': finishReason,
        },
      ],
    };

    Map<String, Object?> audio(Uint8List bytes, String mime) => candidate([
      {
        'inlineData': {'mimeType': mime, 'data': base64.encode(bytes)},
      },
    ]);

    Matcher fails(GuideSpeechFailure reason) => throwsA(
      isA<GuideSpeechException>().having((e) => e.reason, 'reason', reason),
    );

    test('generateContent へ、確定した本文と音声の指定だけを送る', () async {
      final wav = pcmToWav(_pcm(10));
      final transport = _Transport(() async => audio(wav, 'audio/wav'));
      await synthesize(() async => {}, transport: transport);
      expect(transport.uris.single, _vertex.generateContent('tts-model'));
      // TTS が受け付けない systemInstruction・temperature などは送らない。
      expect(transport.sent.single, {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '確定した本文'},
            ],
          },
        ],
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {'voice': 'Kore'},
            'languageCode': 'ja-JP',
          },
        },
      });
    });

    test('WAV はそのまま、PCM には WAV ヘッダーを付ける', () async {
      final wav = pcmToWav(_pcm(10));
      expect(await synthesize(() async => audio(wav, 'audio/wav')), wav);
      final fromPcm = await synthesize(
        () async => audio(_pcm(10), 'audio/l16;rate=24000'),
      );
      expect(isWav(fromPcm), isTrue);
      expect(fromPcm.length, 44 + 20);
    });

    test('音声の part がない・壊れた base64・候補がないは invalidFormat', () async {
      await expectLater(
        synthesize(
          () async => candidate([
            {'text': '音声ではない'},
          ], finishReason: 'OTHER'),
        ),
        throwsA(
          isA<GuideSpeechException>()
              .having(
                (e) => e.reason,
                'reason',
                GuideSpeechFailure.invalidFormat,
              )
              .having((e) => e.detail, 'detail', contains('OTHER')),
        ),
      );
      await expectLater(
        synthesize(
          () async => candidate([
            {
              'inlineData': {'mimeType': 'audio/wav', 'data': '%%%'},
            },
          ]),
        ),
        fails(.invalidFormat),
      );
      await expectLater(synthesize(() async => {}), fails(.invalidFormat));
    });

    test('入力が止められた（promptFeedback.blockReason）なら unavailable', () async {
      await expectLater(
        synthesize(
          () async => {
            'promptFeedback': {'blockReason': 'SAFETY'},
          },
        ),
        throwsA(
          isA<GuideSpeechException>()
              .having((e) => e.reason, 'reason', GuideSpeechFailure.unavailable)
              .having((e) => e.detail, 'detail', contains('SAFETY')),
        ),
      );
    });

    test('応答の超過は tooLarge、想定外の例外はそのまま返す', () async {
      await expectLater(
        synthesize(() async => throw const GeminiResponseTooLargeException()),
        fails(.tooLarge),
      );
      await expectLater(
        synthesize(() async => throw StateError('bug')),
        throwsA(isA<StateError>()),
      );
    });

    test('待ち上限は timeout、HTTP とトークンの取得の失敗は unavailable', () async {
      await expectLater(
        synthesize(() async => throw const GeminiTimeoutException()),
        fails(.timeout),
      );
      await expectLater(
        synthesize(() async => throw const GeminiHttpException(500)),
        fails(.unavailable),
      );
      await expectLater(
        synthesize(() async => throw const AccessTokenException('down')),
        fails(.unavailable),
      );
    });
  });

  group('fake', () {
    test('ネットワークなしで本文と、32 KiB を超える有効な WAV を返す', () async {
      final text = await FakeGuideTextGenerator().generate(
        _input,
        timeout: const Duration(seconds: 1),
      );
      expect(text.text, startsWith('【fake】'));
      expect(text.text, contains('大屋根'));
      final wav = await FakeGuideSpeechGenerator().synthesize(
        text.text,
        timeout: const Duration(seconds: 1),
      );
      expect(isWav(wav), isTrue);
      expect(wav.length, greaterThan(32 * 1024));
      expect(toWav(wav, mimeType: 'audio/wav'), wav);
    });

    test('失敗・空・拒否・タイムアウトを注入できる', () async {
      Future<void> textFails(FakeGuideBehavior b, GuideTextFailure reason) =>
          expectLater(
            FakeGuideTextGenerator(behavior: b)
                .generate(_input, timeout: const Duration(milliseconds: 5)),
            throwsA(
              isA<GuideTextException>().having((e) => e.reason, 'r', reason),
            ),
          );
      await textFails(.unavailable, .unavailable);
      await textFails(.refused, .refused);
      await textFails(.timeout, .timeout);
      expect(
        (await FakeGuideTextGenerator(
          behavior: .empty,
        ).generate(_input, timeout: const Duration(seconds: 1))).text,
        isEmpty,
      );
      await expectLater(
        FakeGuideSpeechGenerator(behavior: .unavailable)
            .synthesize('x', timeout: const Duration(seconds: 1)),
        throwsA(isA<GuideSpeechException>()),
      );
    });

    test('遅延の途中で取り消すと、待たずに取消を返す', () async {
      final cancellation = GuideCancellation();
      final watch = Stopwatch()..start();
      final pending = FakeGuideTextGenerator(delay: const Duration(seconds: 30))
          .generate(
            _input,
            timeout: const Duration(seconds: 60),
            cancellation: cancellation,
          );
      Timer(const Duration(milliseconds: 20), cancellation.cancel);
      await expectLater(pending, throwsA(isA<GuideCancelledException>()));
      expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    });
  });

  group('設定', () {
    test('未設定ならガイドは止まっていて、fake を使う', () {
      final s = GuideSettings.fromEnvironment(const {}, deployed: false);
      expect(s.enabled, isFalse);
      expect(s.backend, GuideBackend.fake);
    });

    test('gemini で必要な設定がなければ、名前だけを挙げて起動しない', () {
      expect(
        () => GuideSettings.fromEnvironment(const {
          'GUIDES_ENABLED': 'true',
          'GUIDE_BACKEND': 'gemini',
          'GEMINI_TEXT_MODEL': 'gemini-3.8-flash',
        }, deployed: false),
        throwsA(
          isA<ConfigurationException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('VERTEX_PROJECT_ID'),
              contains('GEMINI_TEXT_THINKING_LEVEL'),
              contains('GEMINI_TTS_MODEL'),
              contains('GUIDE_VOICE_ID'),
              isNot(contains('GEMINI_API_KEY')),
              isNot(contains('gemini-3.8-flash')),
            ),
          ),
        ),
      );
    });

    test('gemini でも、ガイドを止めていれば起動を許す', () {
      final s = GuideSettings.fromEnvironment(const {
        'GUIDES_ENABLED': 'false',
        'GUIDE_BACKEND': 'gemini',
      }, deployed: false);
      expect(s.enabled, isFalse);
    });

    const geminiEnv = {
      'GUIDES_ENABLED': 'true',
      'GUIDE_BACKEND': 'gemini',
      'VERTEX_PROJECT_ID': 'my-project',
      'GEMINI_TEXT_MODEL': 'gemini-3.8-flash',
      'GEMINI_TEXT_THINKING_LEVEL': 'low',
      'GEMINI_TTS_MODEL': 'gemini-3.8-flash-lite-tts',
      'GUIDE_VOICE_ID': 'Kore',
      'GUIDE_PROMPT_VERSION': 'v1',
    };

    test('そろっていれば gemini の設定を読む。ロケーションの既定は global', () {
      final s = GuideSettings.fromEnvironment(geminiEnv, deployed: true);
      expect(s.backend, GuideBackend.gemini);
      expect(s.location, VertexLocation.global);
      final gemini = s.gemini;
      expect(gemini, isNotNull);
      if (gemini == null) return;
      expect(gemini.vertex.project, 'my-project');
      expect(gemini.vertex.location, VertexLocation.global);
      expect(gemini.textModel, 'gemini-3.8-flash');
      expect(gemini.textThinkingLevel, GeminiThinkingLevel.low);
      expect(gemini.ttsModel, 'gemini-3.8-flash-lite-tts');
      expect(gemini.voiceId, 'Kore');
    });

    test('VERTEX_LOCATION で us・eu を選べる', () {
      final s = GuideSettings.fromEnvironment({
        ...geminiEnv,
        'VERTEX_LOCATION': 'eu',
      }, deployed: true);
      expect(s.gemini?.vertex.location, VertexLocation.eu);
    });

    for (final (key, value) in const [
      ('VERTEX_LOCATION', 'asia-northeast1'),
      ('GEMINI_TEXT_THINKING_LEVEL', 'none'),
    ]) {
      test('$key が対応しない値なら、値を出さずに起動しない（ガイドを止めていても）', () {
        for (final enabled in ['true', 'false']) {
          expect(
            () => GuideSettings.fromEnvironment({
              ...geminiEnv,
              'GUIDES_ENABLED': enabled,
              key: value,
            }, deployed: false),
            throwsA(
              isA<ConfigurationException>().having(
                (e) => e.message,
                'message',
                allOf(contains(key), isNot(contains(value))),
              ),
            ),
          );
        }
      });
    }

    test('配備された環境では、GUIDE_BACKEND の書き忘れと fake を起動時に拒否する', () {
      for (final env in const [
        {'GUIDES_ENABLED': 'true'},
        {'GUIDES_ENABLED': 'true', 'GUIDE_BACKEND': 'fake'},
      ]) {
        expect(
          () => GuideSettings.fromEnvironment(env, deployed: true),
          throwsA(isA<ConfigurationException>()),
          reason: '$env',
        );
      }
    });

    test('配備された環境でも、ローカルのエミュレーターなら fake を許す（ローカルの api は本番モード）', () {
      final s = GuideSettings.fromEnvironment(const {
        'GUIDES_ENABLED': 'true',
        'GUIDE_BACKEND': 'fake',
        'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
      }, deployed: true);
      expect(s.backend, GuideBackend.fake);
    });

    for (final key in ['K_SERVICE', 'CLOUD_RUN_JOB']) {
      test('$key上では設定の読み込み順・ガイドの有効状態によらずemulatorを拒否する', () {
        for (final deployed in [false, true]) {
          for (final enabled in ['false', 'true']) {
            expect(
              () => GuideSettings.fromEnvironment({
                key: 'runtime',
                'GUIDES_ENABLED': enabled,
                'GUIDE_BACKEND': 'fake',
                'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
              }, deployed: deployed),
              throwsA(isA<ConfigurationException>()),
            );
          }
        }
        expect(
          GuideSettings.fromEnvironment({
            key: 'runtime',
          }, deployed: true).enabled,
          isFalse,
        );
      });
    }

    test('空白だけのemulator指定では配備環境のfakeを許さない', () {
      expect(
        () => GuideSettings.fromEnvironment({
          'GUIDES_ENABLED': 'true',
          'GUIDE_BACKEND': 'fake',
          'STORAGE_EMULATOR_HOST': '   ',
        }, deployed: true),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('配備された環境でも、ガイドを止めていれば未設定で起動を許す', () {
      expect(
        GuideSettings.fromEnvironment(const {}, deployed: true).enabled,
        isFalse,
      );
    });

    for (final env in const [
      {'GUIDES_ENABLED': 'yes'},
      {'GUIDE_BACKEND': 'openai'},
      {'GUIDE_FAKE_BEHAVIOR': 'slow'},
      {'GUIDE_FAKE_DELAY_MS': '-1'},
    ]) {
      test('不正な値は起動しない: $env', () {
        expect(
          () => GuideSettings.fromEnvironment(env, deployed: false),
          throwsA(isA<ConfigurationException>()),
        );
      });
    }
  });
}
