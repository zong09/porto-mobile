// Pure avg-cost engine ported from the backend `position.service.ts`.
// Plain inputs — no DB, no freezed deps (CONTRACTS §4.1).

class TxInput {
  final double quantity;
  final double price;
  final double fee;
  final String side; // 'buy'|'sell'|'deposit'|'withdraw'
  final String? date; // 'YYYY-MM-DD' or null

  const TxInput({
    required this.quantity,
    required this.price,
    this.fee = 0,
    required this.side,
    this.date,
  });
}

class PositionSummary {
  final double quantity;
  final double avgCost;
  final double totalCost;
  final double realizedPnl;
  final String direction; // 'long'|'short'

  const PositionSummary({
    required this.quantity,
    required this.avgCost,
    required this.totalCost,
    required this.realizedPnl,
    required this.direction,
  });
}

class PositionCalculator {
  static PositionSummary calculate(
    List<TxInput> txs, {
    String direction = 'long',
  }) {
    // Stable sort: when both dates are non-null, order by date; otherwise keep
    // the original relative order (Dart's List.sort is not stable, so decorate
    // with the original index).
    final indexed = List.generate(txs.length, (i) => i);
    indexed.sort((ia, ib) {
      final a = txs[ia];
      final b = txs[ib];
      if (a.date != null && b.date != null) {
        final c = a.date!.compareTo(b.date!);
        if (c != 0) return c;
      }
      return ia.compareTo(ib);
    });

    double quantity = 0.0;
    double totalCost = 0.0;
    double realizedPnl = 0.0;

    for (final i in indexed) {
      final tx = txs[i];
      final q = tx.quantity;
      final p = tx.price;
      final f = tx.fee;

      if (direction == 'short') {
        if (tx.side == 'sell') {
          // sell opens short
          totalCost += q * p + f;
          quantity += q;
        } else if (tx.side == 'buy') {
          // buy covers
          final avgCost = quantity > 0 ? totalCost / quantity : 0;
          realizedPnl += q * (avgCost - p) - f;
          totalCost -= avgCost * q;
          quantity -= q;
          if (quantity < 1e-9) {
            quantity = 0;
            totalCost = 0;
          }
        }
      } else {
        // long
        if (tx.side == 'buy' || tx.side == 'deposit') {
          totalCost += q * p + f;
          quantity += q;
        } else if (tx.side == 'sell' || tx.side == 'withdraw') {
          final avgCost = quantity > 0 ? totalCost / quantity : 0;
          realizedPnl += q * (p - avgCost) - f;
          totalCost -= avgCost * q;
          quantity -= q;
          if (quantity < 1e-9) {
            quantity = 0;
            totalCost = 0;
          }
        }
      }
    }

    final avgCost = quantity > 0 ? totalCost / quantity : 0.0;
    return PositionSummary(
      quantity: quantity,
      avgCost: avgCost,
      totalCost: totalCost,
      realizedPnl: realizedPnl,
      direction: direction,
    );
  }
}
