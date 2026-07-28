import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/repos/liability_repo.dart';
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
  Liability? saved;
  String? deleted;

  _RecordingLiabilities(this._s);

  @override
  Future<LiabilitiesState> build() async => _s;

  @override
  Future<void> saveLiability(Liability l) async {
    saved = l;
  }

  @override
  Future<void> deleteLiability(String id) async {
    deleted = id;
  }

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

  // ── the picker must not accept a future date ─────────────────────────────
  //
  // This picker capped at 2100 while the transaction sheet's caps at today:
  // two pickers, two policies for the same question. A pay/add is a record of
  // something that happened, so it is aligned on today and pinned here.
  //
  // Asserted on the next-month arrow rather than on a day cell to keep it
  // clock-independent: with `lastDate` at now, today's month is always the last
  // allowed one, whatever the date is when the suite runs. Under the old 2100
  // cap the arrow is enabled.

  testWidgets('adjust sheet: the date picker stops at today', (tester) async {
    tester.view.physicalSize = const Size(2400, 3600); // 800x1200 logical
    addTearDown(tester.view.resetPhysicalSize);

    final rec = _RecordingLiabilities(
      LiabilitiesState(liabilities: [_liab()]),
    );

    await tester.pumpWidget(
        _wrap(LiabilityAdjustSheet(liability: _liab()), rec));
    await tester.pumpAndSettle();

    // Fields in build order: [0] จำนวนเงิน, [1] วันที่ — readOnly, opens the
    // picker on tap. Indexed rather than found by text, which would be today's.
    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    final dialog = find.byType(DatePickerDialog);
    expect(dialog, findsOneWidget);

    final nextMonth = tester.widget<IconButton>(find.descendant(
      of: dialog,
      matching: find.widgetWithIcon(IconButton, Icons.chevron_right),
    ));
    expect(nextMonth.onPressed, isNull);
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

  // ── edit / delete a liability ───────────────────────────────────────────
  //
  // `saveLiability` and `deleteLiability` both had no call site in lib/. The
  // adjust sheet only ever moved the balance; nothing could fix a typo'd name
  // or remove a liability that was paid off.

  /// Opens the adjust sheet for `_liab()` from the screen, so the pop-with-
  /// 'edit' handshake is exercised rather than stubbed.
  Future<_RecordingLiabilities> openAdjust(
    WidgetTester tester, {
    int txCount = 0,
  }) async {
    tester.view.physicalSize = const Size(2400, 3600); // 800x1200 logical
    addTearDown(tester.view.resetPhysicalSize);

    final rec =
        _RecordingLiabilities(LiabilitiesState(liabilities: [_liab()]));
    final repo = _MockLiabRepo();
    when(() => repo.txsFor(any())).thenAnswer(
      (_) async => List.generate(txCount, (i) => _ltx('lt$i')),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        liabilitiesProvider.overrideWith(() => rec),
        liabilityRepoProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: LiabilitiesScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ผ่อนรถ'));
    await tester.pumpAndSettle();
    return rec;
  }

  testWidgets('แก้ไขข้อมูลหนี้สิน reopens the form prefilled and saves',
      (tester) async {
    final rec = await openAdjust(tester);

    await tester.tap(find.text('แก้ไขข้อมูลหนี้สิน'));
    await tester.pumpAndSettle();

    expect(find.text('แก้ไขหนี้สิน'), findsOneWidget);

    // Read the controllers: the name field's hint is 'ผ่อนรถ' too, so
    // widgetWithText cannot tell a prefill from an empty create form.
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.first.controller!.text, 'ผ่อนรถ');
    // 384000, not "384000.0" — same prefill rule as TransactionSheet.
    expect(fields.elementAt(1).controller!.text, '384000');

    // liability_transactions carry no currency of their own, so editing it
    // would re-denominate the whole pay/add history.
    expect(
      tester
          .widget<IgnorePointer>(
              find.byKey(const ValueKey('liability-currency-lock')))
          .ignoring,
      isTrue,
    );

    await tester.enterText(find.byType(TextField).first, 'ผ่อนบ้าน');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    expect(rec.saved?.id, 'l1');
    expect(rec.saved?.name, 'ผ่อนบ้าน');
    expect(rec.lastAdd, isNull, reason: 'edit must not create a second row');
  });

  testWidgets('ลบหนี้สิน names the cascaded history then deletes',
      (tester) async {
    final rec = await openAdjust(tester, txCount: 2);

    await tester.tap(find.text('ลบหนี้สิน'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ประวัติจ่าย/เพิ่ม 2 รายการ'), findsOneWidget);

    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();
    expect(rec.deleted, isNull);

    await tester.tap(find.text('ลบหนี้สิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();

    expect(rec.deleted, 'l1');
  });
}

LiabilityTransaction _ltx(String id) => LiabilityTransaction(
      id: id,
      liabilityId: 'l1',
      type: 'pay',
      amount: 100,
      date: '2026-07-01',
      createdAt: '2026-07-01T00:00:00Z',
    );

class _MockLiabRepo extends Mock implements LiabilityRepo {}
