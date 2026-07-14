import 'package:flutter/material.dart';

/// Vertical bars, evenly spaced. Positive bars grow up from the baseline;
/// if any value is negative, the baseline is mid-height and negatives grow down.
class BarChart extends StatelessWidget {
  final List<double> values;
  final Color barColor;
  final List<Color>? perBar;
  final double gap;
  final double radius;

  const BarChart(
    this.values, {
    super.key,
    required this.barColor,
    this.perBar,
    this.gap = 6,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BarChartPainter(
          values,
          barColor: barColor,
          perBar: perBar,
          gap: gap,
          radius: radius,
        ),
        child: const SizedBox.expand(),
      );
}

/// Hand-painted vertical bar chart.
class BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;
  final List<Color>? perBar;
  final double gap;
  final double radius;

  BarChartPainter(
    this.values, {
    required this.barColor,
    this.perBar,
    this.gap = 6,
    this.radius = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;

    final w = size.width;
    final h = size.height;

    double maxAbs = 0;
    for (final v in values) {
      final a = v.abs();
      if (a > maxAbs) maxAbs = a;
    }
    if (maxAbs == 0) return;

    final hasNeg = values.any((v) => v < 0);
    final baseline = hasNeg ? h / 2 : h;
    final avail = hasNeg ? h / 2 : h;

    final barW = (w - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + gap);
      final len = (values[i].abs() / maxAbs) * avail;
      final top = values[i] >= 0 ? baseline - len : baseline;

      final color = perBar != null && i < perBar!.length
          ? perBar![i]
          : barColor;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(x, top, barW, len);

      if (values[i] >= 0) {
        // Positive: round top corners only
        final rrect = RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        );
        canvas.drawRRect(rrect, paint);
      } else {
        // Negative: round bottom corners only
        final rrect = RRect.fromRectAndCorners(
          rect,
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
        canvas.drawRRect(rrect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return values != oldDelegate.values ||
        barColor != oldDelegate.barColor ||
        perBar != oldDelegate.perBar ||
        gap != oldDelegate.gap ||
        radius != oldDelegate.radius;
  }
}
