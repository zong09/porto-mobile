import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/formatters.dart';
import '../../state/transactions_notifier.dart';
import '../theme/colors.dart';
import '../widgets/cards.dart';

/// Transactions screen — gradient hero with date-grouped tx list + filter pills.
///
/// Watches [transactionsProvider]; filter state is local (StatefulWidget).
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState
    extends ConsumerState<TransactionsScreen> {
  String _filter = 'all'; // all | buy | sell | deposit-withdraw

  static const _pillLabels = ['ทั้งหมด', 'ซื้้่อ', 'ขาย', 'ฝาก/ถอน'];

  int _activePill = 0;

  // ── hero ─────────────────────────────────────────────────────────────

  static Widget _hero({
    required List<MapEntry<String, double>> buySellTotals,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 68, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'รายการ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),

          // Summary line
          Text(
            _summaryText(buySellTotals),
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xCCFAF5EC), // rgba(250,245,236,0.8)
            ),
          ),

          // Filter pills
          const SizedBox(height: 12),
          Row(
            spacing: 7,
            children: List.generate(
              _pillLabels.length,
              (i) => _filterPill(_pillLabels[i], i == 0),
            ),
          ),
        ],
      ),
    );
  }

  static String _summaryText(List<MapEntry<String, double>> totals) {
    final parts = <String>[];
    for (final e in totals) {
      if (e.value != 0) {
        parts.add('${e.key} ฿${Formatters.money(e.value)}');
      }
    }
    return parts.isEmpty ? '' : parts.join(' · ');
  }

  static Widget _filterPill(String label, bool active) {
    return Container(
      decoration: BoxDecoration(
        color: active
            ? const Color(0xEBFFFFFF)
            : const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: active
              ? const Color(0xFFC24A1E)
              : const Color(0xCCFAF5EC),
        ),
      ),
    );
  }

  // ── row icon ─────────────────────────────────────────────────────────

  static Widget _sideIcon(String side) {
    final bg = _sideBg(side);
    final fg = _sideFg(side);
    final glyph = _sideGlyph(side);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          glyph,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }

  static Color _sideBg(String side) {
    switch (side) {
      case 'buy':
        return AppColors.gainBg;
      case 'sell':
        return AppColors.lossBg;
      case 'deposit':
        return AppColors.gold;
      case 'withdraw':
        return AppColors.rose;
      default:
        return AppColors.muted3;
    }
  }

  static Color _sideFg(String side) {
    switch (side) {
      case 'buy':
        return AppColors.gain;
      case 'sell':
        return AppColors.loss;
      case 'deposit':
      case 'withdraw':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  static String _sideGlyph(String side) {
    switch (side) {
      case 'buy':
        return '↓';
      case 'sell':
        return '↑';
      case 'deposit':
        return '＋';
      case 'withdraw':
        return '−';
      default:
        return '?';
    }
  }

  static String _sideLabel(String side) {
    switch (side) {
      case 'buy':
        return 'ซื้้่อ';
      case 'sell':
        return 'ขาย';
      case 'deposit':
        return 'ฝาก';
      case 'withdraw':
        return 'ถอน';
      default:
        return side;
    }
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(transactionsProvider);

    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (state) {
        final groups = state.groups;

        // Compute buy/sell totals for summary
        final totals = <String, double>{'ซื้้่อ': 0, 'ขาย': 0};
        for (final g in groups) {
          for (final row in g.rows) {
            final side = row.tx.side;
            if (side == 'buy' || side == 'sell') {
              totals[side] =
                  (totals[side] ?? 0) + row.tx.quantity * row.tx.price;
            }
          }
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEC6530),
                Color(0xFFC24A1E),
                Color(0xFF9A3614),
              ],
            ),
          ),
          child: Column(
            children: [
              // Hero on gradient
              _hero(buySellTotals: totals.entries.toList()),

              // Filter pills (with local state)
              Padding(
                padding:
                    const EdgeInsets.only(left: 22, right: 22, bottom: 12),
                child: Row(
                  spacing: 7,
                  children: List.generate(
                    _pillLabels.length,
                    (i) => _filterPill(_pillLabels[i], _activePill == i),
                  ),
                ),
              ),

              // Cream sheet
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildGroups(groups),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── group / row builders ─────────────────────────────────────────────

  List<Widget> _buildGroups(List<TxGroup> groups) {
    final result = <Widget>[];
    for (final group in groups) {
      // Filter rows
      final filtered = _filterRows(group.rows);
      if (filtered.isEmpty) continue;

      // Date header
      result.add(Padding(
        padding: const EdgeInsets.only(top: 11, bottom: 4),
        child: Text(
          group.date,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted2),
        ),
      ));

      // Divided card
      result.add(PlainCard(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: DividedCard(rows: filtered),
      ));

      result.add(const SizedBox(height: 11));
    }
    return result;
  }

  List<Widget> _filterRows(List<TxRow> rows) {
    if (_filter == 'all') {
      return rows.map(_rowTile).toList();
    }
    if (_filter == 'deposit-withdraw') {
      return rows
          .where((r) =>
              r.tx.side == 'deposit' || r.tx.side == 'withdraw')
          .map(_rowTile)
          .toList();
    }
    return rows
        .where((r) => r.tx.side == _filter)
        .map(_rowTile)
        .toList();
  }

  Widget _rowTile(TxRow row) {
    final tx = row.tx;
    final asset = row.asset;
    final side = tx.side;
    final total = tx.quantity * tx.price + tx.fee;

    return ListRowTile(
      leading: _sideIcon(side),
      title: '${_sideLabel(side)} ${asset.symbol}',
      subtitle:
          '${Formatters.money(tx.quantity)} @ ${Formatters.money(tx.price)} · ${asset.name}',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _signedAmount(total, side, asset.currency),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      onTap: () {
        // Open form in edit mode — pops for now
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit ${tx.id}')),
        );
      },
    );
  }

  String _signedAmount(double amount, String side, String currency) {
    final prefix = currency == 'THB' ? '฿' : r'$';
    final formatted = Formatters.money(amount.abs(), currency: currency);
    switch (side) {
      case 'buy':
        return '-$prefix$formatted';
      case 'sell':
      case 'deposit':
        return '+$prefix$formatted';
      case 'withdraw':
        return '-$prefix$formatted';
      default:
        return '$prefix$formatted';
    }
  }
}
