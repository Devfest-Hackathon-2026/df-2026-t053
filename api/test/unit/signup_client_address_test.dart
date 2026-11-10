import 'package:photohunt_server/src/domain/ports/signup_rate_limiter.dart';
import 'package:photohunt_server/src/presentation/request/signup_client_address.dart';
import 'package:test/test.dart';

void main() {
  const local = SignupClientAddress(cloudRun: false);
  const cloud = SignupClientAddress(cloudRun: true);

  test('ローカルは偽装可能な代理ヘッダーを無視しsocketのIPを使う', () {
    expect(
      local.key(peerAddress: '127.0.0.1', forwardedFor: ['203.0.113.1']),
      'ipv4:127.0.0.1',
    );
  });
  test('Cloud Runは右端だけを採用し、左側の変更で枠をリセットしない', () {
    for (final spoofed in ['192.0.2.1', '192.0.2.2, 192.0.2.3', 'invalid']) {
      expect(
        cloud.key(
          peerAddress: '127.0.0.1',
          forwardedFor: ['$spoofed, 203.0.113.1'],
        ),
        'ipv4:203.0.113.1',
      );
    }
    expect(
      cloud.key(forwardedFor: ['192.0.2.1', ' 203.0.113.1 ']),
      'ipv4:203.0.113.1',
    );
  });
  test('Cloud Runのヘッダー欠落・不正値はproxyのIPへfallbackしない', () {
    for (final headers in <List<String>>[
      [],
      [''],
      ['203.0.113.1,'],
      ['203.0.113.1, invalid'],
      ['unknown'],
      ['example.com'],
      ['203.0.113.1:1234'],
      ['[2001:db8::1]'],
      ['fe80::1%eth0'],
      ['a' * 4097],
    ]) {
      expect(
        () => cloud.key(peerAddress: '127.0.0.1', forwardedFor: headers),
        throwsA(isA<SignupClientAddressUnavailable>()),
      );
    }
    expect(() => local.key(), throwsA(isA<SignupClientAddressUnavailable>()));
  });
  test('IPv6の表記違いと同じ/64を同一キーにまとめる', () {
    final first = local.key(peerAddress: '2001:db8:1:2::1');
    expect(first, 'ipv6:20010db800010002/64');
    expect(
      local.key(peerAddress: '2001:0db8:0001:0002:ffff:ffff:ffff:ffff'),
      first,
    );
    expect(local.key(peerAddress: '2001:db8:1:3::1'), isNot(first));
  });
  test('IPv4-mapped IPv6とIPv4を同じキーにまとめる', () {
    expect(
      local.key(peerAddress: '::ffff:203.0.113.1'),
      local.key(peerAddress: '203.0.113.1'),
    );
  });
}
