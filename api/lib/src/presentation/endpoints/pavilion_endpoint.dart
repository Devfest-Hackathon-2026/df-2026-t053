import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../endpoint_call.dart';

/// 万博パビリオンマスターの一覧を返す。
///
/// DB 行をそのまま返さず、shared の [Pavilion] DTO にマッピングして返す。
/// 認証済みユーザー向け。
class PavilionEndpoint() extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ListPavilionsResponse> listPavilions(Session session) =>
      guardUnclassifiedFailure(
        session: session,
        logLabel: 'パビリオン一覧の取得に失敗しました',
        action: () async {
          final rows = await PavilionRow.db.find(session, orderBy: (t) => t.id);
          return ListPavilionsResponse(
            pavilions: [
              for (final row in rows)
                Pavilion(
                  id: row.id ?? 0,
                  sourceKey: row.sourceKey,
                  name: row.name,
                  latitude: row.lat,
                  longitude: row.lon,
                ),
            ],
          );
        },
      );
}
