# Plan — next session, with Qwen doing the legwork

> ## ✅ EXECUTED 2026-07-28 — steps 0, Q1, Q2 and the overviewProvider fix
>
> Seven commits on `main` (`c035fd0`..`986bc85`).
> `flutter analyze lib test integration_test` clean, **199 tests green** (was 196).
>
> **Commit order changed from the table below.** As written it does not compile:
> `portfolios.dart` carries *both* the asset edit/delete work and the
> `showAssetChartSheet` call, so commit 2 called a function created in commit 3.
> Chart-sheet files now land first (unused), then `portfolios.dart` brings both
> call sites at once.
>
> **Q3 was skipped.** Its verify step is "read the four 3-line `_reload()` bodies
> and check Qwen's rollup" — strictly more work than just reading them. Read
> directly; the matrix in this doc was correct in every cell.
>
> ### The overviewProvider fix — premise confirmed first
>
> The diagnosis below is derived from a grep, which proves nothing on its own.
> The question that settles it: does `OverviewNotifier.build()` use `ref.watch`
> or `ref.read`? It uses **`ref.read`, and on the repos, not the notifier
> providers** (`overview_notifier.dart:64-69`) — so nothing propagates and the
> bug is real. Had it been `watch`, the whole fix would have been a no-op plus a
> test passing for the wrong reason. **Check this before trusting an
> invalidation grep.**
>
> Fixed by adding `ref.invalidate(overviewProvider)` to the three `_reload()`s
> that feed Net Worth. `SettingsNotifier` deliberately left alone: `setCurrency`
> and `setLanguage` do not feed `build()`, and `importFromJson` already has it.
>
> Three notifier-level tests, one per edge. **Verified by stashing the lib
> change** — all three fail (0 vs -1000, 0 vs 3500, 3500 vs 0) and pass with it.
> Without that stash-check a `container.listen`-less version passes for the
> wrong reason, so do it whenever the test targets an autoDispose provider.
>
> ### Qwen's accuracy, third data point
>
> Q1 (design affordances): **good.** ~60 lines, three spot-checked at
> `file:line` and all three accurate. This is the job shape that pays.
> It did leak Thai label names into its output despite the instruction —
> harmless in a read-only inventory, but the "never Thai" rule is not reliably
> obeyed, only made safe by the job being read-only.
>
> Q2a: **half wrong on the only lines that mattered.** Of four `0 | NONE`
> reports, two were false — `AreaChartPainter` is constructed at
> `area_chart.dart:26` and `DonutChartPainter` at `donut_chart.dart:43`, both
> inside their own widget's `build`. Qwen appears to skip same-file
> constructions. `BarChart` (the planted known-answer) was correctly 0.
> **Re-grep every zero; that is where the entire error rate lives.**
> Q2b: clean, all six screens constructed once.
>
> ### Findings — Q1 diffed against `lib/`, two real gaps
>
> Both are the plan's own defect class, found from the design side, which is the
> independence a same-categories cross-check cannot give.
>
> 1. **Fund assets were permanently worth 0** — ✅ **FIXED**, `AssetSheet` now
>    has a `ราคาต่อหน่วย` input. It offered กองทุน (`asset_sheet.dart:24`) with
>    no `manualPrice` input anywhere in the sheet, while `PriceRepository`
>    resolves `fund` to `manualPrice ?? 0` (`price_repository.dart:44-45`) — so
>    every fund created through the UI was valued 0 forever with no way to
>    correct it. A selectable option that could not work: worse than an unwired
>    control.
>
>    **Read `design-portfolios.md:62` as printed, not as summarised.** It says
>    *"Optional: **manualPrice** (fund/deposit/manual) input; **cgId /
>    yahooSymbol** advanced inputs (collapsible ขั้นสูง)"* — only cgId and
>    yahooSymbol are inside the disclosure. Putting manualPrice behind ขั้นสูง
>    would leave a fund at 0 unless the user knew to expand it.
>
>    Scoped to `fund` only, against the design's *(fund/deposit/manual)*:
>    `deposit` resolves to a fixed 1 (`:39-41`) and would **ignore** the value —
>    building that input is the very defect class being closed. `'manual'` is
>    not in `_types` at all. The live types keep it absent: it is their offline
>    fallback (`:91-93`), so edit passes `Value.absent()` rather than clearing
>    a stored one.
>
>    **`cgId` is deliberately still not built.** It is written by `asset_repo`
>    and read by *no price path in `lib/`* — an input for it would be a control
>    that does nothing. `yahooSymbol` is genuinely read (`:70`) but defaults
>    sensibly (`SYMBOL.BK` / `SYMBOL`), so its absence breaks nothing.
>    `price_repository_test.dart:65` already proved `fund → manualPrice`; the
>    missing half was only ever the UI path, which is what the new tests cover.
> 2. **The Realized P/L banner was inert** — ✅ **FIXED**, it now opens
>    Transactions filtered to sells. `portfolios.dart:372` was a bare
>    `Container` carrying a `›` chevron with no gesture handler anywhere above
>    it, while `design-portfolios.md:49` says it opens a filtered Transactions
>    view. Exactly the `แก้ไข`-chip shape.
>
>    The design does not say *which* filter; **sells** was the call — realized
>    P/L is what the sells produced, and `'sell'` is already a filter key.
>
>    **The mechanism is the interesting part.** The banner sits in a route
>    pushed *on top of* the Portfolios tab, so it can reach neither
>    `_TransactionsScreenState._filter` nor `_AppShellState._currentIndex`.
>    Rather than thread a callback down four widgets, the filter moved into
>    `txFilterProvider` (`lib/src/state/ui_state.dart`) and `AppShell` listens,
>    bringing tab 2 forward when it changes.
>
>    Deliberately **plain state, not a one-shot "navigate" request**: there is
>    nothing to consume and no ordering to get wrong between the two listeners.
>    The obvious alternatives both have a bug — a widget `initialFilter`
>    parameter goes stale when the same filter is requested twice, and a
>    request-then-clear provider depends on listener ordering.
>
>    **But `TxFilter` overrides `updateShouldNotify` to always return true, and
>    that is load-bearing.** The *filter* is idempotent; the *navigation riding
>    on it* is a one-shot event. Under default value-change semantics, tapping
>    the banner a second time writes `sell` over `sell`, nothing fires, and the
>    pop drops the user on the Portfolios tab — a control that works once and
>    then lies, the exact class this session exists to close. Caught only
>    because `app_shell_tab_test.dart` leaves the tab and requests the *same*
>    filter again; the single-request test was green over it.
>    `AppShell`'s `_currentIndex` and `initialIndex` are untouched; the listener
>    guards on `!= 2` so tapping a pill while already on the tab does not
>    trigger a shell rebuild. `_activePill` is gone — it duplicated `_filter`.
>
>    Both halves are covered: `portfolios_screen_test.dart` drives the banner
>    (filter becomes `sell`, detail route pops) and `app_shell_tab_test.dart`
>    asserts the `IndexedStack` index moves to 2. That second one asserts on the
>    index, not on `find.byType(TransactionsScreen)` — the stack mounts all four
>    children on every tab, so a find always hits.
>
> Checked and **already correctly wired** (do not re-find): the Liabilities stat
> card (`overview.dart:201`, `GestureDetector` → `onOpenLiabilities`), the
> ดูทั้งหมด link, the transaction filter pills, every tappable row.
> Specified but **entirely unbuilt, not dead controls**: the first-run screen
> CTAs (`design-overview.md:62`) and the `+ ใหม่` new-portfolio chip in the
> transaction form (`design-transactions.md:50`).
>
> ### Two more dead controls, in `transaction_sheet.dart` — the sweep missed both
>
> That "entirely unbuilt" paragraph above was incomplete. Reading the sheet top
> to bottom, rather than grepping it, turns up two controls that *are* built and
> do not work — the worse class. Neither was in any Q1/Q2 output: Q1 inventories
> the design side and both fields **are** in the design, and Q2 counts class
> constructions, which says nothing about a field inside a widget that builds.
> **Reading one file end to end found what two inventories structurally could
> not.**
>
> 3. **The วันที่ field could not be picked** — ✅ **FIXED**, it now opens
>    `showDatePicker`. `_dateField` was a bare `Container` > `Text(_date)` with
>    no gesture handler anywhere above it (the whole file had four, none of them
>    this one), while `design-transactions.md:49` specifies a date *picker*
>    field. So `_date` never moved off its `initState` value: **every
>    transaction was stamped today**, and a wrong date on an existing row could
>    not be corrected. It sits in a 2-col grid beside a fee input that *is*
>    editable, so it reads as a field — the `แก้ไข`-chip shape again.
>
>    `lastDate: DateTime.now()` — a future-dated transaction is a data-entry
>    error, and this is the deliberate call, not an oversight. But `initialDate`
>    is clamped and parsed with `tryParse`, because `date` is a free-text column
>    and `importFromJson` can land a future or malformed value: `showDatePicker`
>    *asserts* on `initialDate > lastDate`, so an imported row would crash the
>    sheet on tap. Two lines of guard against a reachable input, not defensive
>    padding.
>
>    The test asserts **both** halves — the field re-renders *and*
>    `saveTransaction` carries the new date. A `setState` that never fed
>    `_save()` passes the label assertion alone, the same "green for the wrong
>    reason" trap recorded twice above. Written failing first: it died on
>    `expect(find.byType(DatePickerDialog), findsOneWidget)`, which is the
>    missing handler and nothing else.
>
>    Two things the test deliberately does **not** share with its neighbours.
>    Its fixture date is `2020-01-15`, not the file's usual `2026-07-10`:
>    `lastDate` is `DateTime.now()`, so a fixture in the *current* month couples
>    the test to the wall clock — on a machine dated earlier the clamp opens the
>    picker on a different month and the expected date never appears. 2020 is
>    behind any plausible clock. And it taps `OK`, which only exists because no
>    `localizationsDelegates` are registered, so the picker falls back to en_US;
>    **adding Thai delegates to the app will break this tap**, confusingly, at
>    the confirm step.
>
> 4. **The โน้ต field silently discards what the user types** — ⚠️ **FOUND, NOT
>    FIXED, and that is a decision.** `_noteCtrl` is created
>    (`transaction_sheet.dart:45`), rendered with a label and a hint (`:381`),
>    disposed (`:88`) — and never read by `_save()`. Grepping `note` across
>    `lib/` returns those five lines and nothing else. The reason is upstream:
>    **`Transactions` has no `note` column** (`tables.dart:31-44`), so there is
>    nowhere to put it.
>
>    Deferred because persisting it is not the same size of job as it looks.
>    `schemaVersion = 1` and the migration is `onCreate`-only
>    (`database.dart:22-26`) — **this repo has never written an upgrade step.**
>    Adding the column means authoring the project's first real migration, a
>    drift regen, and new repo + notifier parameters. That is a new workstream,
>    not the tail of this one. Deleting the field instead is not open either:
>    `design-transactions.md:52` specifies it.
>
>    So it is recorded here in the same register as `BarChart` — a decision with
>    a reason, not an omission. **Whoever takes it: the migration is the task,
>    the UI is already built.**
>
> ### `เข้าพอร์ต` (`design-transactions.md:50`) is redundant, not missing
>
> Design field #4 is segmented portfolio chips plus the `+ ใหม่` chip, and the
> sheet has no portfolio control at all — but a transaction's portfolio is
> already determined by `assetId → asset.portfolioId`. A chip row here could
> only either agree with the asset or contradict it. It is listed above as
> "unbuilt"; it is more precisely **not needed against this schema**. Build it
> only if assets ever become portfolio-independent.

**Written:** 2026-07-28, at the end of the session that closed the four step-4
findings (see `next-session-plan.md`).

**Baseline:** `flutter analyze lib test integration_test` clean, **196 tests
green**. ⚠️ **The work is UNCOMMITTED.** `git status` shows 14 modified + 4 new
files (this plan is one of them). Commit that before anything else — see step 0.

---

## The one rule that makes Qwen usable in this repo

This codebase is saturated with Thai UI copy, and Qwen mangles Thai combining
characters and then reports success (`qwen-thai-text-corruption`). It also
ignores command contracts — asked to run `flutter analyze` + `flutter test` it
ran `flutter doctor` and returned a toolchain report
(`qwen-ignores-command-contracts`, and `phase6-handoff.md:97`).

So:

> **Qwen emits `path:line` pointers and identifiers. Never Thai text, never a
> file edit, never a verification run.**

Everything below is built to that shape. Each Qwen job is read-only, has a rigid
output format containing no Thai, and is verified by a cheap grep on this side
before a single line is acted on. That also sidesteps the other recorded trap —
"a Qwen sweep agreeing with yours means nothing if you both used the same
categories" — because Qwen is producing an *inventory*, not a *verdict*.

### Invoking it

`claude-9arm` is a **PowerShell 5.1 profile function**, invisible to the Bash
tool (Git Bash) and the PowerShell tool (pwsh). Both report `command not found`.
Expand it:

```
claude --settings ~/.claude-9arm.json --model=qwen3.6-35b-a3b -p "<prompt>" --allowedTools Read Glob Grep
```

- Run it via the **PowerShell tool**.
- `--allowedTools Read Glob Grep` only. No `Edit`, no `Write`, no `Bash` — these
  are read-only jobs and the flag list is what enforces that.
- Ignore the usual warnings: connectors disabled, "no stdin data received in
  3s", Advisor disabled.
- Add `> <scratchpad>/qwen-<label>.log 2>&1` with `run_in_background: true` to
  run Q1–Q3 in parallel; they are independent.

---

## Step 0 — commit the pending work (Claude, first thing)

Six commits, in this order. Each is analyze-clean and test-green on its own.

| # | Contents |
|---|---|
| 1 | `lib/src/ui/widgets/confirm_delete.dart` — shared `confirmDelete` + `DeleteButton` |
| 2 | asset edit/delete: `portfolios.dart`, `asset_sheet.dart`, `portfolios_screen_test.dart` |
| 3 | chart sheet: `asset_chart_sheet.dart`, `chart_sheet.dart`, `price_repository.dart`, `asset_chart_sheet_test.dart` |
| 4 | transaction delete: `transaction_sheet.dart`, `transactions_screen_test.dart` |
| 5 | liability edit/delete: `liability_sheet.dart`, `liabilities.dart`, `liabilities_screen_test.dart` |
| 6 | the cross-provider fix: `portfolios_notifier.dart`, `portfolios_notifier_test.dart`, plus `docs/` (both plans) + `tasks/T3.06.md` |

---

## The actual bug waiting — `overviewProvider` is invalidated by exactly one thing

`OverviewNotifier.build()` reads portfolios, assets, transactions **and**
liabilities to compute Net Worth. Grepping every `invalidate` in `lib/` returns
one caller for it:

```
lib/src/state/settings_notifier.dart:63:    ref.invalidate(overviewProvider);   // importFromJson only
```

So **every** mutation leaves the Overview hero stale — add an asset, record a
buy, pay down a liability, the Net Worth number does not move. The
`RefreshIndicator` at `overview.dart:267` hides it: pull-to-refresh papers over
the staleness, which is why no test and no manual pass ever caught it.

The current invalidation matrix, for reference:

| `_reload()` | invalidates |
|---|---|
| `PortfoliosNotifier` | `transactionsProvider` + self ← added this session |
| `TransactionsNotifier` | `portfoliosProvider` + self |
| `LiabilitiesNotifier` | self only |
| `SettingsNotifier` | self only |

Nobody touches `overviewProvider`. **Do not fix this from the table alone** —
confirm it with Q3 below first, then decide per notifier.

---

## Qwen work packages

Three independent read-only inventories. Launch all three, then verify.

### Q1 — design-affordance inventory ⭐ highest value

The reason this one pays: it is ~1,500 lines of design markdown that would
otherwise eat Claude context, and its output is pure `file:line`.

```
Read these five files and nothing else:
C:\Gits\porto-mobile\tasks\design-overview.md
C:\Gits\porto-mobile\tasks\design-portfolios.md
C:\Gits\porto-mobile\tasks\design-transactions.md
C:\Gits\porto-mobile\tasks\design-liabilities.md
C:\Gits\porto-mobile\tasks\design-settings.md

List every INTERACTIVE AFFORDANCE they specify — anything the spec says a user
taps, toggles, drags, or that opens/navigates somewhere. Include buttons, pills,
chips, rows described as tappable, cards described as tappable, toggles, and
pickers.

Output ONE LINE PER AFFORDANCE, this exact format, nothing else:

<design-file>:<line> | <screen-or-section> | <what it opens or does>

Rules:
- <screen-or-section> and <what it opens or does> must be ENGLISH ONLY.
- NEVER copy Thai characters into your output. If an affordance is named in
  Thai, give its file:line and describe it in English instead.
- One line per affordance. No headers, no summary, no totals, no commentary.
- Do not open any other file. Do not open any .html file.
```

**Verify before using:** pick 3 output lines at random, `Read` that exact
file:line, confirm the affordance is really there. Qwen once reported
`TOTAL: 48` for a ~35-line listing — that is why the prompt forbids totals.

**What it is for:** diff this list against what `lib/` actually wires. It is the
first audit category (*"widget class never constructed outside tests"*) run from
the design side instead of the code side, which is exactly the independence the
plan says a same-categories cross-check lacks.

### Q2 — widget-construction inventory

Split in two runs to stay well inside the 128k window (~2,750 lines of widgets,
~2,400 of screens).

**Q2a:**
```
List every class in every .dart file directly inside
C:\Gits\porto-mobile\lib\src\ui\widgets\
(skip any file ending in .g.dart or .freezed.dart).

For each PUBLIC class (name does not start with an underscore), search
C:\Gits\porto-mobile\lib\ for places that CONSTRUCT it — an occurrence of
`ClassName(` that is not its own declaration and not a `class ClassName`
declaration line.

Output ONE LINE PER CLASS, this exact format, nothing else:

<ClassName> | <file-where-declared>:<line> | <count> | <constructing-file:line>,<constructing-file:line>,...

If nothing constructs it, put 0 and the word NONE.
Do not search the test/ directory. Do not output Thai characters.
No headers, no summary, no totals.
```

**Q2b:** same prompt, `lib\src\ui\screens\` instead of `lib\src\ui\widgets\`.

**Verify:** for every line reporting `0 | NONE`, re-grep it yourself. Those are
the findings, and they are the ones worth being sure about. Expected known
answer: `BarChart` should come back 0 — it is deliberately unplaced (see
`next-session-plan.md`). If Q2a does **not** report `BarChart` as 0, the run is
untrustworthy; re-run it smaller.

### Q3 — provider-invalidation matrix

```
Read exactly these files:
C:\Gits\porto-mobile\lib\src\state\portfolios_notifier.dart
C:\Gits\porto-mobile\lib\src\state\transactions_notifier.dart
C:\Gits\porto-mobile\lib\src\state\liabilities_notifier.dart
C:\Gits\porto-mobile\lib\src\state\settings_notifier.dart
C:\Gits\porto-mobile\lib\src\state\overview_notifier.dart

For every method in these classes that WRITES (calls a repo method that
creates, saves, removes, adjusts, imports, or sets), report which providers it
invalidates — counting both its own `ref.invalidate*` calls and any it makes
via a helper such as `_reload()`.

Output ONE LINE PER WRITING METHOD, this exact format, nothing else:

<ClassName>.<methodName> | <file>:<line> | <invalidatedProvider>,<invalidatedProvider>,...

Use the literal identifier for each provider, e.g. portfoliosProvider,
transactionsProvider, liabilitiesProvider, overviewProvider, SELF for
ref.invalidateSelf(). Use NONE if it invalidates nothing.
No headers, no summary, no totals. No Thai characters.
```

**Verify:** the four `_reload()` bodies are 3 lines each — read them directly
and check Qwen's rollup. The known answer is the table above; if Qwen's matrix
disagrees, trust the file.

**What it is for:** the `overviewProvider` fix. The matrix tells you which
notifiers need the extra edge, so you fix the class of bug rather than one
instance.

---

## Claude-only work (do NOT delegate)

1. **The `overviewProvider` fix itself.** Which providers a mutation should
   invalidate is a correctness decision, and the edit sits one line from Thai
   copy in files Qwen must not touch.
2. **Its test.** Notifier-level against a real in-memory `AppDatabase`, modelled
   on `portfolios_notifier_test.dart` → `'deleteAsset invalidates
   transactionsProvider'`. **A widget test cannot see this bug** — every screen
   test overrides the notifier method itself, so `_reload()` never runs. Keep
   the provider alive with `container.listen(...)`; without it autoDispose
   rebuilds on the next read and the test passes for the wrong reason.
3. **Anything Q1/Q2 surfaces as a missing affordance.** Wiring a control is a
   design decision plus Thai copy.
4. **Every `flutter analyze` / `flutter test` run.**

---

## Still-open decisions, unchanged — do not re-find these

`BarChart` (kept, unplaced), `reorderPortfolios` (no design), `deletePortfolio`
(speculative scope). All three are recorded with reasons in
`next-session-plan.md`. If a Qwen inventory flags them, that is the inventory
working, not a new finding.

Also unchanged: dual-currency inline display stays deliberately not done
(`phase4-handoff.md:58`).

## Verify

```bash
export PATH="/c/src/flutter/bin:$PATH"   # Flutter 3.44.6 at C:\src\flutter, NOT on PATH
cd /c/Gits/porto-mobile
flutter analyze lib test integration_test   # must be clean
flutter test                                # 196 green at the start of the session
```

**Test-harness gotchas** (each has cost real time): the default 800×600 surface
is too short for Settings, the add sheet, and the new delete buttons — raise
`tester.view.physicalSize` to `Size(2400, 3600)`, **height only**, with
`addTearDown(tester.view.resetPhysicalSize)`. `find.text` is exact and the save
labels differ (`บันทึก` vs `บันทึกรายการ`). `find.widgetWithText` yields one
match per (ancestor, descendant) pair, so a row whose avatar glyph repeats its
title matches twice — target a unique trailing value instead.
