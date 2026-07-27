# Handoff — Porto Mobile (Flutter) post-Phase-4 follow-ups

**Date:** 2026-07-27
**Task:** "เช็คหน่อยมีงานอะไรเหลือบ้าง" → audit what remained after Phase 4, then do it.
**Status:** ✅ Two of the four `phase4-handoff.md` follow-ups **done & verified**.
`flutter analyze lib test` clean, **160 tests green** (was 149).

Commits on `main`:

| Commit | What |
|---|---|
| `0230e94` | Thai copy correction — 58 corrupted lines / 9 files (+2 test files) |
| `01fc3c8` | Display-currency toggle wired + 2 mixed-currency sum bugs fixed |

---

## 1. Thai copy corruption — DONE (`0230e94`)

The Phase-4 handoff named 2 files. **That was stale.** A line-by-line audit of every Thai
literal in `lib/src/ui` (176 lines) found **58 corrupted lines across 9 files**:

| File | Thai literals | corrupted |
|---|---|---|
| `screens/settings.dart` | 23 | 15 |
| `app_shell.dart` | 20 | 9 |
| `widgets/transaction_sheet.dart` | 17 | 9 |
| `widgets/liability_sheet.dart` | 15 | 8 |
| `screens/liabilities.dart` | 8 | 6 |
| `screens/overview.dart` | 10 | 5 |
| `screens/transactions.dart` | 15 | 3 |
| `screens/portfolios.dart` | 10 | 2 |
| `widgets/chart_sheet.dart` | 1 | 1 |

**Clean, do not re-audit:** `widgets/asset_sheet.dart` (15 literals, all correct);
`widgets/cards.dart`, `widgets/app_bottom_nav.dart`, `widgets/area_chart.dart`,
`widgets/donut_chart.dart`, `theme/*.dart` (Thai only in comments).

Two test files asserted the corrupted spellings via `find.text` and were updated in the same
commit: `settings_screen_test.dart`, `transactions_screen_test.dart`. (`shared_widgets_test.dart:68`
`'เพิ่ทรายการ'` was left — it's the test's own fixture for a generic widget, not app copy.)

Authority for each correction: the per-screen design specs (`tasks/design-*.md`, e.g.
`design-overview.md:49-54` pins the Add-sheet strings verbatim), with `reference/translations.ts`
as fallback.

**Verification gotcha:** `grep -rn "้้\|ิิ\|่่\|มม" lib/src/ui` catches only **29 of 58** — the
doubled-tone-mark class. It is blind to dropped vowels (`ยกเลง`, `สินทรพย์`, `พอรต์ของฉน`,
`สกุลเงนหลก`). Don't treat that grep returning empty as proof the copy is clean.

**Do NOT delegate Thai text edits to Qwen** — see the `qwen-thai-text-corruption` memory. Tried
it here on `overview.dart`: 2 of 5 replacements wrong, including a *newly introduced* corruption
(`ดูท้้งหมด`), despite the prompt carrying exact copy-paste before/after pairs.

## 2. Display-currency toggle — DONE (`01fc3c8`)

`Formatters.money` took a `currency` argument and threw it away, so `displayCurrency` (written by
Settings › สกุลเงินหลัก) did nothing. Now:

- **`DisplayMoney`** (`lib/src/domain/formatters.dart`) — converts THB-denominated amounts to the
  display currency via the pre-existing `CurrencyConverter.convert`; exposes `symbol` / `label` /
  `money()` / `compact()`. `Formatters.money`'s dead `currency` param is gone.
- **`displayMoneyProvider`** (`lib/src/state/display_money.dart`) — resolves `displayCurrency` +
  `fx` together over the offline-safe `fxProvider`. **`fx` is resolved even for THB display**,
  because screens also need it to normalise *native* amounts to THB. Screens read it as
  `ref.watch(displayMoneyProvider).value ?? DisplayMoney.thb`.
  (Riverpod 3 — it's `.value`; `valueOrNull` does not exist.)
- Threaded into the THB-denominated sites: Overview (net worth, today's P/L, Assets/Liabilities
  stat cards, **and the currency pill, previously hardcoded `'฿ THB'`**), Liabilities (total),
  Transactions (buy/sell summary).

**Native currency deliberately unchanged.** An asset's/liability's currency is locked at creation
(`CONTRACTS §7`); per-row amounts and input suffixes keep their own glyph
(`transactions.dart:358`, `liability_sheet.dart:49,307`, `asset_sheet.dart`). Don't "unify" these
with display currency — they are different features. `liabilities_screen_test` has a test asserting
the separation (total converts, row stays native).

### Three pre-existing bugs fixed en route
1. `liabilities.dart` total summed `l.amount` across currencies raw → a USD balance counted as THB.
   Now `CurrencyConverter.toThb`, matching `NetWorthCalculator.summary()`.
2. `transactions.dart` buy/sell totals had the same raw-sum bug.
3. Same loop seeded its totals map with Thai labels but wrote keys by the raw side
   (`'buy'`/`'sell'`), so the hero summary rendered **English** keys. Now keyed by `_sideLabel()`.

---

## ⚠️ OPEN DECISION — displayCurrency defaults to USD

`SettingsRepo.getDisplayCurrency()` returns `?? 'USD'` (`settings_repo.dart:13`). Before `01fc3c8`
this was invisible: the Overview pill was hardcoded `'฿ THB'` and nothing read the setting. **Now
that the toggle works, a fresh install renders USD** — converted values and a `$ USD` pill.

The evidence conflicts:
- **USD** — `CONTRACTS.md:388` specifies `?? 'USD'`, and `settings_backup_test.dart:30` asserts it.
- **THB** — mobile design 1b is THB-primary; `design-settings.md:20` draws the row trailing
  `฿ THB ›`; `language` defaults to `'th'`; every domain field is `*Thb`.

**Left as USD** — CONTRACTS is the frozen Phase-0 source of truth and a test pins it, so flipping
it is a product decision, not a refactor. `test/smoke_test.dart` now pins the setting to THB
explicitly rather than relying on the default. **If the intended default is THB**, change
`settings_repo.dart:13`, `CONTRACTS.md:388`, and `settings_backup_test.dart:30` together.

## Still not done (unchanged from Phase 4)

- **Dual-currency inline display — deliberately NOT done.** A web carry-over that mobile design 1b
  contradicts (the `0.72` in the design is opacity ranks, not currency). Don't implement unless the
  design changes.
- **On-device `integration_test/`** — environment-blocked: no emulator/adb here, and the repo has
  only `android`+`ios` platform dirs. `test/smoke_test.dart` covers the flow headlessly and can be
  ported when a device exists.
- **Minor, untouched:** `transaction_sheet.dart:223,277` hardcode `suffix: '฿'` on the qty/price
  inputs even for USD assets — a separate *native*-currency bug, not the display feature.
  `app_shell.dart`'s local-data note is a flat `Text`; `design-overview.md:53-54` wants
  `ในเครื่องของคุณ` emphasised `700 #C24A1E`, which needs `RichText` (cosmetic, deferred).

## Build / test (Windows)

```bash
export PATH="/c/src/flutter/bin:$PATH"   # Flutter 3.44.6 at C:\src\flutter, NOT on PATH
cd /c/Gits/porto-mobile
flutter analyze lib test    # must be clean
flutter test                # 160 green
```

No emulator/adb → cannot `flutter run` here; widget tests are the end-to-end check.
