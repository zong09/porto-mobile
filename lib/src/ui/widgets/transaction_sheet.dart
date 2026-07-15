import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/formatters.dart';
import '../../state/transactions_notifier.dart';
import '../../db/database.dart';
import '../theme/colors.dart';
import 'sheet_shell.dart';

/// Transaction form sheet — buy / sell / deposit / withdraw.
///
/// Shows asset selector, qty + price inputs, live มูลค่ารวม banner,
/// date + fee fields, and a save button.
class TransactionSheet extends ConsumerStatefulWidget {
  /// 'buy' | 'sell' | 'deposit' | 'withdraw'
  final String side;

  /// Selectable assets (caller supplies).
  final List<Asset> assets;

  /// Pre-selected asset for edit mode.
  final Asset? initialAsset;

  /// Existing transaction for edit mode.
  final Transaction? existing;

  const TransactionSheet({
    super.key,
    required this.side,
    required this.assets,
    this.initialAsset,
    this.existing,
  });

  @override
  ConsumerState<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends ConsumerState<TransactionSheet> {
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Asset? _selected;

  double get _qty => double.tryParse(_qtyCtrl.text) ?? 0;
  double get _price => double.tryParse(_priceCtrl.text) ?? 0;
  double get _fee => double.tryParse(_feeCtrl.text) ?? 0;
  double get _total => _qty * _price + _fee;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _qtyCtrl.text = widget.existing!.quantity.toString();
      _priceCtrl.text = widget.existing!.price.toString();
      _feeCtrl.text = widget.existing!.fee.toString();
      _date = widget.existing!.date;
      _selected = widget.assets.firstWhere(
        (a) => a.id == widget.existing!.assetId,
        orElse: () => widget.initialAsset ?? widget.assets.first,
      );
    } else {
      _selected = widget.initialAsset ?? widget.assets.first;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _feeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── title mapping ────────────────────────────────────────────────────

  static String _title(String side) {
    switch (side) {
      case 'buy':
        return 'ซื้้่อสินทรพย์';
      case 'sell':
        return 'ขายสินทรพย์';
      case 'deposit':
        return 'ฝากเงิน';
      case 'withdraw':
        return 'ถอนเงิน';
      default:
        return side;
    }
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: _title(widget.side),
      onClose: () => Navigator.of(context).pop(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset selector
            _assetSelector(context),
            const SizedBox(height: 14),

            // Qty + Price grid
            _inputGrid(context),
            const SizedBox(height: 14),

            // มูลค่ารวม banner
            _totalBanner(context),
            const SizedBox(height: 14),

            // Date + Fee grid
            _dateFeeGrid(context),
            const SizedBox(height: 14),

            // Note (optional)
            _noteField(context),
            const SizedBox(height: 14),

            // Save button
            _saveButton(context),
          ],
        ),
      ),
    );
  }

  // ── asset selector ───────────────────────────────────────────────────

  Widget _assetSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          // Tinted tile
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _selected != null
                  ? _tintBg(_selected!.type)
                  : AppColors.muted3,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _selected != null ? _selected!.symbol[0] : '?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _tintFg(_selected?.type),
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
                  _selected != null
                      ? '${_selected!.name} ${_selected!.symbol}'
                      : 'เลื้้่อสินทรพย์',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _selected != null
                      ? 'สกุลเงิน: ${_selected!.currency}'
                      : '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'เปลี่่ยน \u{203A}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brand,
            ),
          ),
        ],
      ),
    );
  }

  // ── qty + price grid ─────────────────────────────────────────────────

  Widget _inputGrid(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: _numberInput(
            controller: _qtyCtrl,
            label: 'จำนวน',
            suffix: _selected != null ? _selected!.symbol : '',
            focused: true,
          ),
        ),
        Expanded(
          child: _numberInput(
            controller: _priceCtrl,
            label: 'ราคาต่อนวหนวย',
            suffix: '฿',
          ),
        ),
      ],
    );
  }

  // ── total banner ─────────────────────────────────────────────────────

  Widget _totalBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9DB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'มูลค่ารวม',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B5D49),
            ),
          ),
          const Spacer(),
          Text(
            Formatters.money(_total),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC24A1E),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ── date + fee grid ──────────────────────────────────────────────────

  Widget _dateFeeGrid(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: _dateField(context),
        ),
        Expanded(
          child: _numberInput(
            controller: _feeCtrl,
            label: 'ค่าธรรมเนียม (ถ้ามมี)',
            suffix: '฿',
          ),
        ),
      ],
    );
  }

  Widget _dateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'วนที่',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Text(
            _date,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── note field ───────────────────────────────────────────────────────

  Widget _noteField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'โน้ต (ไมบ้ังคับ)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'เชน DCA ประจำเดืิอน...',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ── save button ──────────────────────────────────────────────────────

  Widget _saveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: _save,
        child: const Text(
          'บันทึกรายการ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── save logic ───────────────────────────────────────────────────────

  void _save() {
    if (_selected == null) return;
    if (_qty <= 0) return;

    final notifier = ref.read(transactionsProvider.notifier);

    if (widget.existing != null) {
      // Edit mode — use saveTransaction
      final updated = Transaction(
        id: widget.existing!.id,
        assetId: _selected!.id,
        side: widget.side,
        quantity: _qty,
        price: _price,
        fee: _fee,
        date: _date,
        createdAt: widget.existing!.createdAt,
      );
      notifier.saveTransaction(updated);
    } else {
      notifier.addTransaction(
        assetId: _selected!.id,
        side: widget.side,
        quantity: _qty,
        price: _price,
        fee: _fee,
        date: _date,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  // ── helpers ──────────────────────────────────────────────────────────

  Widget _numberInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    bool focused = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: focused
                ? Border.all(color: AppColors.brand, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: suffix,
              suffixStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.muted2,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Color _tintBg(String type) {
    switch (type) {
      case 'crypto':
        return const Color(0xFFDDF3F3);
      case 'th':
      case 'us':
      case 'deposit':
        return const Color(0xFFFBEBD2);
      case 'fund':
        return const Color(0xFFF6E4EA);
      default:
        return AppColors.muted3;
    }
  }

  Color _tintFg(String? type) {
    switch (type) {
      case 'crypto':
        return const Color(0xFFC24A1E);
      case 'th':
        return const Color(0xFF177E81);
      case 'us':
      case 'deposit':
        return const Color(0xFFB57F22);
      case 'fund':
        return const Color(0xFFA84E71);
      default:
        return Colors.white;
    }
  }
}
