# Plan — next session: close the asset-management hole

**Written:** 2026-07-28, at the end of the session that produced `b6d736e` / `65cfab0` / `7382bd4`.
**Baseline:** `main` clean, `flutter analyze lib test integration_test` clean, **176 tests green**.

> ## ✅ DONE 2026-07-28 — `c7c37ff` (task 1) + `8660b85` (tasks 2 & 3)
>
> All three tasks closed, `tasks/T3.06.md` amended (step 5), audit re-run with the
> four sharper categories (step 4 — **findings below, not yet fixed**).
> `flutter analyze lib test integration_test` clean, **182 tests green** (was 176).
>
> Decisions taken, for the record:
> - **Entry point:** the recommended dashed "＋ เพิ่มสินทรัพย์" card. Renders even
>   when the portfolio is empty, which is the dead-end case.
> - **Snapshot fix:** constructor still takes `PortfolioNode`; it is now only the
>   fallback while the provider resolves. Kept the signature to avoid churning the
>   call site and tests.
> - **Portfolio delete: deliberately NOT added.** `deletePortfolio` stays uncalled;
>   "consider whether delete belongs here" was speculative scope.
> - **One change outside the three tasks:** `TransactionsNotifier._reload` now
>   invalidates `portfoliosProvider`. Without it task 2's buttons save a buy that
>   the screen never reflects — a wired-but-useless control, the thing this plan
>   exists to stop.
>
> Two things worth knowing that the plan did not predict:
> - `TransactionsNotifier` is **autoDispose**, and nothing keeps it alive except
>   `AppShell` being an `IndexedStack` that mounts `TransactionsScreen` on every
>   tab. A `TransactionSheet` opened with that screen unmounted loses the write
>   silently — `ref.read` returns, the provider disposes, the repo call never
>   lands. Fine in the shipped app; fragile. `add_asset_flow_test.dart` has to
>   watch the provider explicitly to reproduce real conditions.
> - The `บันทึก` / `บันทึกรายการ` save-button labels differ between sheet types.
>   `find.text` is exact, so this costs a test-debugging cycle every time.

---

> ## ✅ ALL FOUR STEP-4 FINDINGS CLOSED 2026-07-28
>
> `flutter analyze lib test integration_test` clean, **196 tests green** (was 182).
> Re-running the category-4 sweep over `lib/` now leaves only two uncalled
> notifier methods, both deliberate (below).
>
> | Finding | Outcome |
> |---|---|
> | `ChartSheet` orphaned | **Wired.** `showAssetChartSheet` on the featured-asset sparkline, per `design-settings.md:38`. New `AssetChartSheet` wrapper fetches history and refetches on range switch. |
> | `BarChart` orphaned | **Kept, unplaced — decided, not overlooked.** See below. |
> | No way to edit or delete an asset | **Fixed.** Asset rows + featured-card header open `AssetSheet(existing:)`; ลบสินทรัพย์ sits in the edit sheet. |
> | `deleteTransaction`, `saveLiability`, `deletePortfolio`, `reorderPortfolios` uncalled | **Two built, two deliberately not.** Detail below. |
>
> **A fifth uncalled method the step-4 table missed:** `deleteLiability`. The
> sweep listed four; the repo-level `dao.deleteLiability` at
> `liability_repo.dart:45` masked the notifier one, the same
> "beware the obvious grep" trap recorded above. It is now wired too.
>
> ### Deliberately left uncalled — do not "find" these again
>
> - **`BarChart`.** Commissioned by `design-components.md` §6c, but **no screen
>   in any of the five design docs places it.** It is also a different defect
>   class from the rest: an unconstructed `CustomPainter` is dead *code*, not a
>   dead *control* — nobody can tap it and be lied to. Inventing a placement
>   would be scope invented from nothing. Delete it only when a design says
>   where a bar chart goes, or explicitly drops it.
> - **`reorderPortfolios`.** Drag-to-reorder appears in no design doc. The DAO
>   and notifier are ready; the affordance needs a design first.
> - **`deletePortfolio`.** Already decided last session ("speculative scope"),
>   unchanged. Note it cascades assets → transactions, so it needs the same
>   naming-confirm treatment as the three deletes that did land.
>
> ### Decisions taken while building
>
> - **Stock chart ranges are trimmed** to `1M 3M 1Y`, not the design's
>   `1M 3M 6M 1Y ALL`. `PriceHistoryClient.stockHistory` maps only
>   `7D/1M/3M/1Y` and silently falls back to `3mo` for anything else — a `6M`
>   pill would have been a control that lies, which is what this plan exists to
>   stop. Crypto keeps the full `7D 30D 90D 1Y`; every one hits a real branch.
>   Widen it when the client learns those ranges, not before.
> - **`ChartSheet` skips its own title when empty.** Presented through
>   `showPortoSheet`, `SheetShell` already renders the title, and
>   `design-settings.md` puts the title on the sheet, not in the body. The two
>   existing bare-pump tests still pass a title and still see it.
> - **Liability currency is locked on edit**, mirroring the asset rule.
>   `liability_transactions` rows carry no currency of their own, so switching
>   it would silently re-denominate the entire pay/add history. CONTRACTS does
>   not state this — it locks only `assets.currency` (§7).
> - **The adjust sheet pops `'edit'`** instead of stacking the edit form on top
>   of its own now-stale balance banner; `liabilities.dart` re-presents. Same
>   pop-with-a-value convention as the asset picker in `transaction_sheet.dart`.
> - **`confirmDelete` / `DeleteButton`** are shared in
>   `lib/src/ui/widgets/confirm_delete.dart` (three real call sites).
>   `settings.dart:_showDeleteConfirm` was deliberately **not** folded into it —
>   it works, and refactoring it was not part of this task.
>
> ### The bug wiring `deleteAsset` exposed — and why every widget test missed it
>
> `PortfoliosNotifier._reload()` only did `ref.invalidateSelf()`. Giving
> `deleteAsset` a call site made that a real defect: the FK cascade drops the
> asset's `transactions` rows, but `TransactionsNotifier` is never told, and
> because `AppShell`'s `IndexedStack` keeps `TransactionsScreen` mounted it is
> never disposed either — so the tab keeps rendering `ซื้อ BTC` for a row the DB
> no longer has. Fixed by adding `ref.invalidate(transactionsProvider)`, the
> exact mirror of the edge `TransactionsNotifier._reload` already had.
>
> **Every new widget test was green over it.** They all override the notifier
> method itself (`_RecordingPortfolios.deleteAsset` just records the id), so
> `_reload()` never runs and no cross-provider invalidation is exercised — the
> same blind spot this plan already diagnosed for the repo-seeded smoke flow.
> The check that catches it is notifier-level against a real in-memory
> `AppDatabase`: `portfolios_notifier_test.dart` →
> `'deleteAsset invalidates transactionsProvider'`. **Reach for that shape
> whenever a mutation crosses providers** — a screen test cannot see it.
>
> ### Still open (pre-existing, not introduced here)
>
> - **Liability mutations never invalidate `overviewProvider`**, so Net Worth on
>   Overview goes stale after a liability is added, adjusted, saved or deleted.
>   `LiabilitiesNotifier._reload` has the same one-line gap
>   `PortfoliosNotifier._reload` just had. Untouched here because
>   `addLiability`/`adjust` already shipped with it — it is not a regression of
>   this change, but it is the same bug.

---

## Step 4 re-run — what the four sharper categories found

Ran over `lib/` after the fixes. Every hit is the **same class of defect** as the
original three: complete, unit-tested code with no path to it from the UI.

**Beware the obvious grep.** Counting `.deleteAsset(` / `.deletePortfolio(` /
`.reorderPortfolios(` in `lib/` returns 1 each and looks clean — every one of
those is a **DAO method of the same name** (`portfolio_repo.dart:32`,
`asset_repo.dart:90`), not the notifier's. A Qwen run and a naive local grep
produced identical wrong counts, which is the plan's "agreement proves nothing"
warning landing a second time. Read the matched lines, never the count.

| Finding | Caught by | Detail |
|---|---|---|
| **`ChartSheet` is orphaned** | never constructed outside tests | Built and tested (`settings_screen_test.dart:147`), constructed nowhere in `lib/`. Exactly what `AssetSheet` was. |
| **`BarChart` is orphaned** | never constructed outside tests | Only `bar_chart_test.dart` builds it. |
| **No way to edit or delete an asset** | notifier method with no call site | `AssetSheet(existing:)` is passed only in a test, so its edit branch is unreachable; `saveAsset`'s sole call site sits inside it, and notifier `deleteAsset` has none. Asset rows in Portfolio detail are not tappable. The likely fix is symmetric with task 3: make `_AssetRow` / `_FeaturedAssetCard` open `AssetSheet(existing:)`. |
| **`deleteTransaction`, `saveLiability`, `deletePortfolio`, `reorderPortfolios` uncalled** | notifier method with no call site | No UI deletes a transaction or edits a liability. Decide per item whether the design wants it before building. |

**All four categories were run.** Categories 2 and 3 came up clean:

- **Category 2** (`onTap`/`onPressed` that only calls `Navigator.pop()`) — five hits
  in `lib/`, every one legitimate: the Portfolio detail back button
  (`portfolios.dart:223`), two `SheetShell` close buttons, the delete-confirm
  dialog's ยกเลิก (`settings.dart:362`), and `transaction_sheet.dart:141`, which
  pops **with a value** to return the picked asset. Nothing to fix.
- **Category 3** (action-labelled `Container`/`Text` with no ancestor gesture
  handler) — empty after the `แก้ไข` fix. Every remaining action label resolves to
  an `InkWell`, `GestureDetector`, or a `ListRowTile`/`_actionRow` with a callback;
  each was checked by reading its enclosing widget, not by grep.

One deliberate near-miss, listed so nobody "fixes" it twice: the two Settings
switches (`settings.dart:316`) are `onChanged: null`, commented *"local UI only,
inert in v1"*. A null `onChanged` renders a Switch visibly disabled, so it does
not pretend to work — unlike the three controls this session fixed.

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
