/// Native ↔ THB base currency conversion (CONTRACTS §4.3).
/// Currency strings are 'THB' | 'USD'.
class CurrencyConverter {
  /// native → THB base: multiplier = currency=='USD' ? fx : 1
  static double toThb(double amount, String currency, double fx) =>
      amount * (currency == 'USD' ? fx : 1);

  /// convert `amount` from one currency to another, via THB.
  static double convert(double amount, String from, String to, double fx) {
    final thb = toThb(amount, from, fx);
    return to == 'USD' ? thb / fx : thb;
  }
}
