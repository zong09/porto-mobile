import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/ui/widgets/area_chart.dart';

void main() {
  testWidgets('paints an 8-point hero series', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 358,
            height: 74,
            child: AreaChart(
              const [10, 12, 11, 15, 14, 18, 17, 22],
              line: Colors.white,
              fill: Colors.white.withValues(alpha: 0.14),
              showEndDot: true,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('stroke-only sparkline, no fill', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 50,
            child: AreaChart(
              const [1, 2, 3],
              line: const Color(0xFF1E9396),
              fill: null,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  test('shouldRepaint true when values change', () {
    expect(
      AreaChartPainter(
        const [1, 2],
        line: Colors.white,
      ).shouldRepaint(
        AreaChartPainter(
          const [1, 3],
          line: Colors.white,
        ),
      ),
      isTrue,
    );
  });

  testWidgets('empty list paints nothing without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 50,
            child: AreaChart(
              const [],
              line: Colors.white,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
