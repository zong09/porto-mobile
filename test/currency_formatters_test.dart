import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/domain/currency_converter.dart';
import 'package:porto_mobile/src/domain/formatters.dart';

void main() {
  group('CurrencyConverter', () {
    test('toThb', () {
      expect(CurrencyConverter.toThb(10, 'USD', 30), 300);
      expect(CurrencyConverter.toThb(10, 'THB', 30), 10);
    });
    test('convert via THB', () {
      expect(CurrencyConverter.convert(300, 'THB', 'USD', 30), 10);
      expect(CurrencyConverter.convert(10, 'USD', 'THB', 30), 300);
      expect(CurrencyConverter.convert(5, 'THB', 'THB', 30), 5);
    });
  });

  group('Formatters', () {
    test('money', () {
      expect(Formatters.money(1234.5), '1,234.50');
      expect(Formatters.money(0), '0.00');
      expect(Formatters.money(-12.3), '-12.30');
      expect(Formatters.money(1000000), '1,000,000.00');
    });
    test('compact', () {
      expect(Formatters.compact(1200), '1.2K');
      expect(Formatters.compact(3400000), '3.4M');
      expect(Formatters.compact(950), '950.00');
      expect(Formatters.compact(1500000000), '1.5B');
    });
    test('pct', () {
      expect(Formatters.pct(1.234), '+1.23%');
      expect(Formatters.pct(-0.5), '-0.50%');
      expect(Formatters.pct(0), '+0.00%');
    });
  });
}
