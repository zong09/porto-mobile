import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:porto_mobile/src/state/portfolios_notifier.dart';
import 'package:porto_mobile/src/ui/theme/colors.dart';
import 'package:porto_mobile/src/ui/widgets/area_chart.dart';
import 'package:porto_mobile/src/ui/widgets/cards.dart';
import 'package:porto_mobile/src/ui/widgets/donut_chart.dart';

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

    // Total cost basis across all portfolios
    final totalCost = nodes.fold<double>(
      0,
      (sum, n) => sum + n.assets.fold<double>(0, (a, an) => a + an.position.totalCost),
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
                        'พอรต์ของฉัน',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFAF5EC),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _showCreatePortfolioSheet(context, ref),
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
                    totalCost.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Allocation bar
                  _AllocationBar(nodes: nodes),
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
                      ...nodes.map((node) => _PortfolioCard(node: node)),
                      // Dashed create-new card
                      _CreateNewCard(),
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

  void _showCreatePortfolioSheet(BuildContext context, WidgetRef ref) {
    // Placeholder — would open a create-portfolio sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create portfolio sheet')),
    );
  }
}

// -----------------------------------------------------------------------------
// PortfolioDetailScreen  —  detail sub-screen (takes a PortfolioNode)
// -----------------------------------------------------------------------------

class PortfolioDetailScreen extends StatelessWidget {
  final PortfolioNode node;

  const PortfolioDetailScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final portfolio = node.portfolio;
    final assets = node.assets;

    // Portfolio value = sum of asset totalCosts
    final value = assets.fold<double>(0, (sum, an) => sum + an.position.totalCost);

    // Realized P&L
    final realizedPnl =
        assets.fold<double>(0, (sum, an) => sum + an.position.realizedPnl);

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
                    value.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Allocation bar over assets
                  _AssetAllocationBar(assets: assets),
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
                                'Realized P/L ปีนี้ ${realizedPnl >= 0 ? '+' : ''}\$${realizedPnl.toStringAsFixed(2)}',
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

  const _AllocationBar({required this.nodes});

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    final total = nodes.fold<double>(
      0,
      (sum, n) => sum + n.assets.fold<double>(0, (a, an) => a + an.position.totalCost),
    );

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
              final nodeCost =
                  node.assets.fold<double>(0, (a, an) => a + an.position.totalCost);
              final pct = total > 0 ? nodeCost / total : 0;
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
            final nodeCost =
                node.assets.fold<double>(0, (a, an) => a + an.position.totalCost);
            final pct = total > 0 ? nodeCost / total : 0;
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

  const _AssetAllocationBar({required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const SizedBox.shrink();

    final total = assets.fold<double>(
      0,
      (sum, an) => sum + an.position.totalCost,
    );

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
              final pct = total > 0 ? an.position.totalCost / total : 0;
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
            final pct = total > 0 ? an.position.totalCost / total : 0;
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

  const _PortfolioCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final portfolio = node.portfolio;
    final assets = node.assets;
    final nodeCost =
        assets.fold<double>(0, (sum, an) => sum + an.position.totalCost);

    // Percentage chip
    // (computed relative to total — caller can pass total, or we use 0)
    // We'll compute it inline; the exact total isn't available here so we
    // show 0% — the real app would compute from the parent's total.

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
                nodeCost.toStringAsFixed(2),
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

/// Dashed "create new" card at the end of the list.
class _CreateNewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Center(
        child: Text(
          '+ สร้างพอร์ตใหม่',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFFA89A86),
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
                      'qty ${pos.quantity.toStringAsFixed(2)} @ ${pos.avgCost.toStringAsFixed(2)}',
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
                    pos.totalCost.toStringAsFixed(2),
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
                  label: 'ซื้่อเพิ่ม',
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
      subtitle: 'qty ${pos.quantity.toStringAsFixed(2)}',
      trailing: Text(
        pos.totalCost.toStringAsFixed(2),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
