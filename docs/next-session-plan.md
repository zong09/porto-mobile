# Plan — next session: close the asset-management hole

**Written:** 2026-07-28, at the end of the session that produced `b6d736e` / `65cfab0` / `7382bd4`.
**Baseline:** `main` clean, `flutter analyze lib test integration_test` clean, **176 tests green**.

---

## Why this exists

An audit at the end of the last session found three dead/wrong controls that the earlier
placeholder sweep **missed**. One of them makes the app unusable end-to-end.

### Root cause — the T3.06 brief authorised the gap

`tasks/T3.06.md` is where this came from, and it is worth reading before starting:

- It specifies `AssetSheet` in full but **never says who opens it**. The widget was built
  correctly and wired to nothing.
- It says the buy/sell buttons may be *"`onTap` callbacks that may be no-ops / pop"* — so
  `Navigator.pop()` was a faithful implementation of the brief, not a slip.

Neither gap was ever revisited. **When closing these, update `tasks/T3.06.md` too**, or the next
person reading the brief will think the current state is correct.

### Why the test suite is green anyway

`test/smoke_flow.dart` seeds portfolios/assets/transactions **through the repos directly**, not
through the UI. Every screen test uses fake notifier state. So no test has ever exercised
"create an asset from the UI" — the path simply does not exist to be tested.

**Fix that as part of task 1**, otherwise the suite stays green over the same hole.

### Why the earlier sweep missed all three

The sweep (and the Qwen cross-check, which used the same categories and therefore agreed) looked
for: empty callback bodies, snackbar-only callbacks, and `placeholder`/`coming in` strings.
None of the three match. **Use these categories next time:**

| Category | Why it matters |
|---|---|
| Widget class never constructed outside tests | Catches an orphaned `AssetSheet` |
| `onTap`/`onPressed` that only calls `Navigator.pop()` | Pop is a *plausible* body, so it reads as intentional |
| Action-labelled `Container`/`Text` with no ancestor gesture handler | Catches the inert `แก้ไข` chip |
| Notifier mutation methods with no call site in `lib/` | Would have flagged `renamePortfolio`, `recolorPortfolio`, `deleteAsset` |

That last one is a good one-line health check on its own.

---

## Task 1 — make it possible to add an asset ⚠️ blocker

**Symptom:** fresh install → create portfolio → **dead end.** No asset can be created, so no
transaction can be recorded. `app_shell._startTransaction` even shows `'เพิ่มสินทรัพย์ก่อน'` and
jumps to the Portfolios tab, which has no add-asset control.

`AssetSheet` (`lib/src/ui/widgets/asset_sheet.dart`) is complete and tested — it builds fields
only, so present it with `showPortoSheet` (**not** `_showSheet`; see the two sheet conventions in
`phase7-handoff.md` fix 6).

```dart
AssetSheet({required String portfolioId, Asset? existing})   // existing != null → currency LOCKED
```

Notifier call it makes: `addAsset({portfolioId, type, symbol, name, currency, cgId?, yahooSymbol?, manualPrice?, direction='long'})`.

### ⚠️ Design gap — decide the entry point first

**The design spec does not cover this.** `design-portfolios.md` "Portfolio detail" lists back /
name / แก้ไข / value / allocation / assets / realized-P/L, with **no add-asset affordance**, and
`design-overview.md:46` pins the FAB sheet to a 2×2 grid of exactly four actions. So this is a
product decision, not a lookup.

| Option | Trade-off |
|---|---|
| **Dashed "＋ เพิ่มสินทรัพย์" card at the end of the assets list in Portfolio detail** ← recommended | Mirrors the dashed "＋ สร้างพอร์ตใหม่" card that already exists in `portfolios.dart`; established in both the code and the design language; touches nothing the design pins |
| 5th tile in the FAB add-sheet | Contradicts the pinned 2×2 grid |
| Behind the `แก้ไข` chip | Hides a primary action inside an edit affordance |

### ⚠️ Blocking sub-problem — the detail screen holds a stale snapshot

`PortfolioDetailScreen({required PortfolioNode node})` (`portfolios.dart:167-170`) captures the
node at push time (`:530`). **Adding an asset will not appear** — the screen re-renders from the
captured value.

It is already a `ConsumerWidget`, so the fix is small: keep the id, re-read the live node.

```dart
final node = ref.watch(portfoliosProvider).value?.nodes
    .firstWhereOrNull((n) => n.portfolio.id == portfolioId) ?? widget-supplied fallback;
```

Decide whether the constructor takes a `PortfolioNode` (and derives the id) or just a
`portfolioId`. **Do this before wiring the sheet**, or task 1 will look broken when it isn't.

### Done when
- A fresh DB can reach: create portfolio → add asset → record a buy, entirely through the UI.
- The new asset appears in Portfolio detail **without** popping and re-entering the screen.
- A widget test drives that full path through the UI (not the repos) — this is the coverage that
  does not exist today.

---

## Task 2 — "ซื้อเพิ่ม" / "ขาย" currently close the screen

`portfolios.dart:673` and `:682` are `onTap: () => Navigator.of(context).pop()`. The user taps
"ซื้อเพิ่ม" and gets thrown out of Portfolio detail. Worse than dead — it does something wrong.

(`:210` is the back button and is also a `pop()`. **That one is correct** — do not "fix" it.)

Per `design-portfolios.md`, both should open the transaction form with the side preset:

```dart
TransactionSheet({required String side, required List<Asset> assets,
                  Asset? initialAsset, Transaction? existing})
```

`TransactionSheet` **wraps `SheetShell` itself** → present with a bare `showModalBottomSheet`
(copy the config from `transactions.dart _editTransaction`, which does exactly this).

`_FeaturedAssetCard` is a `StatelessWidget` holding only an `AssetNode`, so it cannot build the
`assets` list. Thread the portfolio's assets down, or pass an `onBuy`/`onSell` callback from
`PortfolioDetailScreen` (which has both the node and `ref`). Callback is cleaner.

### Done when
`ซื้อเพิ่ม` opens the sheet with `side: 'buy'` and the card's asset preselected; `ขาย` the same
with `'sell'`; neither pops the detail screen. Test asserts the sheet title and preselected asset.

---

## Task 3 — the "แก้ไข" chip is inert

`portfolios.dart:250` is a bare `Container` with no gesture handler.
`renamePortfolio(id, name)` and `recolorPortfolio(id, color)` already exist and **have no call
site anywhere in `lib/`**.

`PortfolioCreateSheet` (`lib/src/ui/widgets/portfolio_sheet.dart`) is already a name field + a
6-swatch colour picker — i.e. exactly the edit form. Give it an optional `existing` portfolio the
way `AssetSheet` takes `existing`: prefill, and call rename/recolor instead of `addPortfolio`.
Reuse it rather than writing a second sheet.

Consider whether delete belongs here too — `deletePortfolio(id)` is also uncalled. If added, use
the confirm-dialog pattern from `settings.dart:_showDeleteConfirm`.

### Done when
`แก้ไข` opens the sheet prefilled with the current name and colour; saving renames/recolours and
the list reflects it. Empty name rejected, as in create mode (`PortfolioRepo.save` throws).

---

## Suggested order

1. **Task 1's snapshot fix** — unblocks everything else in Portfolio detail.
2. **Task 1** proper, with the UI-driven test.
3. **Tasks 2 and 3** — same screen, same sheets, small once 1 is done.
4. Re-run the audit with the four sharper categories above.
5. Update `tasks/T3.06.md` so the brief no longer authorises the gap.

Commit separately — task 1 is a behaviour change worth isolating.

## Qwen notes

- **Do delegate:** read-only inventories with a rigid output format (verbatim signatures, call-site
  lists). Worked twice. **Always re-verify its counts** — it reported `TOTAL: 48` for a ~35-line
  listing once.
- **Never delegate:** anything touching Thai copy (`qwen-thai-text-corruption`), and never let it
  run verification — asked to run `flutter analyze` + `flutter test`, it ran `flutter doctor` and
  reported a toolchain summary instead.
- A Qwen sweep agreeing with yours means nothing if you both used the same categories. That is
  exactly how these three got missed.

## Verify

```bash
export PATH="/c/src/flutter/bin:$PATH"   # Flutter 3.44.6 at C:\src\flutter, NOT on PATH
cd /c/Gits/porto-mobile
flutter analyze lib test integration_test   # must be clean
flutter test                                # 176 green at the start of the session
```

**Test-harness gotchas** (all cost time last session, see `phase7-handoff.md`): the default
800×600 surface is too short for Settings and the add sheet — raise `tester.view.physicalSize` to
`Size(2400, 3600)`, **height only**; re-pumping the same widget type reuses its `State` unless you
give it a `Key`; adding a `ref.watch` breaks tests that override only the old providers.
