// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overview_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OverviewNotifier)
final overviewProvider = OverviewNotifierProvider._();

final class OverviewNotifierProvider
    extends $AsyncNotifierProvider<OverviewNotifier, OverviewState> {
  OverviewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'overviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$overviewNotifierHash();

  @$internal
  @override
  OverviewNotifier create() => OverviewNotifier();
}

String _$overviewNotifierHash() => r'744828a6a3cc0b6d7e277d62597c651c0409ce0a';

abstract class _$OverviewNotifier extends $AsyncNotifier<OverviewState> {
  FutureOr<OverviewState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OverviewState>, OverviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OverviewState>, OverviewState>,
              AsyncValue<OverviewState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
