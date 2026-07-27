# Handoff — Porto Mobile (Flutter) placeholder cleanup

**Date:** 2026-07-28
**Task:** "ทำทั้งหมดเลยให้เสร็จ สั่ง qwen ด้วย" → clear every non-functional control in the UI.
**Status:** ✅ All five audited placeholders done, **plus a sixth bug found while mapping them**.
`flutter analyze lib test` clean, **171 tests green** (was 162 — +9 new).

**Phase 4 is genuinely complete.** It is the last phase in
`C:\Gits\porto\docs\mobile-app-plan-flutter.md`, and its sub-items that no prior handoff
mentioned all exist: refresh-on-resume (`main.dart:65`), snapshot, error snackbars. What was
missing was never a *phase* — it was buttons wired to nothing.

---

## The six fixes

### 1. Overview rendered a literal placeholder card

`overview.dart` shipped a card reading **"Portfolio list — coming in T3.06"** on the app's home
screen, months after T3.06 landed (`effc321`). Replaced with a real `DividedCard` list off
`portfoliosProvider`: donut avatar, portfolio name, member-symbol subtitle, value.

**The value is normalised to THB before display.** `position.totalCost` is in each asset's
*native* currency, so `_nodeCostThb` runs `CurrencyConverter.toThb` per asset — the same
mixed-currency bug fixed in Liabilities/Transactions (`phase5-handoff.md §2`). Test pins it:
a USD portfolio with cost 100 at fx 35 must render `3,500.00`, not `100.00`.

> **⚠️ `portfolios.dart` still has that bug.** `PortfoliosScreen`'s hero total (`:29-32`),
> `_PortfolioCard` (`:475`), `_AllocationBar` and `PortfolioDetailScreen` all sum
> `position.totalCost` **raw across currencies**. Overview is now correct and Portfolios is not,
> so the same portfolio can show two different numbers. Left alone deliberately — it is a
> value-math correctness task with its own tests, not a placeholder. **Fix this next.**

Also wired the inert **"ดูทั้งหมด"** link → new `onSeeAllPortfolios` callback → AppShell switches
to the Portfolios tab (mirrors the existing `onOpenLiabilities`).

### 2. Create-portfolio did nothing

`portfolios.dart:142` showed a snackbar reading `'Create portfolio sheet'`. New
`lib/src/ui/widgets/portfolio_sheet.dart` → `PortfolioCreateSheet` (name field + 6-swatch colour
picker) calling `addPortfolio`. Wired to **both** entry points: the hero pill and the dashed
"＋ สร้างพอร์ตใหม่" card, which had no `onTap` at all.

Colour indices are constrained to `0..AppColors.palette.length-1` **at the picker**, because
`PortfolioRepo.create` throws `ArgumentError` outside `0..5` and `_PortfolioCard` indexes
`AppColors.palette[portfolio.color]` unguarded. Empty names are rejected in the sheet for the
same reason — a test covers it.

### 3. Tapping a transaction did nothing

`transactions.dart:350` showed `'Edit ${tx.id}'`. Now opens `TransactionSheet` in edit mode,
which already supported `existing` — it had simply never been reached. The sheet title is
`'แก้ไขรายการ'` in edit mode instead of the side label.

The asset list comes from `portfoliosProvider` (matching `app_shell._allAssets()`), with the
row's own asset appended if portfolios haven't resolved — otherwise the sheet could open with an
empty `assets` list and `initState`'s `assets.first` would throw.

### 4. "ลบข้อมูลทั้งหมด" was a dead button

The confirm dialog worked; its confirm callback was `// destructive action placeholder`. Now
`SettingsScreen.onDeleteAll` → `AppShell._deleteAllData()` → `importFromJson(const {})`.
No new repo method: `BackupRepo.importJson` deletes every table before inserting, so an empty
payload *is* the wipe. CONTRACTS untouched.

**This required fixing a real bug to work at all** — `SettingsNotifier.importFromJson` only did
`invalidateSelf()`, so every other notifier kept serving rows that no longer existed. Delete-all
would have wiped the DB while Portfolios kept listing everything. Now it invalidates
`portfolios`/`transactions`/`liabilities`/`overview`. **This repairs import too**, which had the
same staleness bug since it was written — not scope creep, the same root cause.

### 5. The transaction sheet's asset selector was inert

`เปลี่ยน ›` had no `onTap`, so `_selected` could never change after `initState` and the sheet
was only usable via `initialAsset`. Now opens a picker sheet; selecting swaps the asset **and**
the native-currency suffixes follow it (asserted in the same test).

### 6. NOT on the original list — the FAB's "เพิ่มหนี้สิน" rendered with no sheet chrome

Found while mapping sheet-presentation call sites. Two conventions exist in this codebase:

- `TransactionSheet` **wraps `SheetShell` itself** → present with a bare `showModalBottomSheet`.
- `AssetSheet` / `LiabilityCreateSheet` / `PortfolioCreateSheet` **build fields only** → present
  with `showPortoSheet`, which supplies the chrome.

`app_shell.dart:102` used the wrong one for `LiabilityCreateSheet`, rendering a bare `Column` on
a transparent background with no handle, title, or close button. `liabilities.dart:84` had it
right all along. **Check which convention a sheet follows before presenting it.**

## Qwen usage this session

| Delegated | Result |
|---|---|
| Read-only API inventory (verbatim signatures of 6 notifier/repo/widget files) | **Useful and accurate.** Followed the output contract exactly; spot-checked `showPortoSheet` and `BackupRepo` against the source and both matched. This is what unblocked items 2–4. |
| Read-only completeness sweep for leftover stubs after the work | See the sweep note below. |

**Nothing was delegated for implementation.** All six fixes carry Thai UI copy, and the
`qwen-thai-text-corruption` memory plus `phase5-handoff.md:50-52` rule that out. The currency and
provider-invalidation judgment also needed this session's context.

Qwen's reliability is *task-shaped*: read-only inventory with a rigid output format worked twice;
a two-command verification run failed outright last session (it ran `flutter doctor` instead).
**Never let it verify — run analyze/test yourself.**

## Still open

- **`portfolios.dart` mixed-currency sums** — see the warning under fix 1. Highest-value next task.
- `transaction_sheet.dart` edit mode prefills `_qtyCtrl` via `quantity.toString()`, so 3 renders
  as `3.0`. Cosmetic; now reachable for the first time via fix 3.
- On-device `integration_test/` — needs an emulator/device.
- Dual-currency inline display — design contradicts it; don't implement.

## Test-harness gotchas (cost real time this session)

- **The default 800×600 test surface is too short for several screens.** Settings' destructive row
  sits at y≈741; the add sheet overflows by 73px. Fix: `tester.view.physicalSize = Size(2400, 3600)`
  (800×1200 logical at dpr 3) + `addTearDown(tester.view.resetPhysicalSize)`. **Raise the height
  only** — narrowing the width to a phone size trips unrelated horizontal overflows.
- **Adding a `ref.watch` to a screen breaks tests that override only its old providers.**
  `OverviewScreen` now watches `portfoliosProvider`; `_app` and the pull-to-refresh test both
  needed the extra override.
- `ListRowTile.trailing` is **required** — pass `SizedBox.shrink()` when there is nothing to show.

## Build / test (Windows)

```bash
export PATH="/c/src/flutter/bin:$PATH"   # Flutter 3.44.6 at C:\src\flutter, NOT on PATH
cd /c/Gits/porto-mobile
flutter analyze lib test    # must be clean
flutter test                # 171 green
```
