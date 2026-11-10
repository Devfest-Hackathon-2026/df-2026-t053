import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:test/test.dart';

import 'seed_fixture.dart';

void main() {
  String digest(SeedRevisionInput raw) => bundleOf(raw).digest;

  test('同じ入力は同じ digest（素材のファイル名は含めない）', () {
    final raw = sampleInput();
    final renamed = raw.copyWith(
      assets: raw.assets.copyWith(
        photo: raw.assets.photo.copyWith(file: 'renamed.png'),
      ),
    );
    expect(digest(renamed), digest(raw));
    expect(sampleBundle().digest, digest(raw));
  });

  test('内容が変われば digest が変わる', () {
    final raw = sampleInput();
    final base = digest(raw);
    final changed = [
      raw.copyWith(challenge: raw.challenge.copyWith(title: 'x')),
      raw.copyWith(revision: raw.revision.copyWith(story: 'x')),
      raw.copyWith(
        revision: raw.revision.copyWith(
          goal: raw.revision.goal.copyWith(pitchDegrees: 9),
        ),
      ),
      raw.copyWith(
        modes: [
          raw.modes.first.copyWith(
            spawns: [
              raw.modes.first.spawns.first.copyWith(yawDegrees: 1),
              ...raw.modes.first.spawns.skip(1),
            ],
          ),
          ...raw.modes.skip(1),
        ],
      ),
      raw.copyWith(
        structures: [raw.structures.first.copyWith(fallbackText: 'x')],
      ),
    ];
    for (final c in changed) {
      expect(digest(c), isNot(base));
    }
  });

  test('有限でない数でも空にならず、値ごとに別の digest', () {
    final raw = sampleInput();
    String withX(double x) => digest(
      raw.copyWith(
        revision: raw.revision.copyWith(goal: raw.revision.goal.copyWith(x: x)),
      ),
    );
    final nan = withX(double.nan);
    final inf = withX(double.infinity);
    expect(nan, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(inf, isNot(nan));
    expect(kSeedDigestVersion, 2);
  });
}
