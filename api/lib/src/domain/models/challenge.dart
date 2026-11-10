/// 出題。公開中の版は [currentRevisionId] で指す（未公開は null）。
class const Challenge({
  required final int id,
  required final String slug,
  required final String title,
  required final int? currentRevisionId,
  required final DateTime createdAt,
});
