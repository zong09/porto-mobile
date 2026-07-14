import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/domain/position_calculator.dart';
import 'package:porto_mobile/src/domain/net_worth_calculator.dart';

void main() {
  group('NetWorthCalculator', () {
    test('G1 long crypto USD + THB deposit + USD liability', () {
      final r = NetWorthCalculator.summary(
        assets: [
          const AssetInput(
            type: 'crypto',
            currency: 'USD',
            direction: 'long',
            manualPrice: null,
            txs: [
              TxInput(
                  quantity: 1, price: 100, fee: 0, side: 'buy', date: '2026-01-01'),
            ],
            price: 110,
            chg24h: 10,
          ),
          const AssetInput(
            type: 'deposit',
            currency: 'THB',
            direction: 'long',
            manualPrice: null,
            txs: [
              TxInput(
                  quantity: 1000,
                  price: 1,
                  fee: 0,
                  side: 'deposit',
                  date: '2026-01-01'),
            ],
            price: 0,
            chg24h: 0,
          ),
        ],
        liabilities: [const LiabilityInput(amount: 50, currency: 'USD')],
        fx: 30,
      );
      expect(r.totalAssetsThb, closeTo(4300, 0.01));
      expect(r.totalLiabilitiesThb, closeTo(1500, 0.01));
      expect(r.netWorthThb, closeTo(2800, 0.01));
      expect(r.totalCostThb, closeTo(4000, 0.01));
      expect(r.todayPlThb, closeTo(300, 0.01));
      expect(r.fx, 30);
    });

    test('G2 short subtracts', () {
      final r = NetWorthCalculator.summary(
        assets: [
          const AssetInput(
            type: 'us',
            currency: 'USD',
            direction: 'short',
            manualPrice: null,
            txs: [
              TxInput(
                  quantity: 1, price: 100, fee: 0, side: 'sell', date: '2026-01-01'),
            ],
            price: 100,
            chg24h: 0,
          ),
        ],
        liabilities: [],
        fx: 30,
      );
      expect(r.totalAssetsThb, closeTo(-3000, 0.01));
      expect(r.netWorthThb, closeTo(-3000, 0.01));
      expect(r.totalCostThb, closeTo(3000, 0.01));
      expect(r.todayPlThb, 0);
    });

    test('G3 fund uses manualPrice, THB', () {
      final r = NetWorthCalculator.summary(
        assets: [
          const AssetInput(
            type: 'fund',
            currency: 'THB',
            direction: 'long',
            manualPrice: 25,
            txs: [
              TxInput(
                  quantity: 10, price: 20, fee: 0, side: 'buy', date: '2026-01-01'),
            ],
            price: 0,
            chg24h: 0,
          ),
        ],
        liabilities: [],
        fx: 30,
      );
      expect(r.totalAssetsThb, closeTo(250, 0.01));
      expect(r.totalCostThb, closeTo(200, 0.01));
    });
  });
}
