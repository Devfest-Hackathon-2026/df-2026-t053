import 'package:app/provider/api_client/provider.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

/// パビリオンマスター一覧を API から取得する。
@Riverpod(keepAlive: true)
class PavilionNotifier extends _$PavilionNotifier {
  @override
  Future<List<Pavilion>> build() async {
    final client = ref.watch(apiClientProvider);
    final response = await client.pavilion.listPavilions();
    return response.pavilions;
  }
}
