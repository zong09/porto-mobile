import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/ui/widgets/donut_chart.dart';

void main() {
  testWidgets('three-slice donut paints', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: const DonutChart(<DonutSlice>[
              DonutSlice(50, Color(0xFFEC6530)),
              DonutSlice(26, Color(0xFFFFC79A)),
              DonutSlice(24, Color(0xFFFFE3CF)),
            ]),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('single full-ring slice', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: const DonutChart(<DonutSlice>[
              DonutSlice(1, Color(0xFFEC6530)),
            ]),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty / zero-total paints nothing', (tester) async {
    // empty list
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: const DonutChart(<DonutSlice>[]),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    // zero total
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: const DonutChart(<DonutSlice>[
              DonutSlice(0, Color(0xFFEC6530)),
            ]),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  test('shouldRepaint true on slice change', () {
    expect(
      DonutChartPainter(const [DonutSlice(1, Color(0xFFEC6530))])
          .shouldRepaint(
        DonutChartPainter(const [DonutSlice(2, Color(0xFFEC6530))]),
      ),
      isTrue,
    );
  });
}
