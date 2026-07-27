# Handoff — Porto Mobile (Flutter) post-Phase-5 follow-ups

**Date:** 2026-07-28
**Task:** "ทำต่อที่ค้างไว้เลย ใช้งาน qwen ด้วย" → finish what `phase5-handoff.md` left open.
**Status:** ✅ Both remaining actionable items done, **plus the open USD-default decision resolved**.
`flutter analyze lib test` clean, **162 tests green** (was 160 — +2 new).

The other open items in `phase5-handoff.md` are *not* actionable and were correctly left alone:
dual-currency inline display (design contradicts it) and on-device `integration_test/`
(no emulator/adb in this env).

---

## 1. Transaction sheet used `฿` for USD assets — DONE

`transaction_sheet.dart` hardcoded `suffix: '฿'` on the **ราคาต่อหน่วย** and **ค่าธรรมเนียม**
inputs, so buying a USD asset (BTC, US stocks) prompted for a baht price. The qty input was
already correct (`_selected!.symbol`).

Fix — a getter next to `_qty`/`_price`/`_fee`/`_total`, matching the file's idiom:

```dart
String get _nativeSymbol => _selected?.currency == 'USD' ? r'$' : '฿';
```

Polarity is `== 'USD'` (not `liability_sheet.dart:49`'s `== 'THB'`) so a null `_selected`
falls through to `฿`.

**This is the *native* currency, not the display currency** — same separation
`phase5-handoff.md §2` established. Price and fee are entered in the asset's own currency:
`position_calculator.dart:68` computes `q * p + f`, so fee shares price's unit, and
`price_repository.dart:66-67` fetches `cp.usd` vs `cp.thb` off `asset.currency`. Do **not**
route these through `DisplayMoney`.

**The `มูลค่ารวม` banner is deliberately left symbol-less.** `Formatters.money` carries no glyph
by design, and the banner was already ambiguous before this change — adding a native glyph there
is a separate design decision, not part of this bug.

New test: `transactions_screen_test.dart` → `price + fee suffixes follow the asset native currency`
(USD asset → 2×`$`, THB asset → 2×`฿`).

## 2. Local-data note emphasis — DONE

`design-overview.md:53-54` wants `ในเครื่องของคุณ` emphasised `700 #C24A1E` inside the add-sheet
note; it was a flat `Text`.

**Used `Text.rich`, NOT `RichText`** — this matters. `find.text` matches a `Text` via
`data ?? textSpan.toPlainText()`, so `Text.rich` stays findable by its full plain text; raw
`RichText` is skipped unless the caller passes `findRichText: true`. `phase5-handoff.md` said
"needs `RichText`" — read that as intent, not the widget name.

Base style lives on the parent `TextSpan` (the emphasised child overrides only weight + colour),
and the whole tree is `const` to keep `prefer_const_constructors` quiet.

New test: `overview_screen_test.dart` → `add sheet local-data note keeps its full copy`, asserting
`find.text('ข้อมูลอยู่ในเครื่องของคุณ — ไม่มีบัญชี ไม่ต้องล็อกอิน')`. **This is the guard against
splitting Thai wrongly** — verified by injecting a dropped-vowel corruption
(`ของคุณ`→`ของคณ`) and confirming the test fails. The test literal was byte-compared against
`git show HEAD:...app_shell.dart` before the split.

### Test-harness gotchas hit here

- **The add sheet overflows the default 800×600 test surface by 73px.** Pre-existing —
  reproduced against the *original* `Text` by stashing the change. The test raises
  `tester.view.physicalSize` to `Size(2400, 3600)` (800×1200 logical at dpr 3) with
  `addTearDown(tester.view.resetPhysicalSize)`. **Only the height.** A first attempt used a
  390-logical-wide phone surface and tripped a *different*, unrelated horizontal `Row` overflow.
  Don't narrow the width in these tests.
- **`TransactionSheet` re-pumps reuse the `State`.** `_selected` is set in `initState`, so pumping
  a second asset into the same widget type without a key silently keeps the first one. The test
  passes `key: ValueKey(a.id)`.

## 3. `displayCurrency` now defaults to THB — DECIDED & DONE

The open decision from `phase5-handoff.md:86-100` was **put to the user, who chose THB.** A fresh
install now renders baht, not converted dollars. This is a deliberate **amendment to CONTRACTS**,
not a drift from it.

Five sites changed together — the handoff named three; **two more encoded the same default:**

| Site | Change |
|---|---|
| `lib/src/repos/settings_repo.dart:13` | `?? 'USD'` → `?? 'THB'` |
| `CONTRACTS.md:388` | spec comment amended to match |
| `test/settings_backup_test.dart:30` | fresh-db default assertion → `'THB'` |
| `test/settings_backup_test.dart:102` | **not in the original list.** Asserted a USD default, then `setCurrency('THB')`. Flipping only the assertion would have made it vacuous (set THB, expect THB), so the *target* was flipped to USD — the test still proves `setCurrency` changes something. |
| `test/smoke_test.dart:166` | **not in the original list.** A comment citing the USD default. The explicit `setDisplayCurrency('THB')` pin above it **stays** — it keeps the test independent of whatever the default is. |

If this is ever revisited, `grep -rn "displayCurrency" lib test CONTRACTS.md` finds all of them;
the two beyond the named three are easy to miss.

## Qwen usage this session (per the `/qwen-agent` ask)

| Delegated | Result |
|---|---|
| Read-only audit: every hardcoded currency glyph / code in `lib` | **Useful.** Confirmed `transaction_sheet.dart:223,277` were the only offenders; every other site already branches on currency. Its `TOTAL: 48` was wrong (listing had ~35), so the count was discarded and the list re-verified with an independent grep. |
| Run `flutter analyze lib test` + `flutter test`, report pass/fail | **Failed.** Ran `flutter doctor` instead of either command and returned a toolchain report in a format nothing like the one specified. Output discarded; verification re-run by Claude. |

**Not delegated, deliberately:** the Thai `Text.rich` split (the `qwen-thai-text-corruption` memory
— and `phase5-handoff.md:50-52` records Qwen introducing a *new* corruption even with exact
copy-paste pairs), and the currency-polarity fix (needs the native-vs-display judgment).

**Lesson for next session:** Qwen is usable for *read-only search & summarise* if you re-verify
its aggregates, but it did not reliably follow a two-command "run this, report that" contract.
Run verification yourself.

## Noticed, NOT fixed (surgical-changes discipline)

- **`transaction_sheet.dart` `_assetSelector` is inert.** It renders `เปลี่ยน ›` but has no
  `GestureDetector`/`onTap`, so `_selected` can never change after `initState`. The sheet is
  therefore only usable via `initialAsset`. Real gap, separate task.
- The add-sheet 73px overflow above — pre-existing layout, not touched.
- `app_shell.dart`'s note uses `EdgeInsets.all(16)`; `design-overview.md:54` says `12px 16px`.
  Pre-existing, cosmetic, not touched.

## Still open

- Dual-currency inline display — design contradicts it; don't implement.
- On-device `integration_test/` — needs an emulator/device.

## Build / test (Windows)

```bash
export PATH="/c/src/flutter/bin:$PATH"   # Flutter 3.44.6 at C:\src\flutter, NOT on PATH
cd /c/Gits/porto-mobile
flutter analyze lib test    # must be clean
flutter test                # 162 green
```
