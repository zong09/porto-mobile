import 'package:intl/intl.dart';
import 'currency_converter.dart';

/// Number formatters (CONTRACTS §4.3).
class Formatters {
  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');

  /// 2 decimals, thousands grouped, no currency symbol.
  /// e.g. money(1234.5) == '1,234.50', money(0) == '0.00', money(-12.3) == '-12.30'
  static String money(double v) => _money.format(v);

  /// 1.2K / 3.4M / 1.0B style, 1 decimal; abs < 1000 → money(v) 2dp.
  static String compact(double v) {
    final a = v.abs();
    if (a < 1000) return money(v);
    if (a < 1e6) return '${(v / 1e3).toStringAsFixed(1)}K';
    if (a < 1e9) return '${(v / 1e6).toStringAsFixed(1)}M';
    return '${(v / 1e9).toStringAsFixed(1)}B';
  }

  /// signed, 2 decimals, % suffix. pct(1.234) == '+1.23%', pct(-0.5) == '-0.50%'
  static String pct(double v) {
    final sign = v < 0 ? '-' : '+';
    return '$sign${v.abs().toStringAsFixed(2)}%';
  }
}

/// Renders **THB-denominated** amounts in the user's chosen display currency
/// (Settings › สกุลเงินหลัก).
///
/// This is the global *display* preference. It is deliberately NOT the native
/// currency of an asset or liability — that is locked at creation (CONTRACTS §7)
/// and rendered with its own glyph. Only pass THB-denominated values here.
class DisplayMoney {
  /// 'THB' | 'USD'
  final String currency;

  /// THB per 1 USD.
  final double fx;

  const DisplayMoney({required this.currency, required this.fx});

  /// The THB default, and the fallback while settings/FX are still resolving.
  /// Safe because converting THB→THB ignores [fx].
  static const thb = DisplayMoney(currency: 'THB', fx: 1);

  String get symbol => currency == 'USD' ? r'$' : '฿';

  /// Pill / row label, e.g. '฿ THB' or '$ USD'.
  String get label => '$symbol $currency';

  double convert(double amountThb) =>
      CurrencyConverter.convert(amountThb, 'THB', currency, fx);

  /// Converted, 2 decimals, no symbol.
  String money(double amountThb) => Formatters.money(convert(amountThb));

  /// Converted, 1.2K / 3.4M style, no symbol.
  String compact(double amountThb) => Formatters.compact(convert(amountThb));
}
