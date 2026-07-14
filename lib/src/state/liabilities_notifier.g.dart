// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liabilities_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiabilitiesNotifier)
final liabilitiesProvider = LiabilitiesNotifierProvider._();

final class LiabilitiesNotifierProvider
    extends $AsyncNotifierProvider<LiabilitiesNotifier, LiabilitiesState> {
  LiabilitiesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liabilitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liabilitiesNotifierHash();

  @$internal
  @override
  LiabilitiesNotifier create() => LiabilitiesNotifier();
}

String _$liabilitiesNotifierHash() =>
    r'952e51ea82da36cf8f0fb80fa9dfa38c5331ed1e';

abstract class _$LiabilitiesNotifier extends $AsyncNotifier<LiabilitiesState> {
  FutureOr<LiabilitiesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LiabilitiesState>, LiabilitiesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LiabilitiesState>, LiabilitiesState>,
              AsyncValue<LiabilitiesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
