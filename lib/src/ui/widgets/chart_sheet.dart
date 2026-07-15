import 'package:flutter/material.dart';
import '../../prices/price_history_client.dart';
import '../../ui/theme/colors.dart';
import '../widgets/area_chart.dart';

// -----------------------------------------------------------------------------
// ChartSheet  —  bottom-sheet price-history view (StatefulWidget)
// -----------------------------------------------------------------------------

class ChartSheet extends StatefulWidget {
  final String title;
  final List<PricePoint> history;
  final List<String> ranges;
  final ValueChanged<String>? onRangeChange;

  const ChartSheet({
    super.key,
    required this.title,
    required this.history,
    required this.ranges,
    this.onRangeChange,
  });

  @override
  State<ChartSheet> createState() => _ChartSheetState();
}

class _ChartSheetState extends State<ChartSheet> {
  late String _activeRange;

  @override
  void initState() {
    super.initState();
    _activeRange = widget.ranges.isNotEmpty ? widget.ranges.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.history;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        // Current price + change pill
        if (history.isNotEmpty) ..._buildPriceHeader(history),
        if (history.isEmpty) ..._buildNoData(),
        const SizedBox(height: 14),
        // AreaChart
        if (history.isNotEmpty) ..._buildChart(history),
        if (history.isEmpty) const SizedBox(height: 14),
        // Range pills
        _buildRangePills(),
      ],
    );
  }

  // --- Price header ---

  List<Widget> _buildPriceHeader(List<PricePoint> history) {
    final last = history.last.p;
    final first = history.first.p;
    final change = first != 0 ? ((last - first) / first * 100) : 0.0;
    final isPositive = change >= 0;
    final sign = isPositive ? '+' : '';
    final changeText = '$sign${change.abs().toStringAsFixed(2)}%';

    return [
      Row(
        children: [
          Text(
            last.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFFDDF3F3)
                  : const Color(0xFFFCDFD4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              changeText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPositive
                    ? const Color(0xFF177E81)
                    : const Color(0xFFA8341C),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
    ];
  }

  // --- No data ---

  List<Widget> _buildNoData() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'ไมมมีข้อมลราคายอนหลง',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.muted2,
            ),
          ),
        ),
      ),
    ];
  }

  // --- Area chart ---

  List<Widget> _buildChart(List<PricePoint> history) {
    final values = history.map((e) => e.p).toList();

    return [
      SizedBox(
        height: 160,
        child: AreaChart(
          values,
          line: AppColors.brand,
          fill: AppColors.brand.withAlpha(71),
          showEndDot: true,
          strokeWidth: 2,
        ),
      ),
      const SizedBox(height: 14),
    ];
  }

  // --- Range pills ---

  Widget _buildRangePills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.ranges.map((range) {
          final isActive = range == _activeRange;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: _RangePill(
              label: range,
              active: isActive,
              onTap: () {
                setState(() {
                  _activeRange = range;
                });
                widget.onRangeChange?.call(range);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A single range pill (cream-variant).
class _RangePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RangePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.text : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.bg : const Color(0xFF6B5D49),
          ),
        ),
      ),
    );
  }
}
