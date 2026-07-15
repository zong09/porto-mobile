import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Floating capsule bottom nav — 4 tabs + center FAB.
///
/// Per design-components §1:
///   * Capsule: rgba(61,51,40,0.92), blur(10), radius 999, padding 9×12.
///   * Active tab: [AppColors.secondary] stroke + 4 px dot below.
///   * Inactive: stroke rgba(250,245,236,0.55).
///   * FAB: 46×46 circle [AppColors.brand] with white "+".
class AppBottomNav extends StatelessWidget {
  /// 0 = Overview, 1 = Portfolios, 2 = Transactions, 3 = Settings.
  final int currentIndex;
  final ValueChanged<int> onTap;       // tab taps (skips the FAB)
  final VoidCallback onFabTap;         // center FAB button

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  // ── tab icons ────────────────────────────────────────────────────────

  static Widget _overviewIcon(bool active) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _CircleIconPainter(active: active),
    );
  }

  static Widget _portfoliosIcon(bool active) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _GridIconPainter(active: active),
    );
  }

  static Widget _transactionsIcon(bool active) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _LinesIconPainter(active: active),
    );
  }

  static Widget _settingsIcon(bool active) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _SlidersIconPainter(active: active),
    );
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.secondary;
    final inactiveColor = const Color(0xFAFAF5EC).withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x3D3D3328), // rgba(61,51,40,0.92)
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0x593D3328), // rgba(61,51,40,0.35)
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          _tab(_overviewIcon, 0, activeColor, inactiveColor),
          _tab(_portfoliosIcon, 1, activeColor, inactiveColor),
          _fab(activeColor),
          _tab(_transactionsIcon, 2, activeColor, inactiveColor),
          _tab(_settingsIcon, 3, activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _tab(
    Widget Function(bool) iconBuilder,
    int index,
    Color activeColor,
    Color inactiveColor,
  ) {
    final active = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconBuilder(active),
            if (active)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fab(Color color) {
    return GestureDetector(
      onTap: onFabTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x80EC6530), // rgba(236,101,48,0.5)
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── icon painters ────────────────────────────────────────────────────────

class _CircleIconPainter extends CustomPainter {
  final bool active;
  _CircleIconPainter({required this.active});

  @override
  void paint(Canvas c, Size s) {
    c.drawCircle(
      Offset(s.width / 2, s.height / 2),
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = active ? AppColors.secondary : const Color(0xFAFAF5EC).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_CircleIconPainter old) => active != old.active;
}

class _GridIconPainter extends CustomPainter {
  final bool active;
  _GridIconPainter({required this.active});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = active ? AppColors.secondary : const Color(0xFAFAF5EC).withValues(alpha: 0.55);
    // Two 7×7 rounded rects
    _rect(c, Offset(3, 3), p, 2);
    _rect(c, Offset(12, 3), p, 2);
    _rect(c, Offset(3, 12), p, 2);
    _rect(c, Offset(12, 12), p, 2);
  }

  void _rect(Canvas c, Offset o, Paint p, double r) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(o.dx, o.dy, 7, 7), Radius.circular(r)),
      p,
    );
  }

  @override
  bool shouldRepaint(_GridIconPainter old) => active != old.active;
}

class _LinesIconPainter extends CustomPainter {
  final bool active;
  _LinesIconPainter({required this.active});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = active ? AppColors.secondary : const Color(0xFAFAF5EC).withValues(alpha: 0.55);
    c.drawLine(const Offset(3, 4), Offset(19, 4), p);
    c.drawLine(const Offset(3, 11), Offset(19, 11), p);
    c.drawLine(const Offset(3, 18), Offset(13, 18), p);
  }

  @override
  bool shouldRepaint(_LinesIconPainter old) => active != old.active;
}

class _SlidersIconPainter extends CustomPainter {
  final bool active;
  _SlidersIconPainter({required this.active});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = active ? AppColors.secondary : const Color(0xFAFAF5EC).withValues(alpha: 0.55);
    // Top row
    c.drawLine(const Offset(3, 7), Offset(19, 7), p);
    c.drawCircle(const Offset(14, 7), 2.6,
        Paint()..style = PaintingStyle.fill..color = p.color);
    // Bottom row
    c.drawLine(const Offset(3, 16), Offset(19, 16), p);
    c.drawCircle(const Offset(8, 16), 2.6,
        Paint()..style = PaintingStyle.fill..color = p.color);
  }

  @override
  bool shouldRepaint(_SlidersIconPainter old) => active != old.active;
}
