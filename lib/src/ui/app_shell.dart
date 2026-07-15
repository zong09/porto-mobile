import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database.dart';
import '../state/portfolios_notifier.dart';
import '../state/settings_notifier.dart';
import 'screens/overview.dart';
import 'screens/portfolios.dart';
import 'screens/transactions.dart';
import 'screens/settings.dart';
import 'screens/liabilities.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/sheet_shell.dart';
import 'widgets/transaction_sheet.dart';
import 'widgets/liability_sheet.dart';
import 'theme/colors.dart';

/// The main app shell — IndexedStack of 4 tabs + floating bottom nav.
///
/// Tabs: 0 Overview · 1 Portfolios · 2 Transactions · 3 Settings.
/// The center FAB opens the "add" grid; Liabilities is reached from the
/// Overview liabilities card (pushed as a route).
class AppShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
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

  // ── navigation ─────────────────────────────────────────────────────────

  void _openLiabilities() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LiabilitiesScreen()),
    );
  }

  /// Show a self-contained sheet widget (it already wraps [SheetShell]).
  Future<void> _showSheet(Widget sheet) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73291C12),
      builder: (_) => sheet,
    );
  }

  List<Asset> _allAssets() {
    final st = ref.read(portfoliosProvider).value;
    if (st == null) return const [];
    return st.nodes.expand((n) => n.assets.map((a) => a.asset)).toList();
  }

  void _startTransaction(String side) {
    final assets = _allAssets();
    if (assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มสินทรัพย์ก่อน')),
      );
      setState(() => _currentIndex = 1); // jump to Portfolios
      return;
    }
    _showSheet(TransactionSheet(side: side, assets: assets));
  }

  void _showAddSheet() {
    showPortoSheet(context, title: 'เพิ่มรายการ', builder: (_) {
      return _AddSheetContent(onSelect: (action) {
        Navigator.of(context).pop(); // close the add grid first
        switch (action) {
          case 'buy':
          case 'sell':
          case 'deposit':
            _startTransaction(action);
          case 'liability':
            _showSheet(const LiabilityCreateSheet());
        }
      });
    });
  }

  // ── backup export / import ───────────────────────────────────────────────

  Future<void> _exportBackup() async {
    try {
      final data = await ref.read(settingsProvider.notifier).exportToJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/porto-backup.json');
      await file
          .writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Porto backup'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export ล้มเหลว: $e')),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = result?.files.single.path;
      if (path == null) return;
      final content = await File(path).readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      await ref.read(settingsProvider.notifier).importFromJson(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('นำเข้าข้อมูลสำเร็จ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import ล้มเหลว: $e')),
        );
      }
    }
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              OverviewScreen(onOpenLiabilities: _openLiabilities),
              const PortfoliosScreen(),
              const TransactionsScreen(),
              SettingsScreen(onExport: _exportBackup, onImport: _importBackup),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: AppBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              onFabTap: _showAddSheet,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add sheet content (2×2 action grid) ──────────────────────────────────

class _AddSheetContent extends StatelessWidget {
  /// Called with one of: 'buy', 'sell', 'deposit', 'liability'.
  final void Function(String action) onSelect;

  const _AddSheetContent({required this.onSelect});

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
              onTap: () => onSelect('buy'),
            ),
            _AddGridItem(
              icon: '↑',
              iconBg: const Color(0xFFFCDFD4),
              iconFg: AppColors.loss,
              title: 'ขายสินทรพย์',
              subtitle: 'บันทึก Realized P/L อัตโนมัต',
              onTap: () => onSelect('sell'),
            ),
            _AddGridItem(
              icon: '＋',
              iconBg: const Color(0xFFFBEBD2),
              iconFg: AppColors.gold,
              title: 'ฝาก / ถอนเงิน',
              subtitle: 'เงินฝาก บัญชอออมทรพย์',
              onTap: () => onSelect('deposit'),
            ),
            _AddGridItem(
              icon: '−',
              iconBg: const Color(0xFFF6E4EA),
              iconFg: const Color(0xFFA84E71),
              title: 'เพิ่่มหน้สิน',
              subtitle: 'สินเชื่่อ บัตรเครดต ผ่อนชำระ',
              onTap: () => onSelect('liability'),
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
  final VoidCallback onTap;

  const _AddGridItem({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
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
      ),
    );
  }
}
