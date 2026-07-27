import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/settings_notifier.dart';
import '../../ui/theme/colors.dart';
import '../widgets/cards.dart';

// -----------------------------------------------------------------------------
// SettingsScreen  —  Settings tab (ConsumerWidget)
// -----------------------------------------------------------------------------

class SettingsScreen extends ConsumerWidget {
  final VoidCallback? onExport;
  final VoidCallback? onImport;

  const SettingsScreen({super.key, this.onExport, this.onImport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (state) {
        final notifier = ref.read(settingsProvider.notifier);
        return _SettingsBody(
          state: state,
          notifier: notifier,
          context: context,
          onExport: onExport,
          onImport: onImport,
        );
      },
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final SettingsState state;
  final SettingsNotifier notifier;
  final BuildContext context;
  final VoidCallback? onExport;
  final VoidCallback? onImport;

  const _SettingsBody({
    required this.state,
    required this.notifier,
    required this.context,
    this.onExport,
    this.onImport,
  });

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(22, 68, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ตั้งค่า',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFAF5EC),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // On-device banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x24FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: Color(0xFFFAF5EC),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ไม่มีบัญชี ไม่ต้องล็อกอิน',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFAF5EC),
                                ),
                              ),
                              Text(
                                'ข้อมูลทั้งหมดเก็บในเครื่องของคุณเท่านั้น',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xC9FAF5EC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      // --- Section 1: ทั่วไป ---
                      _sectionHeader('ทั่วไป'),
                      const SizedBox(height: 11),
                      DividedCard(
                        rows: [
                          _currencyRow(state.displayCurrency, (v) {
                            final next = v == 'THB' ? 'USD' : 'THB';
                            notifier.setCurrency(next);
                          }),
                          _staticRow('ธีม', 'สว่าง'),
                          _languageRow(state.language, (v) {
                            final next = v == 'th' ? 'en' : 'th';
                            notifier.setLanguage(next);
                          }),
                        ],
                      ),
                      const SizedBox(height: 11),

                      // --- Section 2: ความปลอดภัย ---
                      _sectionHeader('ความปลอดภัย'),
                      const SizedBox(height: 11),
                      DividedCard(
                        rows: [
                          _toggleRow('ปลดล็อกด้วย Face ID', true),
                          _toggleRow('ซ่อนยอดเงินเมื่อเปิดแอป', false),
                        ],
                      ),
                      const SizedBox(height: 11),

                      // --- Section 3: ข้อมูลของคุณ ---
                      _sectionHeader('ข้อมูลของคุณ'),
                      const SizedBox(height: 11),
                      DividedCard(
                        rows: [
                          _actionRow(
                            'สำรองข้อมูลลงไฟล์',
                            'ส่งออกทั้งหมดเป็นไฟล์เดียว',
                            () => onExport?.call(),
                          ),
                          _actionRow(
                            'นำเข้าข้อมูล',
                            'จากไฟล์สำรอง หรือ CSV',
                            () => onImport?.call(),
                          ),
                          _destructiveRow(
                            'ลบข้อมูลทั้งหมด',
                            () => _showDeleteConfirm(context, () {
                              // destructive action placeholder
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),

                      // Footer
                      const Text(
                        'Porto 1.0 · ทำงานออฟไลน์ได้ 100%',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted2,
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

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.muted2,
      ),
    );
  }

  Widget _currencyRow(String currency, ValueChanged<String> onTap) {
    final label = currency == 'THB' ? '฿ THB' : '\$ USD';
    return ListRowTile(
      leading: const SizedBox.shrink(),
      title: 'สกุลเงินหลัก',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '\u{203A}',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
      onTap: () => onTap(currency),
    );
  }

  Widget _staticRow(String title, String trailing) {
    return ListRowTile(
      leading: const SizedBox.shrink(),
      title: title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '\u{203A}',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _languageRow(String language, ValueChanged<String> onTap) {
    final label = language == 'th' ? 'ไทย' : 'EN';
    return ListRowTile(
      leading: const SizedBox.shrink(),
      title: 'ภาษา',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '\u{203A}',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
      onTap: () => onTap(language),
    );
  }

  Widget _toggleRow(String title, bool initialValue) {
    return ListRowTile(
      leading: const SizedBox.shrink(),
      title: title,
      trailing: Switch(
        value: initialValue,
        activeThumbColor: AppColors.gain,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        onChanged: null, // local UI only, inert in v1
      ),
    );
  }

  Widget _actionRow(String title, String subtitle, VoidCallback onTap) {
    return ListRowTile(
      leading: const SizedBox.shrink(),
      title: title,
      subtitle: subtitle,
      trailing: const Text(
        '\u{203A}',
        style: TextStyle(fontSize: 14, color: AppColors.muted),
      ),
      onTap: onTap,
    );
  }

  Widget _destructiveRow(String title, VoidCallback onTap) {
    return ListRowTile(
      leading: const SizedBox.shrink(),
      title: title,
      trailing: const Text(
        '\u{203A}',
        style: TextStyle(fontSize: 14, color: AppColors.loss),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirm(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบข้อมูลทั้งหมด'),
        content: const Text('คุณมั่นใจหรือไม่? การลบนี้ทำให้ข้อมูลหายทั้งหมด'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.loss),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
