import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/formatters.dart';
import '../../domain/net_worth_calculator.dart';
import '../../state/overview_notifier.dart';
import '../theme/colors.dart';
import '../widgets/area_chart.dart';
import '../widgets/cards.dart';

/// Overview screen — gradient hero with net-worth, area chart, stat trio,
/// and portfolio list. Watches [overviewProvider] and renders fake state.
class OverviewScreen extends ConsumerWidget {
  /// Called when the Liabilities stat card is tapped (wired in T4.1 to push
  /// the Liabilities screen). Null → no-op.
  final VoidCallback? onOpenLiabilities;

  const OverviewScreen({super.key, this.onOpenLiabilities});

  // ── hero ─────────────────────────────────────────────────────────────

  static Widget _hero({
    required NetWorthSummary summary,
    required List<double> chartPoints,
    required bool offline,
    required String? asOf,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 68, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar row
          Row(
            children: [
              Text(
                'Porto',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _pill('ในเครื่่อง', 11, 3, 11,
                  bg: const Color(0x29FFFFFF)),
              const SizedBox(width: 8),
              _pill('฿ THB', 11.5, 3, 12,
                  bg: const Color(0x29FFFFFF), bold: true),
            ],
          ),
          const SizedBox(height: 14),

          // Net Worth label
          const Text(
            'Net Worth',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xBFFAF5EC), // rgba(250,245,236,0.75)
            ),
          ),

          // Net-worth value
          Text(
            Formatters.money(summary.netWorthThb, currency: 'THB'),
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.015,
            ),
          ),

          // Change row
          const SizedBox(height: 6),
          Row(
            children: [
              _gainPill(summary.todayPlThb),
              const SizedBox(width: 8),
              Text(
                '+${Formatters.pct((summary.todayPlThb / (summary.netWorthThb - summary.todayPlThb) * 100)).replaceAll('%', '').replaceAll('+', '').replaceAll('-', '')} · วันนนี้ +${Formatters.money(summary.todayPlThb)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xCCFAF5EC), // rgba(250,245,236,0.8)
                ),
              ),
            ],
          ),

          // Area chart
          const SizedBox(height: 12),
          SizedBox(
            height: 74,
            child: AreaChart(
              chartPoints,
              line: Colors.white,
              fill: const Color(0x24FFFFFF), // 0x24FFFFFF
              showEndDot: true,
            ),
          ),

          // Timeframe pills
          const SizedBox(height: 8),
          Row(
            children: ['1D', '1W', '1M', '1Y', 'ALL'].map((label) {
              final active = label == '1D';
              return _timeframePill(label, active);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── stat trio ────────────────────────────────────────────────────────

  static Widget _statRow({
    required NetWorthSummary summary,
    VoidCallback? onOpenLiabilities,
  }) {
    return Row(
      spacing: 9,
      children: [
        Expanded(
          child: StatCard(
            label: 'Assets',
            value: Formatters.compact(summary.totalAssetsThb),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onOpenLiabilities,
            behavior: HitTestBehavior.opaque,
            child: StatCard(
              label: 'Liabilities',
              value: Formatters.compact(summary.totalLiabilitiesThb),
              valueColor: const Color(0xFFA8341C),
            ),
          ),
        ),
        Expanded(
          child: StatCard(
            label: 'กำไรรวม',
            value: Formatters.pct(
                (summary.todayPlThb / summary.totalCostThb) * 100),
            valueColor: const Color(0xFF177E81),
          ),
        ),
      ],
    );
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(overviewProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (st) {
        // Empty / first-run state
        if (st.summary == null) {
          return const Center(
            child: Text(
              'เริ่้มใช้เลย',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        }

        final chartPoints =
            st.history.map((h) => h.netWorthThb).toList();

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _hero(
                        summary: st.summary!,
                        chartPoints: chartPoints,
                        offline: st.offline,
                        asOf: st.asOf,
                      ),

                      const SizedBox(height: 13),

                      // Cream sheet
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.bg,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                            20, 20, 20, 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Offline banner
                            if (st.offline && st.asOf != null)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE9DB),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Text(
                                  'as of ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(st.asOf!))}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFC24A1E),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (st.offline && st.asOf != null)
                              const SizedBox(height: 13),

                            // Stat trio
                            _statRow(
                              summary: st.summary!,
                              onOpenLiabilities: onOpenLiabilities,
                            ),

                            // Section header
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                const Text(
                                  'พอรต์ของฉน',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'ดทู้งหมด',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brand,
                                  ),
                                ),
                              ],
                            ),

                            // Simple placeholder for portfolio list
                            const SizedBox(height: 13),
                            PlainCard(
                              child: const Center(
                                child: Text(
                                  'Portfolio list — coming in T3.06',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────

  static Widget _pill(String text, double fontSize, double py, double px,
      {Color? bg, bool bold = false}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: const Color(0xFAFAF5EC),
        ),
      ),
    );
  }

  static Widget _gainPill(double todayPlThb) {
    final isPositive = todayPlThb >= 0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEBFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isPositive ? '▲' : '▼',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPositive
                  ? const Color(0xFF177E81)
                  : const Color(0xFFA8341C),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '+฿${Formatters.money(todayPlThb)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF177E81),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _timeframePill(String label, bool active) {
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
}
