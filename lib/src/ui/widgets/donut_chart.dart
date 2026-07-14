import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:porto_mobile/src/ui/theme/colors.dart';

/// A single slice of a [DonutChart].
class DonutSlice {
  /// Proportional value (not a percentage — values are relative within the list).
  final double value;

  /// Colour of this slice.
  final Color color;

  const DonutSlice(this.value, this.color);
}

/// A ring donut. Slices are drawn clockwise starting at 12 o'clock.
///
/// Avatar donut colour pairs (for callers):
/// - crypto: `[#EC6530 0.62, #FFC79A 0.38]`
/// - th:     `[#1E9396 0.45, #8FDDDF 0.55]`
/// - us:     `[#E6A23C 0.70, #F3D9A8 0.30]`
/// - fund:   `[#C76B8E 0.55, #F7AEC8 0.45]`
/// - General allocation uses [AppColors.palette] in order.
class DonutChart extends StatelessWidget {
  final List<DonutSlice> slices;

  /// Ring thickness / radius ratio, default `0.34`.
  final double strokeFraction;

  /// Gap between slices in degrees, default `0`.
  final double gapDegrees;

  const DonutChart(
    this.slices, {
    super.key,
    this.strokeFraction = 0.34,
    this.gapDegrees = 0,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DonutChartPainter(
          slices,
          strokeFraction: strokeFraction,
          gapDegrees: gapDegrees,
        ),
        child: const SizedBox.expand(),
      );
}

/// [CustomPainter] that draws an allocation donut.
///
/// Slices are drawn clockwise starting at 12 o'clock.
class DonutChartPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final double strokeFraction;
  final double gapDegrees;

  const DonutChartPainter(
    this.slices, {
    this.strokeFraction = 0.34,
    this.gapDegrees = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final w = size.width;
    final h = size.height;
    final radius = math.min(w, h) / 2;
    final center = Offset(w / 2, h / 2);
    final stroke = radius * strokeFraction;

    final gapRad = gapDegrees * math.pi / 180;
    final start = -math.pi / 2; // 12 o'clock
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    double sweepAccum = start;

    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = slice.color;

      if (gapDegrees > 0) {
        paint.strokeCap = StrokeCap.round;
      } else {
        paint.strokeCap = StrokeCap.butt;
      }

      if (gapDegrees > 0) {
        final adjustedStart = sweepAccum + gapRad / 2;
        final adjustedSweep = sweep - gapRad;
        if (adjustedSweep > 0) {
          canvas.drawArc(rect, adjustedStart, adjustedSweep, false, paint);
        }
      } else {
        canvas.drawArc(rect, sweepAccum, sweep, false, paint);
      }

      sweepAccum += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    if (oldDelegate.slices.length != slices.length) return true;
    for (int i = 0; i < slices.length; i++) {
      if (oldDelegate.slices[i].value != slices[i].value ||
          oldDelegate.slices[i].color != slices[i].color) {
        return true;
      }
    }
    if (oldDelegate.strokeFraction != strokeFraction) return true;
    if (oldDelegate.gapDegrees != gapDegrees) return true;
    return false;
  }
}
