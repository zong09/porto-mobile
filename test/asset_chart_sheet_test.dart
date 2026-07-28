import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/prices/price_history_client.dart';
import 'package:porto_mobile/src/prices/price_repository.dart';
import 'package:porto_mobile/src/ui/widgets/area_chart.dart';
import 'package:porto_mobile/src/ui/widgets/asset_chart_sheet.dart';

class _MockHistory extends Mock implements PriceHistoryClient {}

Asset _asset({
  required String type,
  String symbol = 'BTC',
  String name = 'Bitcoin',
  String currency = 'USD',
  String? yahooSymbol,
}) =>
    Asset(
      id: 'a1',
      portfolioId: 'p1',
      type: type,
      symbol: symbol,
      name: name,
      currency: currency,
      yahooSymbol: yahooSymbol,
      direction: 'long',
      sortOrder: 0,
    );

Widget _app(PriceHistoryClient client, Asset asset) => ProviderScope(
      overrides: [priceHistoryClientProvider.overrideWithValue(client)],
      child: MaterialApp(
        home: Scaffold(body: AssetChartSheet(asset: asset)),
      ),
    );

const _series = [PricePoint(1, 10), PricePoint(2, 12), PricePoint(3, 11)];

void main() {
  testWidgets('crypto charts the design range set and refetches on switch',
      (tester) async {
    final client = _MockHistory();
    when(() => client.cryptoHistory(any(), any()))
        .thenAnswer((_) async => _series);

    await tester.pumpWidget(_app(client, _asset(type: 'crypto')));
    await tester.pumpAndSettle();

    expect(find.byType(AreaChart), findsOneWidget);
    for (final r in ['7D', '30D', '90D', '1Y']) {
      expect(find.text(r), findsOneWidget, reason: 'design-settings.md §3');
    }
    verify(() => client.cryptoHistory('BTC', 7)).called(1);

    await tester.tap(find.text('90D'));
    await tester.pumpAndSettle();

    verify(() => client.cryptoHistory('BTC', 90)).called(1);
  });

  testWidgets('a Thai stock charts through the .BK fallback symbol',
      (tester) async {
    final client = _MockHistory();
    when(() => client.stockHistory(any(), any()))
        .thenAnswer((_) async => _series);

    await tester.pumpWidget(
        _app(client, _asset(type: 'th', symbol: 'PTT', name: 'PTT')));
    await tester.pumpAndSettle();

    // Same fallback as PriceRepository.resolve — a bare 'PTT' charts nothing.
    verify(() => client.stockHistory('PTT.BK', '1M')).called(1);
  });

  testWidgets('stock ranges are trimmed to what the client can serve',
      (tester) async {
    final client = _MockHistory();
    when(() => client.stockHistory(any(), any()))
        .thenAnswer((_) async => _series);

    await tester.pumpWidget(_app(client, _asset(type: 'us', symbol: 'AAPL')));
    await tester.pumpAndSettle();

    for (final r in ['1M', '3M', '1Y']) {
      expect(find.text(r), findsOneWidget);
    }
    // stockHistory maps only 7D/1M/3M/1Y and silently serves 3mo for the rest,
    // so these two pills would lie about the data behind them.
    expect(find.text('6M'), findsNothing);
    expect(find.text('ALL'), findsNothing);
  });

  testWidgets('a fund has no history source and says so', (tester) async {
    final client = _MockHistory();

    await tester.pumpWidget(
        _app(client, _asset(type: 'fund', symbol: 'KFAFIX', currency: 'THB')));
    await tester.pumpAndSettle();

    expect(find.text('ไม่มีข้อมูลราคาย้อนหลัง'), findsOneWidget);
    verifyNever(() => client.cryptoHistory(any(), any()));
    verifyNever(() => client.stockHistory(any(), any()));
  });

  testWidgets('a failed fetch degrades to the no-data note', (tester) async {
    final client = _MockHistory();
    when(() => client.cryptoHistory(any(), any()))
        .thenThrow(Exception('offline'));

    await tester.pumpWidget(_app(client, _asset(type: 'crypto')));
    await tester.pumpAndSettle();

    expect(find.text('ไม่มีข้อมูลราคาย้อนหลัง'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
