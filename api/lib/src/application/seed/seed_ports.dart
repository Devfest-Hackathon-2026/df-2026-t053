import 'dart:typed_data';

import 'seed_input.dart';

/// 同じ slug・版番号に違う内容を入れようとした、公開済みの版を変えようとしたなど、
/// 登録済みの内容と両立しない操作。
class const SeedConflictException(final String message) implements Exception {
  @override
  String toString() => 'SeedConflictException($message)';
}

/// 対象の出題・版がない。
class const SeedNotFoundException(final String message) implements Exception {
  @override
  String toString() => 'SeedNotFoundException($message)';
}

/// 公開素材の置き場（GCS の公開バケット）。
abstract interface class SeedMediaStore() {
  /// [objectPath] に無ければ置く。既にあれば内容が [bytes] と同じか確かめ、
  /// 違えば [SeedConflictException]（内容アドレスは上書きしない）。
  ///
  /// 新しく置いたら true、同じ内容が既にあれば false。
  Future<bool> putIfAbsent(
    String objectPath,
    Uint8List bytes,
    String contentType,
  );
}

/// DB に登録する素材 1 件。
class const SeedAssetRecord({
  required final String sha256,
  required final String objectPath,
  required final String contentType,
  required final int byteLength,
});

/// 下書き登録 1 回分。
class const SeedDraft({
  required final SeedRevision input,
  required final List<SeedPavilion> pavilions,
  required final SeedAssetRecord photo,
  required final SeedAssetRecord map,

  /// 入力と素材の内容を正規化した SHA-256。再投入で内容を比べる。
  required final String digest,
  required final DateTime now,
});

enum SeedLoadOutcome() {
  /// 新しい下書き版を登録した。
  inserted,

  /// 同じ内容の版が既にあり、何も変えなかった。
  unchanged,
}

enum SeedPublishOutcome() {
  /// 下書き版を公開し、公開中の版にした。
  published,

  /// 公開済みの別の版（切り戻しなど）を公開中の版にした。
  switched,

  /// 既に公開中の版だった。
  unchanged,
}

/// seed の書き込み先（管理用。API の要求からは使わない）。
///
/// 各操作は 1 トランザクションで行い、途中で失敗したら何も残さない。
abstract interface class SeedStore() {
  /// sha256 が同じ素材が登録済みなら、そのオブジェクト名。
  Future<String?> findAssetObjectPath(String sha256);

  /// 登録済みの内容と両立しないなら [SeedConflictException]。DB は変えない。
  /// 素材を公開バケットへ置く前に呼び、失敗する登録で素材を公開しないようにする。
  ///
  /// [publish] が true なら、公開できるか（別の出題が公開中でないか）も確かめる。
  Future<void> checkDraft(
    SeedRevision input,
    String digest, {
    bool publish = false,
  });

  /// pavilion マスターの sourceKey 一覧。
  Future<Set<String>> pavilionKeys();

  /// pavilion マスターと下書き版を登録する。同じ版番号が既にあれば、
  /// [SeedDraft.digest] が同じなら [SeedLoadOutcome.unchanged]、違えば [SeedConflictException]。
  ///
  /// [publish] が true なら、同じトランザクションで公開まで行う（公開に失敗したら
  /// 下書きも残さない）。結果の `published` は、公開したときだけ入る。
  Future<
    ({SeedLoadOutcome outcome, int revisionId, SeedPublishOutcome? published})
  >
  loadDraft(SeedDraft draft, {bool publish = false});

  /// 版を公開済みにし、出題の公開中の版にする（切り戻しも同じ操作）。
  ///
  /// 公開中の出題は最大 1 件（提出版）。別の出題が公開中なら [SeedConflictException]。
  Future<SeedPublishOutcome> publish({
    required String slug,
    required int revisionNo,
    required DateTime now,
  });

  /// 出題を公開中でなくする（版の published_at は保つ）。
  Future<void> unpublish({required String slug});

  /// 未公開の版を子データごと消す。公開済みなら [SeedConflictException]。
  Future<void> deleteDraft({required String slug, required int revisionNo});
}
