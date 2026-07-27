import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/portfolios_notifier.dart';
import '../theme/colors.dart';

/// Create a portfolio (design-portfolios.md §A.1 / §B "สร้างพอร์ตใหม่").
///
/// Builds the fields only — present it via `showPortoSheet`, which supplies the
/// [SheetShell] chrome (same convention as [AssetSheet] / [LiabilityCreateSheet]).
class PortfolioCreateSheet extends ConsumerStatefulWidget {
  const PortfolioCreateSheet({super.key});

  @override
  ConsumerState<PortfolioCreateSheet> createState() =>
      _PortfolioCreateSheetState();
}

class _PortfolioCreateSheetState extends ConsumerState<PortfolioCreateSheet> {
  final _nameCtrl = TextEditingController();
  int _color = 0;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    // PortfolioRepo.create throws ArgumentError on an empty name — catch it here
    // so the sheet shows a message instead of an unhandled async error.
    if (name.isEmpty) {
      setState(() => _error = 'กรุณากรอกชื่อพอร์ต');
      return;
    }
    ref
        .read(portfoliosProvider.notifier)
        .addPortfolio(name: name, color: _color);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ชื่อพอร์ต
        _label('ชื่อพอร์ต'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'เช่น Crypto หลัก',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // สี — indices 0..5 only; PortfolioRepo.create rejects anything else.
        _label('สี'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            AppColors.palette.length,
            (i) => _swatch(i),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: const TextStyle(fontSize: 12, color: AppColors.loss),
          ),
        ],

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'บันทึก',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      );

  Widget _swatch(int i) {
    final active = _color == i;
    return GestureDetector(
      onTap: () => setState(() => _color = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.palette[i],
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(color: AppColors.text, width: 2.5)
              : null,
        ),
      ),
    );
  }
}
