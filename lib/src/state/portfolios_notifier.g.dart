// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolios_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PortfoliosNotifier)
final portfoliosProvider = PortfoliosNotifierProvider._();

final class PortfoliosNotifierProvider
    extends $AsyncNotifierProvider<PortfoliosNotifier, PortfoliosState> {
  PortfoliosNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfoliosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfoliosNotifierHash();

  @$internal
  @override
  PortfoliosNotifier create() => PortfoliosNotifier();
}

String _$portfoliosNotifierHash() =>
    r'ff01d2f035aac17e6319855aae9b0b4372fc6cec';

abstract class _$PortfoliosNotifier extends $AsyncNotifier<PortfoliosState> {
  FutureOr<PortfoliosState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PortfoliosState>, PortfoliosState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PortfoliosState>, PortfoliosState>,
              AsyncValue<PortfoliosState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
