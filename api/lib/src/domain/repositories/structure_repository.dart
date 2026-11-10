import '../models/models.dart';

abstract interface class StructureRepository() {
  /// 版の構造物を id の昇順で返す。出典（sources）を含む。
  Future<List<Structure>> listByRevision(int revisionId);
}
