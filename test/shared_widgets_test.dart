import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/ui/widgets/cards.dart';
import 'package:porto_mobile/src/ui/widgets/sheet_shell.dart';

void main() {
  group('shared widgets', () {
    Widget wrap(Widget child) {
      return MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('PlainCard renders child', (tester) async {
      await tester.pumpWidget(wrap(
        PlainCard(child: Text('hi')),
      ));
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('DividedCard inserts dividers', (tester) async {
      await tester.pumpWidget(wrap(
        DividedCard(rows: [Text('a'), Text('b'), Text('c')]),
      ));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StatCard shows label + value', (tester) async {
      await tester.pumpWidget(wrap(
        Row(
          children: [
            Expanded(
              child: StatCard(label: 'Assets', value: '฿4.67M'),
            ),
          ],
        ),
      ));
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('฿4.67M'), findsOneWidget);
    });

    testWidgets('ListRowTile shows title/subtitle and fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        ListRowTile(
          leading: SizedBox(width: 40, height: 40),
          title: 'Crypto',
          subtitle: 'BTC·ETH',
          trailing: Text('฿1,842,300'),
          onTap: () => tapped = !tapped,
        ),
      ));
      expect(find.text('Crypto'), findsOneWidget);
      expect(find.text('BTC·ETH'), findsOneWidget);
      expect(tapped, isFalse);
      await tester.tap(find.byType(ListRowTile));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('SheetShell shows title, close fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(wrap(
        SheetShell(
          title: 'เพิ่ทรายการ',
          onClose: () => closed = true,
          child: Text('body'),
        ),
      ));
      expect(find.text('เพิ่ทรายการ'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(closed, isFalse);
      await tester.tap(find.text('\u{2715}'));
      await tester.pump();
      expect(closed, isTrue);
    });
  });
}
