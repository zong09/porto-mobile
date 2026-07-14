import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A smooth area/line chart. Values are plotted evenly across the width,
/// oldest→newest, with the line optionally filled down to the baseline.
class AreaChart extends StatelessWidget {
  final List<double> values;
  final Color line;
  final Color? fill; // null = stroke only (row sparkline)
  final bool showEndDot; // draws a filled dot at the last point
  final double strokeWidth; // default 2.5

  const AreaChart(
    this.values, {
    super.key,
    required this.line,
    this.fill,
    this.showEndDot = false,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: AreaChartPainter(
          values,
          line: line,
          fill: fill,
          showEndDot: showEndDot,
          strokeWidth: strokeWidth,
        ),
        child: const SizedBox.expand(),
      );
}

/// Painter for [AreaChart] — Catmull-Rom→cubic smoothing.
class AreaChartPainter extends CustomPainter {
  final List<double> values;
  final Color line;
  final Color? fill;
  final bool showEndDot;
  final double strokeWidth;

  AreaChartPainter(
    this.values, {
    required this.line,
    this.fill,
    this.showEndDot = false,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;

    final w = size.width;
    final h = size.height;
    final topPad = h * 0.08;

    // Compute min/max
    double minV = values[0];
    double maxV = values[0];
    for (int i = 1; i < n; i++) {
      if (values[i] < minV) minV = values[i];
      if (values[i] > maxV) maxV = values[i];
    }
    final range = maxV - minV;

    // Build points
    final List<Offset> points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final double x = w * i / max(n - 1, 1);
      final double y = range == 0
          ? h * 0.5
          : topPad + (1 - (values[i] - minV) / range) * (h - topPad);
      points.add(Offset(x, y));
    }

    // Build smooth path via Catmull-Rom→cubic
    final Path path = Path();
    if (n == 1) {
      // Single point: draw nothing (or a flat line at mid-height)
      return;
    }

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < n - 1; i++) {
      final Offset p0 = points[max(i - 1, 0)];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = points[min(i + 2, n - 1)];

      // Catmull-Rom control points
      final Offset c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final Offset c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    // Fill (only if fill != null)
    if (fill != null) {
      final Path fillPath = Path.from(path);
      fillPath.lineTo(w, h);
      fillPath.lineTo(0, h);
      fillPath.close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..style = PaintingStyle.fill
          ..color = fill!,
      );
    }

    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = line,
    );

    // End dot
    if (showEndDot) {
      canvas.drawCircle(
        points.last,
        4,
        Paint()..color = line,
      );
    }
  }

  @override
  bool shouldRepaint(AreaChartPainter oldDelegate) {
    return !listEquals(values, oldDelegate.values) ||
        line != oldDelegate.line ||
        fill != oldDelegate.fill ||
        showEndDot != oldDelegate.showEndDot ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
