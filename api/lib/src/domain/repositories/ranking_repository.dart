import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;

import '../models/ranked_score.dart';

/// ランキング用の読み取りビュー。出題の素材・正解や書き込みには触れない。
abstract interface class RankingRepository() {
  /// 一度でも公開された版か。公開終了後も true、下書きは false
  /// （challenge の取得と同じく、下書きの存在を公開しない）。
  Future<bool> publishedRevisionExists(int revisionId);

  Future<List<RankedScore>> listTop({
    required int revisionId,
    required PlayMode mode,
    required int limit,
  });

  Future<RankedScore?> findMine({
    required int revisionId,
    required PlayMode mode,
    required int userProfileId,
  });
}
