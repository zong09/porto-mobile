import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Confirm dialog for a destructive action.
///
/// [message] MUST name what is destroyed, including anything the schema takes
/// with it: `PRAGMA foreign_keys = ON` plus `onDelete: KeyAction.cascade` on
/// `transactions.assetId`, `assets.portfolioId` and
/// `liability_transactions.liabilityId` means deleting a parent row silently
/// deletes its children. A bare "คุณมั่นใจหรือไม่?" hides that.
///
/// Returns true only when the user confirms.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('ยกเลิก'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('ลบ', style: TextStyle(color: AppColors.loss)),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Full-width destructive footer button, sitting below a sheet's บันทึก.
class DeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DeleteButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.loss,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
