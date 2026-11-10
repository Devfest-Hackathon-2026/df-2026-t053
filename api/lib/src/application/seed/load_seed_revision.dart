import 'dart:typed_data';

import 'seed_input.dart';
import 'seed_ports.dart';
import 'seed_validator.dart';

/// 素材ファイル 1 件（読み込み済み）。
class const SeedFile({
  /// ファイルの内容。上限を超えるファイルは読まず、空にする（[byteLength] だけを持つ）。
  required final Uint8List bytes,

  /// ファイルの大きさ（バイト）。
  required final int byteLength,

  /// 内容の SHA-256（小文字 16 進 64 桁）。
  required final String sha256,

  /// ヘッダーを読めなかった場合は null。
  required final SeedImageFacts? probe,
});

/// seed 入力 1 版と、その素材・pavilion マスター。
class const SeedBundle({
  required final SeedRevision input,
  required final List<SeedPavilion> pavilions,
  required final SeedFile photo,
  required final SeedFile map,

  /// 入力と素材の内容を正規化した SHA-256。同じ版番号の再投入で内容を比べる。
  /// 素材はファイル名ではなく内容の SHA-256 で比べる（名前だけ変えても同じ内容）。
  required final String digest,
});

/// [LoadSeedRevision.execute] の結果。
sealed class LoadSeedResult();

/// 検証で違反があった。DB・素材置き場には何も書いていない。
class const LoadSeedInvalid(final List<SeedViolation> violations)
    implements LoadSeedResult;

/// 検証だけを行い、違反がなかった。
class const LoadSeedVerified() implements LoadSeedResult;

/// 登録した（または同じ内容が既にあった）。
class const LoadSeedLoaded({
  required final SeedLoadOutcome outcome,
  required final int revisionId,

  /// 新しく素材置き場へ置いたオブジェクト名。
  required final List<String> uploaded,

  /// 公開まで求めたときの公開の結果。
  required final SeedPublishOutcome? published,
}) implements LoadSeedResult;

/// 素材の配置・下書き登録・検証を行う（docs/specs.md「seedと公開処理」1〜3）。
///
/// 1. 検証する。違反があれば、何も書かずに全件を返す。
/// 2. 素材を内容ハッシュ付きのパスに置く（既にあれば内容の一致だけを確かめる）。
/// 3. pavilion マスターと下書き版を 1 トランザクションで登録する。
///
/// 素材を先に置くので、DB が置いていない素材を参照することはない。
class LoadSeedRevision({
  required final SeedStore _store,
  required final SeedMediaStore _media,
  required final DateTime Function() _clock,
}) {
  Future<LoadSeedResult> execute(
    SeedBundle bundle, {
    bool verifyOnly = false,
    bool publish = false,
  }) async {
    final input = bundle.input;
    final pavilionKeys = {
      ...await _store.pavilionKeys(),
      for (final p in bundle.pavilions) p.sourceKey,
    };
    final violations = [
      ...validatePavilions(bundle.pavilions),
      ...validateSeed(
        input: input,
        pavilionKeys: pavilionKeys,
        photo: _facts(input.photo, bundle.photo),
        map: _facts(input.map, bundle.map),
      ),
    ];
    if (violations.isNotEmpty) return LoadSeedInvalid(violations);
    if (verifyOnly) return const LoadSeedVerified();

    // 失敗する登録（同じ版番号に別の内容など）で、素材だけが公開されないよう先に確かめる。
    // 最終的な判定は loadDraft のトランザクションの中でもう一度行う。
    await _store.checkDraft(input, bundle.digest, publish: publish);

    final uploaded = <String>[];
    final chosen = <String, String>{};
    Future<SeedAssetRecord> place(
      String role,
      SeedAssetFile file,
      SeedFile content,
    ) async {
      // 同じ内容の素材が登録済みなら、そのオブジェクト名を使う（内容アドレスは 1 つ）。
      // ファイル名は役割と形式だけにし、正解姿勢などを入れない。
      // 写真と会場図が同じバイト列なら、DB 登録前でも同じオブジェクト名にする
      // （同じ sha256 に別の名前を付けると、登録時に衝突する）。
      final objectPath =
          chosen[content.sha256] ??
          await _store.findAssetObjectPath(content.sha256) ??
          'media/${content.sha256}/$role.${_extension(file.contentType)}';
      chosen[content.sha256] = objectPath;
      if (await _media.putIfAbsent(
        objectPath,
        content.bytes,
        file.contentType,
      )) {
        uploaded.add(objectPath);
      }
      return SeedAssetRecord(
        sha256: content.sha256,
        objectPath: objectPath,
        contentType: file.contentType,
        byteLength: content.byteLength,
      );
    }

    final photo = await place('photo', input.photo, bundle.photo);
    final map = await place('map', input.map, bundle.map);
    final result = await _store.loadDraft(
      SeedDraft(
        input: input,
        pavilions: bundle.pavilions,
        photo: photo,
        map: map,
        digest: bundle.digest,
        now: _clock().toUtc(),
      ),
      publish: publish,
    );
    return LoadSeedLoaded(
      outcome: result.outcome,
      revisionId: result.revisionId,
      uploaded: List.unmodifiable(uploaded),
      published: result.published,
    );
  }

  SeedAssetFacts _facts(SeedAssetFile file, SeedFile content) => SeedAssetFacts(
    declaredContentType: file.contentType,
    byteLength: content.byteLength,
    probe: content.probe,
  );
}

/// pavilion マスターの入力を検証する。
List<SeedViolation> validatePavilions(List<SeedPavilion> pavilions) {
  final violations = <SeedViolation>[];
  final seen = <String>{};
  for (var i = 0; i < pavilions.length; i++) {
    final p = pavilions[i];
    final path = 'pavilions[$i]';
    if (p.sourceKey.trim().isEmpty) {
      violations.add(SeedViolation('$path.sourceKey', '空にしない'));
    } else if (!seen.add(p.sourceKey)) {
      violations.add(
        SeedViolation('$path.sourceKey', '重複している（${p.sourceKey}）'),
      );
    }
    if (p.name.trim().isEmpty) {
      violations.add(SeedViolation('$path.name', '空にしない'));
    }
    final lat = p.latitude;
    final lon = p.longitude;
    if ((lat == null) != (lon == null)) {
      violations.add(SeedViolation(path, '緯度と経度は対で設定する（片方だけは不可）'));
    } else if (lat != null && lon != null) {
      if (!lat.isFinite || lat < -90 || lat > 90) {
        violations.add(SeedViolation('$path.latitude', '−90〜90 の有限の数にする'));
      }
      if (!lon.isFinite || lon < -180 || lon > 180) {
        violations.add(SeedViolation('$path.longitude', '−180〜180 の有限の数にする'));
      }
    }
  }
  return violations;
}

String _extension(String contentType) => switch (contentType) {
  'image/jpeg' => 'jpg',
  'image/png' => 'png',
  'image/webp' => 'webp',
  // 検証で弾いているので来ない。
  _ => throw ArgumentError.value(contentType, 'contentType'),
};
