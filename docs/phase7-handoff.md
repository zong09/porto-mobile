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

## Follow-up, same session — the three open items were then closed

### `portfolios.dart` mixed-currency sums — DONE (`65cfab0`)

The warning under fix 1 is resolved. Shared helpers now live beside the node types in
`portfolios_notifier.dart` — `assetCostThb` / `assetsCostThb` / `nodeCostThb` /
`assetRealizedPnlThb` — with **the aggregate-vs-native rule written at the definition**:

> Aggregates over possibly-mixed assets convert first; single-asset rows keep their own
> amount and their own glyph.

Overview dropped its private `_nodeCostThb` and uses the shared ones, so the two screens
cannot diverge again. Its fx-35 test passed untouched, which is what proves the refactor
was behaviour-preserving.

**The allocation bars were the quiet part.** They render percentages, not money, so nothing
looked wrong — but a portfolio holding \$1000 and ฿1000 drew two equal segments. All four
folds now normalise. Verified sensitive by reverting one fold to the raw sum and watching the
50%/50% legend assertion fail.

Also fixed en route: the detail Realized P/L hardcoded `$`, and money values used bare
`toStringAsFixed(2)` so the screen mixed grouped and ungrouped numbers.

### Edit-mode prefill — DONE

`_editable()` drops the `.0` from whole amounts so 3 prefills as `3`, not `3.0`. Fractional
values are left to `toString()` so nothing is rounded away — both cases are tested.

### On-device `integration_test/` — PORTED, **NOT VERIFIED**

`integration_test/app_test.dart` exists and is analyze-clean, with the `integration_test` SDK
dev-dep added. **It has never been executed.** `flutter test integration_test/app_test.dart`
here still reports *"No devices are connected"* — only Windows-desktop and Edge are available
and this project has no runner for either. Treat its first real run as the actual test of it.

**It does not duplicate the flow.** The 200-line body moved to `test/smoke_flow.dart` as
`runSmokeFlow()`; `test/smoke_test.dart` and `integration_test/app_test.dart` are thin
wrappers differing only in binding. So the on-device file cannot rot while unrunnable — the
headless wrapper exercises the same body on every `flutter test`. `smoke_flow.dart` is
deliberately not named `*_test.dart`, so the runner does not collect it directly.

**`flutter test` count excludes it** — 176 green is what actually ran.

## Still open

- **Dual-currency inline display — still deliberately NOT done.** `phase4-handoff.md:58`
  records why: the `0.72` in the design is *opacity ranks*, misread as a currency treatment.
  Mobile design 1b is THB-primary with a single display-currency toggle. Implementing it would
  contradict the design, so it needs a product decision, not a coding task.

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
flutter analyze lib test integration_test   # must be clean
flutter test                                # 176 green

# On-device only — fails here with "No devices are connected":
flutter test integration_test/app_test.dart
```
