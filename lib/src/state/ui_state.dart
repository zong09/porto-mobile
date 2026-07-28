import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which filter pill the Transactions screen is showing:
/// `all | buy | sell | deposit-withdraw`.
///
/// This lives outside `_TransactionsScreenState` because it has a second
/// writer: the Realized P/L banner in Portfolio detail
/// (`design-portfolios.md:49` — it opens Transactions filtered to the sells
/// that produced the number). That banner sits in a route pushed *on top of*
/// the Portfolios tab, so it can reach neither the Transactions screen's State
/// nor the shell's.
///
/// Deliberately plain state rather than a one-shot "navigate" request: setting
/// it to a value it already holds is a no-op and correct, so there is nothing
/// to consume and no ordering to get wrong between the two listeners.
/// [AppShell] watches it to bring the Transactions tab forward.
class TxFilter extends Notifier<String> {
  @override
  String build() => 'all';

  void choose(String key) => state = key;
}

final txFilterProvider = NotifierProvider<TxFilter, String>(TxFilter.new);
