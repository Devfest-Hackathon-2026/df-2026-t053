// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// run:localが渡す接続先。指定がなければローカルのiOSシミュレーター用。

@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = ApiBaseUrlProvider._();

/// run:localが渡す接続先。指定がなければローカルのiOSシミュレーター用。

final class ApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// run:localが渡す接続先。指定がなければローカルのiOSシミュレーター用。
  ApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiBaseUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return apiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'e7550e54c561161a1b941c76f2bc6800db2736a1';

/// 機能に依存しない生成Client。認証の接続側もこのProviderを使用する。
/// このProviderが生成したClientの寿命はProviderが所有する。

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// 機能に依存しない生成Client。認証の接続側もこのProviderを使用する。
/// このProviderが生成したClientの寿命はProviderが所有する。

final class ApiClientProvider
    extends $FunctionalProvider<Client, Client, Client>
    with $Provider<Client> {
  /// 機能に依存しない生成Client。認証の接続側もこのProviderを使用する。
  /// このProviderが生成したClientの寿命はProviderが所有する。
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Client create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Client>(value),
    );
  }
}

String _$apiClientHash() => r'676840811d2293593e783871b210fa94549b004b';
