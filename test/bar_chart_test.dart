import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/ui/widgets/bar_chart.dart';

void main() {
  testWidgets('five positive bars paint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 80,
          child: const BarChart(
            [3, 7, 5, 9, 4],
            barColor: Color(0xFFEC6530),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mixed sign bars paint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 80,
          child: const BarChart(
            [3, -2, 5, -4],
            barColor: Color(0xFF1E9396),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty / all-zero paints nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 80,
          child: const BarChart(
            [],
            barColor: Color(0xFFEC6530),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 80,
          child: const BarChart(
            [0, 0],
            barColor: Color(0xFFEC6530),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  test('shouldRepaint true on values change', () {
    expect(
      BarChartPainter(
        [1, 2],
        barColor: const Color(0xFFEC6530),
      ).shouldRepaint(
        BarChartPainter(
          [1, 3],
          barColor: const Color(0xFFEC6530),
        ),
      ),
      isTrue,
    );
  });
}
