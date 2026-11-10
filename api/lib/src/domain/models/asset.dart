/// 内容アドレスの素材。同じ sha256 は 1 件だけ。
class const Asset({
  required final int id,
  required final String sha256,
  required final String objectPath,
  required final String contentType,
  required final int byteLength,
  required final DateTime createdAt,
});
