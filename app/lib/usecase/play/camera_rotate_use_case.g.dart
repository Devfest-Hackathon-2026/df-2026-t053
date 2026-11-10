// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_rotate_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CameraRotateUseCase)
final cameraRotateUseCaseProvider = CameraRotateUseCaseProvider._();

final class CameraRotateUseCaseProvider
    extends $NotifierProvider<CameraRotateUseCase, void> {
  CameraRotateUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraRotateUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraRotateUseCaseHash();

  @$internal
  @override
  CameraRotateUseCase create() => CameraRotateUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$cameraRotateUseCaseHash() =>
    r'972851ff09b90d18fd05107360bfe68b8fd092b9';

abstract class _$CameraRotateUseCase extends $Notifier<void> {
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
