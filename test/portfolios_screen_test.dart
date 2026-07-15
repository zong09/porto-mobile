import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/domain/position_calculator.dart';
import 'package:porto_mobile/src/state/portfolios_notifier.dart';
import 'package:porto_mobile/src/ui/screens/portfolios.dart';
import 'package:porto_mobile/src/ui/widgets/asset_sheet.dart';
import 'package:porto_mobile/src/ui/widgets/cards.dart';

// ── builders ────────────────────────────────────────────────────────────────

Portfolio _pf({String id = 'p1', String name = 'พอร์ตหลัก', int color = 0}) =>
    Portfolio(id: id, name: name, color: color, sortOrder: 0);

Asset _asset({
  String id = 'a1',
  String portfolioId = 'p1',
  String symbol = 'BTC',
  String name = 'Bitcoin',
  String currency = 'USD',
  String type = 'crypto',
}) =>
    Asset(
      id: id,
      portfolioId: portfolioId,
      type: type,
      symbol: symbol,
      name: name,
      currency: currency,
      direction: 'long',
      sortOrder: 0,
    );

PositionSummary _pos({double totalCost = 1000}) => PositionSummary(
      quantity: 1,
      avgCost: totalCost,
      totalCost: totalCost,
      realizedPnl: 0,
      direction: 'long',
    );

AssetNode _an({Asset? asset, double totalCost = 1000}) =>
    AssetNode(asset: asset ?? _asset(), position: _pos(totalCost: totalCost));

PortfolioNode _node({Portfolio? portfolio, List<AssetNode>? assets}) =>
    PortfolioNode(
      portfolio: portfolio ?? _pf(),
      assets: assets ?? [_an()],
    );

class _FakePortfolios extends PortfoliosNotifier {
  final PortfoliosState _s;
  _FakePortfolios(this._s);
  @override
  Future<PortfoliosState> build() async => _s;
}

Widget _app(PortfoliosState s) => ProviderScope(
      overrides: [portfoliosProvider.overrideWith(() => _FakePortfolios(s))],
      child: const MaterialApp(home: PortfoliosScreen()),
    );

Widget _sheetApp(Widget sheet) => ProviderScope(
      overrides: [
        portfoliosProvider.overrideWith(
            () => _FakePortfolios(const PortfoliosState(nodes: []))),
      ],
      child: MaterialApp(home: Scaffold(body: sheet)),
    );

Finder _currencyIgnorePointer() =>
    find.byKey(const ValueKey('currency-lock'));

// ── tests ─────────────────────────────────────────────────────────────────

void main() {
  testWidgets('list renders one card per portfolio node', (tester) async {
    final s = PortfoliosState(nodes: [
      _node(portfolio: _pf(id: 'p1', name: 'พอร์ต A')),
      _node(portfolio: _pf(id: 'p2', name: 'พอร์ต B', color: 1)),
    ]);

    await tester.pumpWidget(_app(s));
    await tester.pumpAndSettle();

    expect(find.text('พอร์ต A'), findsOneWidget);
    expect(find.text('พอร์ต B'), findsOneWidget);
    expect(find.byType(ListRowTile), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a card opens detail', (tester) async {
    final s = PortfoliosState(nodes: [
      _node(
        portfolio: _pf(id: 'p1', name: 'พอร์ต A'),
        assets: [_an(asset: _asset(symbol: 'ETH', name: 'Ethereum'))],
      ),
    ]);

    await tester.pumpWidget(_app(s));
    await tester.pumpAndSettle();

    await tester.tap(find.text('พอร์ต A'));
    await tester.pumpAndSettle();

    expect(find.byType(PortfolioDetailScreen), findsOneWidget);
    expect(find.text('ETH'), findsWidgets);
  });

  testWidgets('AssetSheet create mode allows currency choice', (tester) async {
    await tester.pumpWidget(_sheetApp(const AssetSheet(portfolioId: 'p1')));
    await tester.pumpAndSettle();

    // Currency control is NOT ignored → user can pick.
    final ip = tester.widget<IgnorePointer>(_currencyIgnorePointer());
    expect(ip.ignoring, isFalse);

    // Both currency options present and tappable.
    expect(find.text('฿ THB'), findsOneWidget);
    await tester.tap(find.text('฿ THB'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AssetSheet edit mode locks currency', (tester) async {
    await tester.pumpWidget(_sheetApp(
      AssetSheet(portfolioId: 'p1', existing: _asset(currency: 'USD')),
    ));
    await tester.pumpAndSettle();

    // Currency control is wrapped in an IgnorePointer that blocks interaction.
    final ip = tester.widget<IgnorePointer>(_currencyIgnorePointer());
    expect(ip.ignoring, isTrue);
  });
}
