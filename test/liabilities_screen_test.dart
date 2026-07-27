import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/domain/formatters.dart';
import 'package:porto_mobile/src/state/display_money.dart';
import 'package:porto_mobile/src/state/liabilities_notifier.dart';
import 'package:porto_mobile/src/ui/screens/liabilities.dart';
import 'package:porto_mobile/src/ui/widgets/cards.dart';
import 'package:porto_mobile/src/ui/widgets/liability_sheet.dart';

// ── builders ────────────────────────────────────────────────────────────────

Liability _liab({
  String id = 'l1',
  String name = 'ผ่อนรถ',
  double amount = 384000,
  String currency = 'THB',
}) =>
    Liability(id: id, name: name, amount: amount, currency: currency);

/// Records adjust() / addLiability() calls for assertion.
class _RecordingLiabilities extends LiabilitiesNotifier {
  final LiabilitiesState _s;
  Map<String, dynamic>? lastAdjust;
  Map<String, dynamic>? lastAdd;

  _RecordingLiabilities(this._s);

  @override
  Future<LiabilitiesState> build() async => _s;

  @override
  Future<void> adjust({
    required String liabilityId,
    required String type,
    required double amount,
    required String date,
  }) async {
    lastAdjust = {
      'liabilityId': liabilityId,
      'type': type,
      'amount': amount,
      'date': date,
    };
  }

  @override
  Future<void> addLiability({
    required String name,
    required double amount,
    required String currency,
  }) async {
    lastAdd = {'name': name, 'amount': amount, 'currency': currency};
  }
}

Widget _wrap(Widget child, _RecordingLiabilities rec) => ProviderScope(
      overrides: [liabilitiesProvider.overrideWith(() => rec)],
      child: MaterialApp(home: Scaffold(body: child)),
    );

// ── tests ─────────────────────────────────────────────────────────────────

void main() {
  testWidgets('screen renders liability cards + total', (tester) async {
    final rec = _RecordingLiabilities(
      LiabilitiesState(liabilities: [
        _liab(id: 'l1', name: 'ผ่อนรถ', amount: 384000),
        _liab(id: 'l2', name: 'บัตรเครดิต', amount: 100000),
      ]),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [liabilitiesProvider.overrideWith(() => rec)],
      child: const MaterialApp(home: LiabilitiesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ผ่อนรถ'), findsOneWidget);
    expect(find.text('บัตรเครดิต'), findsOneWidget);
    expect(find.byType(ListRowTile), findsNWidgets(2));
    // Total = 484,000.00
    expect(find.text('484,000.00'), findsOneWidget);
  });

  testWidgets('total normalises a USD liability to THB before summing',
      (tester) async {
    // Regression: the fold used to add l.amount raw, so a USD balance was
    // counted as THB — 384,000 + 100 instead of 384,000 + 3,600.
    final rec = _RecordingLiabilities(
      LiabilitiesState(liabilities: [
        _liab(id: 'l1', amount: 384000),
        _liab(id: 'l2', name: 'บัตรเครดิต', amount: 100, currency: 'USD'),
      ]),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        liabilitiesProvider.overrideWith(() => rec),
        displayMoneyProvider
            .overrideWith((ref) async => const DisplayMoney(currency: 'THB', fx: 36)),
      ],
      child: const MaterialApp(home: LiabilitiesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('387,600.00'), findsOneWidget);
    expect(find.text('384,100.00'), findsNothing);
  });

  testWidgets('display currency USD reformats the total', (tester) async {
    final rec = _RecordingLiabilities(
      LiabilitiesState(liabilities: [_liab(id: 'l1', amount: 36000)]),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        liabilitiesProvider.overrideWith(() => rec),
        displayMoneyProvider
            .overrideWith((ref) async => const DisplayMoney(currency: 'USD', fx: 36)),
      ],
      child: const MaterialApp(home: LiabilitiesScreen()),
    ));
    await tester.pumpAndSettle();

    // The THB-denominated total converts: 36,000 THB / 36 == 1,000.00 USD.
    expect(find.text('1,000.00'), findsOneWidget);
    // ...while the row keeps its NATIVE amount. Native currency is locked at
    // creation (CONTRACTS §7) and must not follow the display preference.
    expect(find.text('36,000.00'), findsOneWidget);
  });

  testWidgets('adjust sheet: pay flow calls adjust(type=pay)', (tester) async {
    final rec = _RecordingLiabilities(
      LiabilitiesState(liabilities: [_liab()]),
    );

    await tester.pumpWidget(
        _wrap(LiabilityAdjustSheet(liability: _liab()), rec));
    await tester.pumpAndSettle();

    // Default type is 'pay'. Enter amount.
    await tester.enterText(find.byType(TextField).first, '500');
    await tester.pump();

    final save = find.byType(ElevatedButton);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();

    expect(rec.lastAdjust, isNotNull);
    expect(rec.lastAdjust!['type'], 'pay');
    expect(rec.lastAdjust!['amount'], 500.0);
    expect(rec.lastAdjust!['liabilityId'], 'l1');
  });

  testWidgets('adjust sheet: toggling add calls adjust(type=add)',
      (tester) async {
    final rec = _RecordingLiabilities(
      LiabilitiesState(liabilities: [_liab()]),
    );

    await tester.pumpWidget(
        _wrap(LiabilityAdjustSheet(liability: _liab()), rec));
    await tester.pumpAndSettle();

    // Toggle to the "add" segment (label contains "add").
    await tester.tap(find.textContaining('(add)'));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.pump();

    final save = find.byType(ElevatedButton);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();

    expect(rec.lastAdjust, isNotNull);
    expect(rec.lastAdjust!['type'], 'add');
    expect(rec.lastAdjust!['amount'], 1000.0);
  });
}
