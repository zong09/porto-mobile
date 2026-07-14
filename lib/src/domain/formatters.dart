import 'package:intl/intl.dart';

/// Number formatters (CONTRACTS §4.3).
class Formatters {
  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');

  /// 2 decimals, thousands grouped, no currency symbol.
  /// e.g. money(1234.5) == '1,234.50', money(0) == '0.00', money(-12.3) == '-12.30'
  static String money(double v, {String currency = 'USD'}) => _money.format(v);

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
