import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_input.dart';
import 'package:photohunt_server/src/application/seed/seed_validator.dart';
import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';

/// テストの基準にするサンプル seed（`api/test/fixtures/seeds/`）。テストは `api/` で実行する。
const sampleDir = (
  revision: 'test/fixtures/seeds/sample-plaza/r1',
  pavilions: 'test/fixtures/seeds/pavilions.yaml',
);

SeedBundle sampleBundle() =>
    readSeedBundle(dir: sampleDir.revision, pavilionsPath: sampleDir.pavilions);

/// サンプルの読み取り形式。テストは copyWith で一部を変えてから [bundleOf] で使う。
SeedRevisionInput sampleInput() => readSeedRevisionInput(sampleDir.revision);

/// [raw] とサンプルの素材・pavilion マスターから bundle を作る。
SeedBundle bundleOf(SeedRevisionInput raw) {
  final base = sampleBundle();
  final input = seedRevisionFromInput(raw);
  return SeedBundle(
    input: input,
    pavilions: base.pavilions,
    photo: base.photo,
    map: base.map,
    digest: seedDigest(
      input,
      photoSha256: base.photo.sha256,
      mapSha256: base.map.sha256,
    ),
  );
}

SeedAssetFacts facts(SeedAssetFile file, SeedFile content) => SeedAssetFacts(
  declaredContentType: file.contentType,
  byteLength: content.byteLength,
  probe: content.probe,
);
