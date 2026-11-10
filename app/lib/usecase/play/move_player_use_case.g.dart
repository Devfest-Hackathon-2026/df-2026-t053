// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_player_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MovePlayerUseCase)
final movePlayerUseCaseProvider = MovePlayerUseCaseProvider._();

final class MovePlayerUseCaseProvider
    extends $NotifierProvider<MovePlayerUseCase, void> {
  MovePlayerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'movePlayerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$movePlayerUseCaseHash();

  @$internal
  @override
  MovePlayerUseCase create() => MovePlayerUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$movePlayerUseCaseHash() => r'1d2a50ab3e41ab3049f24867970a7b6a48b60ea9';

abstract class _$MovePlayerUseCase extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
