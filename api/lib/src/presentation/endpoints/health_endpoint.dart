import 'dart:io';

import 'package:photohunt_shared/photohunt_shared.dart';
// serverpod にも同名の HealthResponse があるため hide する。
import 'package:serverpod/serverpod.dart' hide HealthResponse;

/// 疎通確認用の運用 Endpoint。認証・DB・外部サービスに触れない。
class HealthEndpoint() extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<HealthResponse> ping(Session session, HealthRequest request) async {
    return HealthResponse(
      releaseId: Platform.environment['RELEASE_ID'] ?? 'dev',
      time: DateTime.now().toUtc(),
    );
  }
}
