import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/domain/position_calculator.dart';
import 'package:porto_mobile/src/domain/formatters.dart';
import 'package:porto_mobile/src/state/display_money.dart';
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

Widget _app(PortfoliosState s, {DisplayMoney? money}) => ProviderScope(
      overrides: [
        portfoliosProvider.overrideWith(() => _FakePortfolios(s)),
        if (money != null)
          displayMoneyProvider.overrideWith((ref) async => money),
      ],
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

  // ── mixed-currency aggregates ───────────────────────────────────────────

  testWidgets('hero total normalises USD before summing', (tester) async {
    // USD 100 @ fx 35 = 3,500 THB, plus THB 1,000 → 4,500.00.
    // Summing raw would show 1,100.00.
    await tester.pumpWidget(_app(
      PortfoliosState(nodes: [_mixedNode()]),
      money: const DisplayMoney(currency: 'THB', fx: 35),
    ));
    await tester.pumpAndSettle();

    expect(find.text('4,500.00'), findsWidgets);
    expect(find.text('1,100.00'), findsNothing);
  });

  testWidgets('portfolio card value follows the display currency',
      (tester) async {
    // Same 4,500 THB shown in USD at fx 35 → 128.57.
    await tester.pumpWidget(_app(
      PortfoliosState(nodes: [_mixedNode()]),
      money: const DisplayMoney(currency: 'USD', fx: 35),
    ));
    await tester.pumpAndSettle();

    expect(find.text(Formatters.money(4500 / 35)), findsWidgets);
  });

  testWidgets('allocation legend uses THB-normalised proportions',
      (tester) async {
    // p1 = USD 100 → 3,500 THB; p2 = THB 3,500. Equal halves.
    // Raw sums would read 100 vs 3,500 → 3% / 97%.
    final nodes = PortfoliosState(nodes: [
      PortfolioNode(
        portfolio: const Portfolio(id: 'p1', name: 'USD พอร์ต', color: 0,
            sortOrder: 0),
        assets: [
          _an(asset: _asset(id: 'u1', currency: 'USD'), totalCost: 100),
        ],
      ),
      PortfolioNode(
        portfolio: const Portfolio(id: 'p2', name: 'THB พอร์ต', color: 1,
            sortOrder: 1),
        assets: [
          _an(
            asset: _asset(id: 't1', portfolioId: 'p2', currency: 'THB',
                type: 'th'),
            totalCost: 3500,
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(
        _app(nodes, money: const DisplayMoney(currency: 'THB', fx: 35)));
    await tester.pumpAndSettle();

    expect(find.text('USD พอร์ต 50%'), findsOneWidget);
    expect(find.text('THB พอร์ต 50%'), findsOneWidget);
  });

  testWidgets('detail converts the total but leaves asset rows native',
      (tester) async {
    await tester.pumpWidget(_app(
      PortfoliosState(nodes: [_mixedNode()]),
      money: const DisplayMoney(currency: 'THB', fx: 35),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ผสม'));
    await tester.pumpAndSettle();

    // Aggregate converts...
    expect(find.text('4,500.00'), findsWidgets);
    // ...while the single-asset rows keep their own amount AND glyph.
    expect(find.text(r'$100.00'), findsOneWidget); // the USD asset, unconverted
    expect(find.text('฿1,000.00'), findsOneWidget); // the THB asset
  });

  // ── create-portfolio sheet ──────────────────────────────────────────────

  testWidgets('create pill opens the sheet and saves a portfolio',
      (tester) async {
    final rec = _RecordingPortfolios(PortfoliosState(nodes: [_node()]));

    await tester.pumpWidget(ProviderScope(
      overrides: [portfoliosProvider.overrideWith(() => rec)],
      child: const MaterialApp(home: PortfoliosScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ สร้างพอร์ต'));
    await tester.pumpAndSettle();

    // Sheet chrome comes from showPortoSheet, so the title is rendered.
    expect(find.text('สร้างพอร์ตใหม่'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'พอร์ตใหม่');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    expect(rec.added, isNotNull);
    expect(rec.added!['name'], 'พอร์ตใหม่');
    expect(rec.added!['color'], 0);
  });

  testWidgets('create sheet rejects an empty name', (tester) async {
    final rec = _RecordingPortfolios(PortfoliosState(nodes: [_node()]));

    await tester.pumpWidget(ProviderScope(
      overrides: [portfoliosProvider.overrideWith(() => rec)],
      child: const MaterialApp(home: PortfoliosScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ สร้างพอร์ต'));
    await tester.pumpAndSettle();

    // Save with a blank name — PortfolioRepo.create would throw, so the sheet
    // must stop it here and stay open.
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    expect(rec.added, isNull);
    expect(find.text('กรุณากรอกชื่อพอร์ต'), findsOneWidget);
  });

  testWidgets('dashed create-new card opens the sheet too', (tester) async {
    await tester.pumpWidget(_app(PortfoliosState(nodes: [_node()])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ สร้างพอร์ตใหม่'));
    await tester.pumpAndSettle();

    expect(find.text('สร้างพอร์ตใหม่'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

/// Portfolio holding one USD asset and one THB asset.
PortfolioNode _mixedNode({String id = 'p1', String name = 'ผสม'}) =>
    PortfolioNode(
      portfolio: Portfolio(id: id, name: name, color: 0, sortOrder: 0),
      assets: [
        _an(
          asset: _asset(id: '$id-usd', portfolioId: id, symbol: 'BTC',
              currency: 'USD'),
          totalCost: 100,
        ),
        _an(
          asset: _asset(id: '$id-thb', portfolioId: id, symbol: 'PTT',
              name: 'PTT', currency: 'THB', type: 'th'),
          totalCost: 1000,
        ),
      ],
    );

/// Records addPortfolio instead of hitting the repo.
class _RecordingPortfolios extends PortfoliosNotifier {
  final PortfoliosState _s;
  Map<String, dynamic>? added;

  _RecordingPortfolios(this._s);

  @override
  Future<PortfoliosState> build() async => _s;

  @override
  Future<void> addPortfolio({required String name, required int color}) async {
    added = {'name': name, 'color': color};
  }
}
