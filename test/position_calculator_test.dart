import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/domain/position_calculator.dart';

void main() {
  group('PositionCalculator', () {
    test('1. buys accumulate cost & quantity', () {
      final r = PositionCalculator.calculate([
        const TxInput(
            quantity: 0.2, price: 2350000, fee: 100, side: 'buy', date: '2026-01-01'),
        const TxInput(
            quantity: 0.1, price: 2400000, fee: 50, side: 'buy', date: '2026-01-02'),
      ]);
      expect(r.quantity, closeTo(0.3, 1e-9));
      expect(r.totalCost, closeTo(710150, 0.01));
      expect(r.avgCost, closeTo(2367166.67, 0.01));
      expect(r.realizedPnl, 0);
      expect(r.direction, 'long');
    });

    test('2. sell realizes PnL', () {
      final r = PositionCalculator.calculate([
        const TxInput(quantity: 0.2, price: 2350000, fee: 0, side: 'buy'),
        const TxInput(quantity: 0.05, price: 3300000, fee: 0, side: 'sell'),
      ]);
      expect(r.quantity, closeTo(0.15, 1e-9));
      expect(r.avgCost, closeTo(2350000, 0.01));
      expect(r.totalCost, closeTo(0.15 * 2350000, 0.01));
      expect(r.realizedPnl, closeTo(47500, 0.01));
      expect(r.direction, 'long');
    });

    test('3. deposit/withdraw', () {
      final r = PositionCalculator.calculate([
        const TxInput(quantity: 10000, price: 1, fee: 0, side: 'deposit'),
        const TxInput(quantity: 4000, price: 1, fee: 10, side: 'withdraw'),
      ]);
      expect(r.quantity, closeTo(6000, 1e-9));
      expect(r.realizedPnl, closeTo(-10, 1e-9));
      expect(r.direction, 'long');
    });

    test('4. short open', () {
      final r = PositionCalculator.calculate([
        const TxInput(quantity: 10, price: 150, fee: 5, side: 'sell'),
        const TxInput(quantity: 5, price: 160, fee: 3, side: 'sell'),
      ], direction: 'short');
      expect(r.quantity, closeTo(15, 1e-9));
      expect(r.totalCost, closeTo(2308, 0.01));
      expect(r.avgCost, closeTo(2308 / 15, 0.01));
      expect(r.realizedPnl, 0);
      expect(r.direction, 'short');
    });

    test('5. short cover profit', () {
      final r = PositionCalculator.calculate([
        const TxInput(quantity: 10, price: 200, fee: 0, side: 'sell'),
        const TxInput(quantity: 4, price: 150, fee: 0, side: 'buy'),
      ], direction: 'short');
      expect(r.quantity, closeTo(6, 1e-9));
      expect(r.avgCost, closeTo(200, 0.01));
      expect(r.realizedPnl, closeTo(200, 0.01));
      expect(r.direction, 'short');
    });

    test('6. short cover loss', () {
      final r = PositionCalculator.calculate([
        const TxInput(quantity: 10, price: 200, fee: 0, side: 'sell'),
        const TxInput(quantity: 4, price: 250, fee: 10, side: 'buy'),
      ], direction: 'short');
      expect(r.quantity, closeTo(6, 1e-9));
      expect(r.realizedPnl, closeTo(-210, 0.01));
      expect(r.direction, 'short');
    });

    test('7. short full close', () {
      final r = PositionCalculator.calculate([
        const TxInput(quantity: 5, price: 100, fee: 0, side: 'sell'),
        const TxInput(quantity: 5, price: 80, fee: 0, side: 'buy'),
      ], direction: 'short');
      expect(r.quantity, 0);
      expect(r.totalCost, 0);
      expect(r.realizedPnl, closeTo(100, 0.01));
      expect(r.direction, 'short');
    });
  });
}
