import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../domain/formatters.dart';
import '../../repos/liability_repo.dart';
import '../../state/liabilities_notifier.dart';
import '../theme/colors.dart';
import 'confirm_delete.dart';

/// Adjust sheet — pay / add for an existing liability.
///
/// Pops `'edit'` when the user asks to change the liability's own fields: the
/// edit form is another sheet, and opening it on top of this one would leave a
/// stale balance banner underneath. The screen re-presents instead — same
/// pop-with-a-value convention as the asset picker in `transaction_sheet.dart`.
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

  /// `liability_transactions.liabilityId` cascades, so the pay/add history goes
  /// with the liability — the confirm counts it.
  Future<void> _delete() async {
    final l = widget.liability;
    final txs = await ref.read(liabilityRepoProvider).txsFor(l.id);
    if (!mounted) return;
    final ok = await confirmDelete(
      context,
      title: 'ลบหนี้สิน',
      message: 'ลบ ${l.name} และประวัติจ่าย/เพิ่ม ${txs.length} รายการ '
          '— ย้อนกลับไม่ได้',
    );
    if (!ok || !mounted) return;
    await ref.read(liabilitiesProvider.notifier).deleteLiability(l.id);
    if (mounted) Navigator.of(context).pop();
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
                'ยอดคงเหลือ',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B5D49),
                ),
              ),
              Text(
                // Native currency (the amount input below carries [suffix]).
                Formatters.money(widget.liability.amount),
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
              _segmentedPill('เพิ่ม (add)', _type == 'add',
                  () => setState(() => _type = 'add')),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // จำนวนเงิน
        const Text(
          'จำนวนเงิน',
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
            // Capped at today, matching transaction_sheet.dart: a pay/add is a
            // record of something that happened, so a future date is a
            // data-entry error. One `now` feeds both bounds, so initialDate
            // cannot drift past lastDate between two separate calls.
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2000),
              lastDate: now,
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
              'บันทึก',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop('edit'),
            child: const Text(
              'แก้ไขข้อมูลหนี้สิน',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        DeleteButton(label: 'ลบหนี้สิน', onPressed: _delete),
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

/// Create sheet — add a new liability, or edit one when [existing] is supplied.
/// The fields are the same either way, so the แก้ไข action in
/// [LiabilityAdjustSheet] reuses this rather than duplicating it.
class LiabilityCreateSheet extends ConsumerStatefulWidget {
  final Liability? existing;

  const LiabilityCreateSheet({super.key, this.existing});

  @override
  ConsumerState<LiabilityCreateSheet> createState() =>
      _LiabilityCreateSheetState();
}

class _LiabilityCreateSheetState
    extends ConsumerState<LiabilityCreateSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _currency = 'THB';

  bool get _isEdit => widget.existing != null;

  /// Prefill text for a stored amount — same rule as `TransactionSheet`: whole
  /// values lose the trailing `.0`, fractional ones are left untouched so no
  /// precision is rounded away.
  static String _editable(double v) =>
      v == v.roundToDouble() && v.abs() < 1e15
          ? v.toInt().toString()
          : v.toString();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _amountCtrl.text = _editable(e.amount);
      _currency = e.currency;
    }
  }

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
    final notifier = ref.read(liabilitiesProvider.notifier);
    final e = widget.existing;
    if (e != null) {
      // Currency stays put — see the lock note in build().
      notifier.saveLiability(e.copyWith(name: name, amount: amt));
    } else {
      notifier.addLiability(name: name, amount: amt, currency: _currency);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ชื่อ
        const Text(
          'ชื่อ',
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

        // จำนวนเงิน
        const Text(
          'จำนวนเงิน',
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

        // สกุลเงิน — segmented. Locked on edit: `liability_transactions` rows
        // carry no currency of their own, so switching it here would silently
        // re-denominate the whole pay/add history.
        Text(
          _isEdit ? 'สกุลเงิน (ล็อกแล้ว)' : 'สกุลเงิน',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        IgnorePointer(
          key: const ValueKey('liability-currency-lock'),
          ignoring: _isEdit,
          child: Opacity(
            opacity: _isEdit ? 0.5 : 1,
            child: Container(
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
              'บันทึก',
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
