import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/sheet_shell.dart';
import 'screens/overview.dart';
import 'theme/colors.dart';

/// The main app shell — IndexedStack of 4 tabs + floating bottom nav.
///
/// Per T3.05 brief: only OverviewScreen is real; others are placeholders.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() => _currentIndex = widget.initialIndex);
    }
  }

  // ── Add sheet ────────────────────────────────────────────────────────

  static void _showAddSheet(BuildContext context) {
    showPortoSheet(context, title: 'เพิ่่มรายการ', builder: (_) {
      return const _AddSheetContent();
    });
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: const [
              OverviewScreen(),
              Center(child: Text('Portfolios')),
              Center(child: Text('Transactions')),
              Center(child: Text('Settings')),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: AppBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              onFabTap: () => _showAddSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add sheet content (2×2 action grid) ──────────────────────────────────

class _AddSheetContent extends StatelessWidget {
  const _AddSheetContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2×2 grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _AddGridItem(
              icon: '↓',
              iconBg: const Color(0xFFDDF3F3),
              iconFg: AppColors.gain,
              title: 'ซื้้อสินทรพย์',
              subtitle: 'หุ้น คริปโต กองทุน ทอง',
            ),
            _AddGridItem(
              icon: '↑',
              iconBg: const Color(0xFFFCDFD4),
              iconFg: AppColors.loss,
              title: 'ขายสินทรพย์',
              subtitle: 'บันทึก Realized P/L อัตโนมัต',
            ),
            _AddGridItem(
              icon: '＋',
              iconBg: const Color(0xFFFBEBD2),
              iconFg: AppColors.gold,
              title: 'ฝาก / ถอนเงิน',
              subtitle: 'เงินฝาก บัญชอออมทรพย์',
            ),
            _AddGridItem(
              icon: '−',
              iconBg: const Color(0xFFF6E4EA),
              iconFg: const Color(0xFFA84E71),
              title: 'เพิ่่มหน้สิน',
              subtitle: 'สินเชื่่อ บัตรเครดต ผ่อนชำระ',
            ),
          ],
        ),
        // Local-data note
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9DB),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            'ข้อมลอย่ในเครื่องของคณ — '
            'ในเครื่องของคณ'
            ' ไม่มีบัญชี ไม่ต้องล็อกอิน',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B5D49),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddGridItem extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;

  const _AddGridItem({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 68) / 2, // 2 cols minus gaps/padding
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: iconFg,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
