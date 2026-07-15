import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../state/portfolios_notifier.dart';
import '../theme/colors.dart';

/// Add / edit an asset. In edit mode (`existing != null`) the currency is
/// LOCKED — transactions are stored in the asset's native currency, so it must
/// not change after creation (CONTRACTS §7).
class AssetSheet extends ConsumerStatefulWidget {
  final String portfolioId;
  final Asset? existing;

  const AssetSheet({super.key, required this.portfolioId, this.existing});

  @override
  ConsumerState<AssetSheet> createState() => _AssetSheetState();
}

class _AssetSheetState extends ConsumerState<AssetSheet> {
  static const _types = ['crypto', 'th', 'us', 'fund', 'deposit'];
  static const _typeLabels = {
    'crypto': 'คริปโต',
    'th': 'หุ้นไทย',
    'us': 'หุ้นนอก',
    'fund': 'กองทุน',
    'deposit': 'เงินฝาก',
  };
  static final _symbolRe = RegExp(r'^[A-Za-z0-9.\-^=]{1,15}$');

  late String _type;
  late String _currency;
  final _symbolCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? 'crypto';
    _currency = e?.currency ?? _defaultCurrencyFor(_type);
    if (e != null) {
      _symbolCtrl.text = e.symbol;
      _nameCtrl.text = e.name;
    }
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  static String _defaultCurrencyFor(String type) =>
      (type == 'crypto' || type == 'us') ? 'USD' : 'THB';

  void _save() {
    final symbol = _symbolCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'กรุณากรอกชื่อ');
      return;
    }
    if (!_symbolRe.hasMatch(symbol)) {
      setState(() => _error = 'สัญลักษณ์ไม่ถูกต้อง');
      return;
    }

    final notifier = ref.read(portfoliosProvider.notifier);
    final e = widget.existing;
    if (e != null) {
      // Currency is locked — keep e.currency.
      notifier.saveAsset(e.copyWith(type: _type, symbol: symbol, name: name));
    } else {
      notifier.addAsset(
        portfolioId: widget.portfolioId,
        type: _type,
        symbol: symbol,
        name: name,
        currency: _currency,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type chips
        _label('ประเภท'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _types
              .map((t) => _typeChip(t, _type == t, () {
                    setState(() {
                      _type = t;
                      if (!_isEdit) _currency = _defaultCurrencyFor(t);
                    });
                  }))
              .toList(),
        ),
        const SizedBox(height: 14),

        // Symbol
        _label('สัญลักษณ์'),
        const SizedBox(height: 6),
        _input(_symbolCtrl, 'เช่น BTC, PTT'),
        const SizedBox(height: 14),

        // Name
        _label('ชื่อ'),
        const SizedBox(height: 6),
        _input(_nameCtrl, 'เช่น Bitcoin'),
        const SizedBox(height: 14),

        // Currency (locked in edit mode)
        _label(_isEdit ? 'สกุลเงิน (ล็อกแล้ว)' : 'สกุลเงิน'),
        const SizedBox(height: 6),
        IgnorePointer(
          key: const ValueKey('currency-lock'),
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

        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: const TextStyle(fontSize: 12, color: AppColors.loss),
          ),
        ],

        const SizedBox(height: 20),

        // Save
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

  Widget _input(TextEditingController c, String hint) => TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  Widget _typeChip(String type, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: active ? AppColors.brand : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        child: Text(
          _typeLabels[type] ?? type,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.muted,
          ),
        ),
      ),
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
