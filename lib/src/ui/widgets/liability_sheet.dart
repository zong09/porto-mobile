import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../domain/formatters.dart';
import '../../state/liabilities_notifier.dart';
import '../theme/colors.dart';

/// Adjust sheet — pay / add for an existing liability.
class LiabilityAdjustSheet extends ConsumerStatefulWidget {
  final Liability liability;

  const LiabilityAdjustSheet({super.key, required this.liability});

  @override
  ConsumerState<LiabilityAdjustSheet> createState() =>
      _LiabilityAdjustSheetState();
}

class _LiabilityAdjustSheetState
    extends ConsumerState<LiabilityAdjustSheet> {
  String _type = 'pay'; // 'pay' | 'add'
  final _amountCtrl = TextEditingController();
  String _date = DateTime.now().toIso8601String().substring(0, 10);

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amt = double.tryParse(_amountCtrl.text);
    if (amt == null || amt <= 0) return;
    ref
        .read(liabilitiesProvider.notifier)
        .adjust(
          liabilityId: widget.liability.id,
          type: _type,
          amount: amt,
          date: _date,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.liability.currency;
    final suffix = currency == 'THB' ? '฿' : r'$';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current balance banner
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9DB),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ยอดคงเหลืือ',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B5D49),
                ),
              ),
              Text(
                Formatters.money(widget.liability.amount, currency: currency),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC24A1E),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ประเภท — segmented toggle
        const Text(
          'ประเภท',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5EDDE),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _segmentedPill('จ่าย (pay)', _type == 'pay',
                  () => setState(() => _type = 'pay')),
              const SizedBox(width: 3),
              _segmentedPill('เพิ่่ม (add)', _type == 'add',
                  () => setState(() => _type = 'add')),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // จำนวนเงิิน
        const Text(
          'จำนวนเงิิน',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00',
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // วันที่
        const Text(
          'วันที่',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: _date),
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (d != null) {
              setState(() {
                _date = d.toIso8601String().substring(0, 10);
              });
            }
          },
        ),

        const SizedBox(height: 20),

        // Save footer
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
              'บันทึ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _segmentedPill(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: active ? AppColors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.bg : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Create sheet — add a new liability.
class LiabilityCreateSheet extends ConsumerStatefulWidget {
  const LiabilityCreateSheet({super.key});

  @override
  ConsumerState<LiabilityCreateSheet> createState() =>
      _LiabilityCreateSheetState();
}

class _LiabilityCreateSheetState
    extends ConsumerState<LiabilityCreateSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _currency = 'THB';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final amt = double.tryParse(_amountCtrl.text);
    if (name.isEmpty || amt == null || amt <= 0) return;
    ref
        .read(liabilitiesProvider.notifier)
        .addLiability(
          name: name,
          amount: amt,
          currency: _currency,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ชื่่อ
        const Text(
          'ชื่่อ',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'ผ่อนรถ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // จำนวนเงิิน
        const Text(
          'จำนวนเงิิน',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00',
            suffixText: _currency == 'THB' ? '฿' : r'$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // สกุลเงิิน — segmented
        const Text(
          'สกุลเงิิน',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5EDDE),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _currencyPill('฿ THB', _currency == 'THB',
                  () => setState(() => _currency = 'THB')),
              _currencyPill(r'$ USD', _currency == 'USD',
                  () => setState(() => _currency = 'USD')),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Save footer
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
              'บันทึ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _currencyPill(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: active ? AppColors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.bg : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
