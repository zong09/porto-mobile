import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// The chrome of a Porto bottom sheet: grab handle, title row with a close button, then child.
class SheetShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;

  const SheetShell({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 46, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grab handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2D6C2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Title row
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E7D6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '\u{2715}',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Content
          child,
        ],
      ),
    );
  }
}

/// Presents [builder] as a modal bottom sheet with the Porto scrim + rounded top.
Future<T?> showPortoSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x73291C12),
    builder: (ctx) => SheetShell(
      title: title,
      onClose: () => Navigator.of(ctx).pop(),
      child: builder(ctx),
    ),
  );
}
