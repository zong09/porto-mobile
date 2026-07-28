import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:porto_mobile/src/domain/formatters.dart';
import 'package:porto_mobile/src/state/display_money.dart';
import 'package:porto_mobile/src/state/portfolios_notifier.dart';
import 'package:porto_mobile/src/ui/theme/colors.dart';
import 'package:porto_mobile/src/ui/widgets/area_chart.dart';
import 'package:porto_mobile/src/ui/widgets/asset_sheet.dart';
import 'package:porto_mobile/src/ui/widgets/cards.dart';
import 'package:porto_mobile/src/ui/widgets/donut_chart.dart';
import 'package:porto_mobile/src/ui/widgets/portfolio_sheet.dart';
import 'package:porto_mobile/src/ui/widgets/sheet_shell.dart';

/// Glyph for an asset's OWN currency. Single-asset rows render their native
/// amount, so they must not borrow the display-currency symbol.
String _nativeSymbolOf(String currency) => currency == 'USD' ? r'$' : '฿';

/// Maps an asset type wire string to its palette index (crypto=0 … deposit=4).
int _assetTypeIndex(String type) {
  const order = ['crypto', 'th', 'us', 'fund', 'deposit'];
  final i = order.indexOf(type);
  return i < 0 ? 0 : i;
}

// -----------------------------------------------------------------------------
// PortfoliosScreen  —  list view (ConsumerWidget)
// -----------------------------------------------------------------------------

class PortfoliosScreen extends ConsumerWidget {
  const PortfoliosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfoliosProvider);
    final nodes = state.value?.nodes ?? const <PortfolioNode>[];
    final money = ref.watch(displayMoneyProvider).value ?? DisplayMoney.thb;

    // Total cost basis across all portfolios, normalised to THB first.
    final totalCostThb = nodes.fold<double>(
      0,
      (sum, n) => sum + nodeCostThb(n, money.fx),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brand,
              AppColors.brandD,
              AppColors.brandDd,
            ],
          ),
        ),
        child: Column(
          children: [
            // --- Hero region ---
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 68, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      const Text(
                        'พอร์ตของฉัน',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFAF5EC),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _showCreatePortfolioSheet(context),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xECEDEDED),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '+ สร้างพอร์ต',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC24A1E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Label
                  const Text(
                    'มูลค่าการลงทุนรวม',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xBFFAF5EC),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Total value
                  Text(
                    money.money(totalCostThb),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Allocation bar
                  _AllocationBar(nodes: nodes, fx: money.fx),
                ],
              ),
            ),
            // --- Cream sheet ---
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF5EC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...nodes.map(
                          (node) => _PortfolioCard(node: node, money: money)),
                      // Dashed create-new card
                      _CreateNewCard(
                        label: '+ สร้างพอร์ตใหม่',
                        onTap: () => _showCreatePortfolioSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePortfolioSheet(BuildContext context) {
    showPortoSheet(
      context,
      title: 'สร้างพอร์ตใหม่',
      builder: (_) => const PortfolioCreateSheet(),
    );
  }
}

// -----------------------------------------------------------------------------
// PortfolioDetailScreen  —  detail sub-screen (takes a PortfolioNode)
// -----------------------------------------------------------------------------

class PortfolioDetailScreen extends ConsumerWidget {
  /// The node as of the moment this screen was pushed — a FALLBACK only.
  ///
  /// The live node is re-read from [portfoliosProvider] on every build. Reading
  /// this snapshot directly would freeze the screen: an asset added from here
  /// would not appear until the user popped and re-entered.
  final PortfolioNode node;

  const PortfolioDetailScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes =
        ref.watch(portfoliosProvider).value?.nodes ?? const <PortfolioNode>[];
    final live = nodes.where((n) => n.portfolio.id == node.portfolio.id);
    final current = live.isEmpty ? node : live.first;

    final portfolio = current.portfolio;
    final assets = current.assets;
    final money = ref.watch(displayMoneyProvider).value ?? DisplayMoney.thb;

    // Aggregates across possibly-mixed currencies — convert before summing.
    final valueThb = assetsCostThb(assets, money.fx);
    final realizedPnlThb = assets.fold<double>(
      0,
      (sum, an) => sum + assetRealizedPnlThb(an, money.fx),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brand,
              AppColors.brandD,
              AppColors.brandDd,
            ],
          ),
        ),
        child: Column(
          children: [
            // --- Hero ---
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 68, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: back + name + edit chip
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x29FFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '\u{2039}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFFAF5EC),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        portfolio.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFAF5EC),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x29FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'แก้ไข',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFAF5EC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Value
                  Text(
                    money.money(valueThb),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Allocation bar over assets
                  _AssetAllocationBar(assets: assets, fx: money.fx),
                ],
              ),
            ),
            // --- Cream sheet ---
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF5EC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title
                      const Text(
                        'สินทรัพย์ในพอร์ต',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D3328),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Featured asset card (first asset)
                      if (assets.isNotEmpty) _FeaturedAssetCard(assetNode: assets.first),

                      // Remaining assets
                      if (assets.length > 1) ...[
                        const SizedBox(height: 2),
                        DividedCard(
                          rows: assets.skip(1).map((an) => _AssetRow(an: an)).toList(),
                        ),
                      ],

                      const SizedBox(height: 11),

                      // Dashed add-asset card — the ONLY way to create an
                      // asset, so it must render even when the list is empty.
                      _CreateNewCard(
                        label: '+ เพิ่มสินทรัพย์',
                        onTap: () => showPortoSheet(
                          context,
                          title: 'เพิ่มสินทรัพย์',
                          builder: (_) => AssetSheet(portfolioId: portfolio.id),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Realized P/L banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Realized P/L ปีนี้ ${realizedPnlThb >= 0 ? '+' : ''}${money.symbol}${money.money(realizedPnlThb)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF6B5D49),
                                ),
                              ),
                            ),
                            const Text(
                              '\u{203A}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFC24A1E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Supporting widgets
// -----------------------------------------------------------------------------

/// Segmented allocation bar on the gradient hero.
class _AllocationBar extends StatelessWidget {
  final List<PortfolioNode> nodes;

  /// THB per USD — segment widths are proportions of a mixed-currency total,
  /// so they are wrong unless every node is normalised first.
  final double fx;

  const _AllocationBar({required this.nodes, required this.fx});

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    final total = nodes.fold<double>(0, (sum, n) => sum + nodeCostThb(n, fx));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0x4AFFFFFF),
          ),
          child: Row(
            children: nodes.map((node) {
              final pct = total > 0 ? nodeCostThb(node, fx) / total : 0;
              return Expanded(
                flex: (pct * 100).toInt().clamp(0, 100),
                child: Container(
                  color: AppColors.palette[node.portfolio.color],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: nodes.map((node) {
            final pct = total > 0 ? nodeCostThb(node, fx) / total : 0;
            return Text(
              '${node.portfolio.name} ${(pct * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xD9FAF5EC),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Asset-level allocation bar inside PortfolioDetail.
class _AssetAllocationBar extends StatelessWidget {
  final List<AssetNode> assets;

  /// THB per USD — see [_AllocationBar.fx].
  final double fx;

  const _AssetAllocationBar({required this.assets, required this.fx});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const SizedBox.shrink();

    final total = assetsCostThb(assets, fx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0x4AFFFFFF),
          ),
          child: Row(
            children: assets.map((an) {
              final pct = total > 0 ? assetCostThb(an, fx) / total : 0;
              return Expanded(
                flex: (pct * 100).toInt().clamp(0, 100),
                child: Container(
                  color: AppColors.palette[_assetTypeIndex(an.asset.type)],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: assets.map((an) {
            final pct = total > 0 ? assetCostThb(an, fx) / total : 0;
            return Text(
              '${an.asset.symbol} ${(pct * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xD9FAF5EC),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// One portfolio card in the list.
class _PortfolioCard extends StatelessWidget {
  final PortfolioNode node;
  final DisplayMoney money;

  const _PortfolioCard({required this.node, required this.money});

  @override
  Widget build(BuildContext context) {
    final portfolio = node.portfolio;
    final assets = node.assets;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: PlainCard(
        child: ListRowTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.palette[portfolio.color].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DonutChart(
              assets.isEmpty
                  ? [DonutSlice(1, AppColors.palette[portfolio.color])]
                  : assets
                      .map((an) => DonutSlice(
                            an.position.totalCost,
                            AppColors.palette[_assetTypeIndex(an.asset.type)],
                          ))
                      .toList(),
              strokeFraction: 0.34,
            ),
          ),
          title: portfolio.name,
          subtitle: '${assets.length} สินทรัพย์',
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                money.money(nodeCostThb(node, money.fx)),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PortfolioDetailScreen(node: node),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Dashed "create new" card at the end of a list.
class _CreateNewCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CreateNewCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD9CBB4),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA89A86),
            ),
          ),
        ),
      ),
    );
  }
}

/// Featured asset card — first asset in the portfolio.
class _FeaturedAssetCard extends StatelessWidget {
  final AssetNode assetNode;

  const _FeaturedAssetCard({required this.assetNode});

  @override
  Widget build(BuildContext context) {
    final an = assetNode;
    final asset = an.asset;
    final pos = an.position;
    final typeIndex = _assetTypeIndex(asset.type);
    final nativeSymbol = _nativeSymbolOf(asset.currency);

    return PlainCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.palette[typeIndex].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    asset.symbol.toUpperCase().substring(0, asset.symbol.length > 3 ? 3 : asset.symbol.length),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.palette[typeIndex],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      // Single asset — its own currency, not the display one.
                      'qty ${Formatters.money(pos.quantity)} @ $nativeSymbol${Formatters.money(pos.avgCost)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted2,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$nativeSymbol${Formatters.money(pos.totalCost)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sparkline
          SizedBox(
            height: 34,
            child: AreaChart(
              const [], // No history in state — skip chart if empty
              line: AppColors.gain,
            ),
          ),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'ซื้อเพิ่ม',
                  bgColor: const Color(0xFFDDF3F3),
                  fgColor: const Color(0xFF177E81),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'ขาย',
                  bgColor: const Color(0xFFFCDFD4),
                  fgColor: const Color(0xFFA8341C),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Asset row inside DividedCard.
class _AssetRow extends StatelessWidget {
  final AssetNode an;

  const _AssetRow({required this.an});

  @override
  Widget build(BuildContext context) {
    final asset = an.asset;
    final pos = an.position;
    final typeIndex = _assetTypeIndex(asset.type);
    final nativeSymbol = _nativeSymbolOf(asset.currency);

    return ListRowTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.palette[typeIndex].withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            asset.symbol.toUpperCase().substring(0, asset.symbol.length > 3 ? 3 : asset.symbol.length),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.palette[typeIndex],
            ),
          ),
        ),
      ),
      title: asset.name,
      subtitle: 'qty ${Formatters.money(pos.quantity)}',
      trailing: Text(
        '$nativeSymbol${Formatters.money(pos.totalCost)}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
