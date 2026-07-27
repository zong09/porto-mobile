import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/formatters.dart';
import 'overview_notifier.dart';
import 'settings_notifier.dart';

/// The display currency and the FX rate, resolved together so any screen can
/// render THB-denominated values in the user's chosen currency.
///
/// [DisplayMoney.fx] is always resolved, not just for USD display: screens also
/// need it to normalise **native** amounts to THB before summing (e.g. the
/// Liabilities total), which is required even when displaying THB. FX is
/// offline-safe — [fxProvider] falls back to the last cached rate and only
/// throws when it has never been cached (first-run offline), the same contract
/// `OverviewNotifier` already depends on.
///
/// Screens read this as
/// `ref.watch(displayMoneyProvider).valueOrNull ?? DisplayMoney.thb`
/// so a value is always available while it resolves. The fallback is exact for
/// all-THB data; a USD amount would be mis-normalised for the frame before this
/// resolves (or if FX has never been cached).
final displayMoneyProvider = FutureProvider<DisplayMoney>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final fx = await ref.watch(fxProvider)();
  return DisplayMoney(currency: settings.displayCurrency, fx: fx);
});
