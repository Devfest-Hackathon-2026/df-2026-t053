import 'dart:io';

import '../../domain/ports/signup_rate_limiter.dart';

/// Cloud Run直結ingressだけ右端のXFFを使う。外付けproxy追加時は再検証する。
class const SignupClientAddress({required final bool cloudRun}) {
  String key({String? peerAddress, Iterable<String> forwardedFor = const []}) {
    final String? raw;
    if (cloudRun) {
      final chain = forwardedFor.join(',');
      if (chain.isEmpty || chain.length > 4096) {
        throw const SignupClientAddressUnavailable();
      }
      raw = chain.split(',').last.trim();
    } else {
      raw = peerAddress;
    }
    if (raw == null || raw.isEmpty || raw.contains('%')) {
      throw const SignupClientAddressUnavailable();
    }
    final ip = InternetAddress.tryParse(raw);
    if (ip == null) throw const SignupClientAddressUnavailable();
    final bytes = ip.rawAddress;
    if (bytes.length == 16 &&
        bytes.take(10).every((b) => b == 0) &&
        bytes[10] == 255 &&
        bytes[11] == 255) {
      return 'ipv4:${bytes.skip(12).join('.')}';
    }
    if (bytes.length == 4) return 'ipv4:${ip.address}';
    final prefix = bytes
        .take(8)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'ipv6:$prefix/64';
  }
}
