import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../prices/price_history_client.dart';
import '../../prices/price_repository.dart';
import 'chart_sheet.dart';
import 'sheet_shell.dart';

/// Crypto range pills — the full set from design-settings.md §"Chart sheet".
/// Every one maps to a real `cryptoHistory` day count.
const _cryptoRanges = ['7D', '30D', '90D', '1Y'];
const _cryptoDays = {'7D': 7, '30D': 30, '90D': 90, '1Y': 365};

/// Stock range pills, TRIMMED from the design's `1M 3M 6M 1Y ALL`.
///
/// `PriceHistoryClient.stockHistory` maps only `7D/1M/3M/1Y` and silently falls
/// back to `3mo` for anything else, so a `6M` or `ALL` pill would return
/// three-month data under a label that says otherwise — a control that lies,
/// which is the defect class `docs/next-session-plan.md` exists to stop.
const _stockRanges = ['1M', '3M', '1Y'];

/// Ranges offered for [type]. `fund` / `deposit` have no history source, so
/// they get none and [ChartSheet] renders its no-data note.
List<String> chartRangesFor(String type) {
  switch (type) {
    case 'crypto':
      return _cryptoRanges;
    case 'th':
    case 'us':
      return _stockRanges;
    default:
      return const [];
  }
}

/// Presents the price-history chart for [asset] — the entry point
/// design-settings.md:38 asks for ("opened from an asset row / asset detail").
///
/// [SheetShell] owns the title, so [ChartSheet] is given an empty one.
Future<void> showAssetChartSheet(BuildContext context, Asset asset) =>
    showPortoSheet(
      context,
      title: '${asset.name} · ${asset.symbol}',
      builder: (_) => AssetChartSheet(asset: asset),
    );

/// Fetches price history for one asset and feeds it to [ChartSheet],
/// refetching when the user switches range.
class AssetChartSheet extends ConsumerStatefulWidget {
  final Asset asset;

  const AssetChartSheet({super.key, required this.asset});

  @override
  ConsumerState<AssetChartSheet> createState() => _AssetChartSheetState();
}

class _AssetChartSheetState extends ConsumerState<AssetChartSheet> {
  List<PricePoint> _history = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final ranges = chartRangesFor(widget.asset.type);
    if (ranges.isNotEmpty) _load(ranges.first);
  }

  /// Mirrors `PriceRepository.resolve`'s symbol fallback — without the `.BK`
  /// suffix a Thai stock silently charts nothing.
  Future<List<PricePoint>> _fetch(String range) {
    final a = widget.asset;
    final client = ref.read(priceHistoryClientProvider);
    switch (a.type) {
      case 'crypto':
        return client.cryptoHistory(a.symbol, _cryptoDays[range] ?? 30);
      case 'th':
      case 'us':
        return client.stockHistory(
          a.yahooSymbol ?? (a.type == 'th' ? '${a.symbol}.BK' : a.symbol),
          range,
        );
      default:
        return Future.value(const []);
    }
  }

  Future<void> _load(String range) async {
    setState(() => _loading = true);
    List<PricePoint> history;
    try {
      history = await _fetch(range);
    } catch (_) {
      // Offline / bad symbol — fall through to ChartSheet's no-data note
      // rather than throwing inside a bottom sheet.
      history = const [];
    }
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A 2px bar rather than swapping in a spinner: ChartSheet owns the
        // active-range pill in its own State, and unmounting it would snap the
        // selection back to the first range on every refetch.
        SizedBox(
          height: 2,
          child: _loading ? const LinearProgressIndicator(minHeight: 2) : null,
        ),
        ChartSheet(
          title: '',
          history: _history,
          ranges: chartRangesFor(widget.asset.type),
          onRangeChange: _load,
        ),
      ],
    );
  }
}
