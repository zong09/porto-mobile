// Pure net-worth summary ported from backend `net-worth.service.ts#getSummary`.
// Plain inputs (CONTRACTS §4.2).

import 'position_calculator.dart';

class AssetInput {
  final String type; // 'crypto'|'th'|'us'|'fund'|'deposit'
  final String currency; // 'THB'|'USD'
  final String direction; // 'long'|'short'
  final double? manualPrice;
  final List<TxInput> txs;
  final double price; // resolved live/last price in the asset's NATIVE currency
  final double chg24h; // 24h % change

  const AssetInput({
    required this.type,
    required this.currency,
    required this.direction,
    required this.manualPrice,
    required this.txs,
    required this.price,
    required this.chg24h,
  });
}

class LiabilityInput {
  final double amount;
  final String currency; // 'THB'|'USD'

  const LiabilityInput({required this.amount, required this.currency});
}

class NetWorthSummary {
  final double totalAssetsThb;
  final double totalLiabilitiesThb;
  final double netWorthThb;
  final double todayPlThb;
  final double totalCostThb;
  final double fx;

  const NetWorthSummary({
    required this.totalAssetsThb,
    required this.totalLiabilitiesThb,
    required this.netWorthThb,
    required this.todayPlThb,
    required this.totalCostThb,
    required this.fx,
  });
}

class NetWorthCalculator {
  static NetWorthSummary summary({
    required List<AssetInput> assets,
    required List<LiabilityInput> liabilities,
    required double fx,
  }) {
    double totalLiabilitiesThb = 0;
    for (final l in liabilities) {
      totalLiabilitiesThb += l.amount * (l.currency == 'USD' ? fx : 1);
    }

    double totalAssetsThb = 0;
    double totalCostThb = 0;
    double todayPlThb = 0;

    for (final a in assets) {
      final pos = PositionCalculator.calculate(a.txs, direction: a.direction);
      if (pos.quantity <= 0) continue;

      final double price;
      if (a.type == 'deposit') {
        price = 1.0;
      } else if (a.type == 'fund') {
        price = a.manualPrice ?? 0.0;
      } else {
        price = a.price;
      }

      final multiplier = a.currency == 'USD' ? fx : 1;
      final assetValThb = pos.quantity * price * multiplier;
      final isShort = a.direction == 'short';

      totalAssetsThb += isShort ? -assetValThb : assetValThb;
      totalCostThb += pos.quantity * pos.avgCost * multiplier;

      if (a.chg24h != 0) {
        final rawPl = assetValThb - assetValThb / (1 + a.chg24h / 100);
        todayPlThb += isShort ? -rawPl : rawPl;
      }
    }

    final netWorthThb = totalAssetsThb - totalLiabilitiesThb;
    return NetWorthSummary(
      totalAssetsThb: totalAssetsThb,
      totalLiabilitiesThb: totalLiabilitiesThb,
      netWorthThb: netWorthThb,
      todayPlThb: todayPlThb,
      totalCostThb: totalCostThb,
      fx: fx,
    );
  }
}
