import 'dart:async';

import 'package:photohunt_server/src/application/dto/guide_text_result.dart';
import 'package:photohunt_server/src/application/usecase/compose_guide_text.dart';
import 'package:photohunt_server/src/domain/models/models.dart';
import 'package:photohunt_server/src/domain/ports/guide_cancellation.dart';
import 'package:photohunt_server/src/domain/ports/guide_text_generator.dart';
import 'package:test/test.dart';

/// 決めた結果を返す文生成。受け取った入力を記録する。
class _Generator(final Future<GeneratedGuideText> Function() _result)
    implements GuideTextGenerator {
  final List<GuideTextInput> inputs = [];

  @override
  Future<GeneratedGuideText> generate(
    GuideTextInput input, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) {
    inputs.add(input);
    return _result();
  }
}

StructureSource _source(int id, int structureId) => StructureSource(
  id: id,
  structureId: structureId,
  title: '出典 $id',
  url: 'https://example.com/$id',
  sortOrder: id,
);

final _materials = [
  GuideMaterial(
    structureId: 1,
    name: '大屋根',
    facts: '木造の大きな屋根。',
    fallbackText: '大屋根の固定文。',
    sources: [_source(10, 1), _source(11, 1)],
    direction: GuideDirection.front,
    distanceMeters: 3,
  ),
  GuideMaterial(
    structureId: 2,
    name: '塔',
    facts: '高い塔。',
    fallbackText: '塔の固定文。',
    sources: [_source(20, 2)],
    direction: GuideDirection.left,
    distanceMeters: 20,
  ),
];

Future<GuideTextResult> _compose(
  Future<GeneratedGuideText> Function() result, {
  Duration timeout = kGuideTextTimeout,
  GuideCancellation? cancellation,
}) =>
    ComposeGuideText(_Generator(result))
        .execute(_materials, timeout: timeout, cancellation: cancellation);

void _expectFallback(GuideTextResult result, GuideTextFailure reason) {
  expect(result.text, '大屋根の固定文。');
  expect(result.aiGenerated, isFalse);
  expect(result.structureIds, [1]);
  // 固定文は先頭の構造物のものなので、出典もその構造物の登録資料だけ。
  expect(result.sources.map((s) => s.id), [10, 11]);
  expect(result.fallbackReason, reason);
}

void main() {
  test('距離帯は5・15・30・100mで区切り、30mまでを近くの候補の帯にする（#226）', () {
    for (final (meters, band) in [
      (4.999, GuideDistanceBand.veryNear),
      (5.0, GuideDistanceBand.near),
      (14.999, GuideDistanceBand.near),
      (15.0, GuideDistanceBand.far),
      (30.0, GuideDistanceBand.far),
      (30.001, GuideDistanceBand.distant),
      (99.999, GuideDistanceBand.distant),
      (100.0, GuideDistanceBand.remote),
      (800.0, GuideDistanceBand.remote),
    ]) {
      expect(GuideDistanceBand.fromMeters(meters), band, reason: '$meters m');
    }
  });

  test('生成した本文は aiGenerated=true で、出典は選定した構造物の登録資料', () async {
    final result = await _compose(
      () async => const GeneratedGuideText(text: '  生成した本文。  ', model: 'm'),
    );
    expect(result.text, '生成した本文。');
    expect(result.aiGenerated, isTrue);
    expect(result.structureIds, [1, 2]);
    expect(result.sources.map((s) => s.id), [10, 11, 20]);
    expect(result.fallbackReason, isNull);
  });

  test('生成側へ渡すのは、名称・事実・方向・距離帯と locale だけ', () async {
    final generator = _Generator(
      () async => const GeneratedGuideText(text: '本文', model: 'm'),
    );
    await ComposeGuideText(generator).execute(_materials);
    final input = generator.inputs.single;
    expect(input.locale, 'ja-JP');
    expect(input.subjects.map((s) => s.name), ['大屋根', '塔']);
    expect(input.subjects.map((s) => s.distanceBand), [
      GuideDistanceBand.veryNear,
      GuideDistanceBand.far,
    ]);
    expect(input.subjects.map((s) => s.direction), [
      GuideDirection.front,
      GuideDirection.left,
    ]);
  });

  test('空の本文は固定文', () async {
    _expectFallback(
      await _compose(
        () async => const GeneratedGuideText(text: '  ', model: 'm'),
      ),
      GuideTextFailure.empty,
    );
  });

  test('拒否は固定文', () async {
    _expectFallback(
      await _compose(
        () async => throw const GuideTextException(GuideTextFailure.refused),
      ),
      GuideTextFailure.refused,
    );
  });

  test('形式の不正は固定文', () async {
    _expectFallback(
      await _compose(
        () async =>
            throw const GuideTextException(GuideTextFailure.invalidFormat),
      ),
      GuideTextFailure.invalidFormat,
    );
  });

  test('400 字は使い、401 字は固定文', () async {
    final ok = await _compose(
      () async => GeneratedGuideText(text: 'あ' * 400, model: 'm'),
    );
    expect(ok.aiGenerated, isTrue);
    _expectFallback(
      await _compose(
        () async => GeneratedGuideText(text: 'あ' * 401, model: 'm'),
      ),
      GuideTextFailure.invalidFormat,
    );
  });

  test('文字数はコードポイントで数える（絵文字 1 つを 2 文字と数えない）', () async {
    final result = await _compose(
      () async => GeneratedGuideText(text: '🏯' * 400, model: 'm'),
    );
    expect(result.aiGenerated, isTrue);
  });

  test('タイムアウトは固定文（実装が待ち上限を守らなくても打ち切る）', () async {
    final result = await _compose(
      () => Completer<GeneratedGuideText>().future, // 返らない
      timeout: const Duration(milliseconds: 10),
    );
    _expectFallback(result, GuideTextFailure.timeout);
  });

  test('通信の失敗は固定文', () async {
    _expectFallback(
      await _compose(
        () async =>
            throw const GuideTextException(GuideTextFailure.unavailable),
      ),
      GuideTextFailure.unavailable,
    );
  });

  test('取消は失敗ではないので、固定文に切り替えずにそのまま返す', () async {
    final cancellation = GuideCancellation();
    final pending = _compose(() async {
      cancellation.cancel();
      throw const GuideCancelledException();
    }, cancellation: cancellation);
    await expectLater(pending, throwsA(isA<GuideCancelledException>()));
  });

  test('取消の後に生成側が失敗を返しても、固定文ではなく取消', () async {
    final cancellation = GuideCancellation();
    await expectLater(
      _compose(() async {
        cancellation.cancel();
        throw const GuideTextException(GuideTextFailure.unavailable);
      }, cancellation: cancellation),
      throwsA(isA<GuideCancelledException>()),
    );
  });

  test('想定外の例外は固定文にせず、そのまま返す（不具合を隠さない）', () async {
    await expectLater(
      _compose(() async => throw StateError('bug')),
      throwsA(isA<StateError>()),
    );
  });
}
