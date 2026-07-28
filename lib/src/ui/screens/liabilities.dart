import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/currency_converter.dart';
import '../../domain/formatters.dart';
import '../../state/display_money.dart';
import '../../state/liabilities_notifier.dart';
import '../theme/colors.dart';
import '../widgets/cards.dart';
import '../widgets/liability_sheet.dart';
import '../widgets/sheet_shell.dart';

/// Liabilities sub-screen — gradient hero with total + liability cards.
///
/// Watches [liabilitiesProvider]; opens [LiabilityAdjustSheet] /
/// [LiabilityCreateSheet] via [showPortoSheet].
class LiabilitiesScreen extends ConsumerWidget {
  const LiabilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(liabilitiesProvider);
    final money =
        ref.watch(displayMoneyProvider).value ?? DisplayMoney.thb;

    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (state) {
        final liabilities = state.liabilities;
        // Liabilities are stored in their own native currency, so normalise to
        // THB before summing — matching NetWorthCalculator.summary(). Adding the
        // raw amounts would silently treat a USD balance as THB.
        final totalThb = liabilities.fold<double>(
            0,
            (prev, l) =>
                prev + CurrencyConverter.toThb(l.amount, l.currency, money.fx));

        return Scaffold(
          body: Container(
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
                // ── Hero ───────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(22, 68, 22, 22),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Top bar: back + title + add pill
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.bg,
                                size: 26),
                            onPressed: () =>
                                Navigator.of(context).pop(),
                          ),
                          const Text(
                            'หนี้สิน',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bg,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              showPortoSheet(
                                context,
                                title: 'เพิ่มหนี้สิน',
                                builder: (_) =>
                                    const LiabilityCreateSheet(),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xEBFFFFFF),
                                borderRadius:
                                    BorderRadius.circular(999),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 5),
                              child: const Text(
                                '＋ เพิ่มหนี้สิน',
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
                      // Total label
                      const Text(
                        'หนี้สินรวม',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xBFFAF5EC),
                        ),
                      ),
                      // Total value
                      Text(
                        money.money(totalThb),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Cream sheet ────────────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.bg,
                      borderRadius:
                          BorderRadius.vertical(
                              top: Radius.circular(30)),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Liability cards
                          if (liabilities.isEmpty) ...[
                            const SizedBox(height: 40),
                            Center(
                              child: Text(
                                'ยังไม่มีหนี้สิน — เพิ่มให้ Net Worth แม่นยำขึ้น',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else ...[
                            for (final l in liabilities)
                              PlainCard(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 4),
                                child: ListRowTile(
                                  leading: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6E4EA),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '−',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.w700,
                                          color:
                                              const Color(0xFFA84E71),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: l.name,
                                  subtitle: l.currency,
                                  trailing: Text(
                                    // Native currency — the row's subtitle
                                    // already shows which one.
                                    Formatters.money(l.amount),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: Color(0xFFA8341C),
                                    ),
                                  ),
                                  onTap: () async {
                                    // The adjust sheet pops 'edit' rather
                                    // than stacking the edit form on top of
                                    // its own stale balance banner.
                                    final action =
                                        await showPortoSheet<String>(
                                      context,
                                      title: l.name,
                                      builder: (_) =>
                                          LiabilityAdjustSheet(
                                              liability: l),
                                    );
                                    if (action != 'edit' ||
                                        !context.mounted) {
                                      return;
                                    }
                                    showPortoSheet(
                                      context,
                                      title: 'แก้ไขหนี้สิน',
                                      builder: (_) =>
                                          LiabilityCreateSheet(
                                              existing: l),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 11),
                            // Add-new card
                            GestureDetector(
                              onTap: () {
                                showPortoSheet(
                                  context,
                                  title: 'เพิ่มหนี้สินใหม่',
                                  builder: (_) =>
                                      const LiabilityCreateSheet(),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD9CBB4),
                                    width: 1.5,
                                    strokeAlign:
                                        BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 13),
                                child: Center(
                                  child: Text(
                                    '＋ เพิ่มหนี้สินใหม่',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: AppColors.muted2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
