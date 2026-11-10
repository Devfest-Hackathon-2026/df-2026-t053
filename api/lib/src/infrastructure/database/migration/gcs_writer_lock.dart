import '../../../application/migration/migration_ports.dart';
import '../replication/writer_ownership.dart';

/// API・seed と共通の writer 所有権（GCS のオブジェクト）を、migration Job の port に合わせる。
///
/// [_manager] は取得のときに作る（設定の不足は、所有権を使うコマンドでだけ失敗にする）。
class GcsWriterLock(final WriterOwnershipManager Function() _manager)
    implements WriterLock {
  @override
  Future<HeldWriterLock> acquire() async {
    final manager = _manager();
    try {
      return _HeldGcsWriterLock(manager, await manager.acquire());
    } on WriterOwnershipUnavailable catch (e) {
      throw WriterLockUnavailable(e.message);
    }
  }
}

class _HeldGcsWriterLock(
  final WriterOwnershipManager _manager,
  final WriterOwnership _ownership,
) implements HeldWriterLock {
  @override
  String get description =>
      'ownerId=${_ownership.ownerId} generation=${_ownership.generation}';

  @override
  Future<void> release() async {
    try {
      await _manager.release(_ownership);
    } on WriterOwnershipUnavailable catch (e) {
      throw WriterLockUnavailable(e.message);
    }
  }
}
