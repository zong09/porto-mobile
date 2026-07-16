# Handoff — Porto Mobile (Flutter) Phase 4 (integration & hardening)

**Date:** 2026-07-16
**Task:** "ทำเฟส 4 ต่อเลย" — finish Phase 4 of `mobile-app-plan-flutter.md` (T4.1 wire-up was already committed in a prior session; this session did the T4.1 bug-fix + T4.2 + T4.3).
**Status:** ✅ **Phases 0–4 ALL complete & verified.** Full suite **149 tests green**, `flutter analyze lib test` clean.

**Repos / paths (this is a Windows machine — `zong0`):**
- Flutter app repo: `C:\Gits\porto-mobile` (Flutter, default branch `main`)
- Plan doc: `C:\Gits\porto\docs\mobile-app-plan-flutter.md` (Phase 4 = §5 "Phase 4", Claude-owned)
- Contracts: `C:\Gits\porto-mobile\CONTRACTS.md`
- Prior handoff: `C:\Gits\porto\docs\porto-mobile-phase1-handoff.md`

**Toolchain (see also the `porto-mobile-windows-env` memory):**
- Flutter SDK at `C:\src\flutter` (3.44.6 / Dart 3.12.2) — **NOT on PATH**; prepend per shell: `export PATH="/c/src/flutter/bin:$PATH"` (Git Bash).
- Qwen dispatch (`claude-9arm`) works — expand to `claude --settings ~/.claude-9arm.json --model=qwen3.6-35b-a3b -p "..." --allowedTools Bash Read Edit Write Glob Grep` (the bare alias is invisible to the Bash/PowerShell tools; dispatch via the **PowerShell** tool).

---

## What is DONE this session (commits on `main`, porto-mobile)

| Commit | Task | Notes |
|---|---|---|
| `6008b7f` | **T4.1 bug-fix** | T4.1 (`ca6edf2`) left a **compile error**: `overview.dart` passed `onOpenLiabilities` to `_hero` (which doesn't declare it). The callback belongs on `_statRow` (holds the tappable Liabilities StatCard). The memory's "analyze clean" was stale — the real baseline was BROKEN. Fixed → analyze clean. |
| `7ecde4b` | **T4.2 smoke test** | End-to-end flow, verified green. |
| `c627704` | **T4.3** | Offline-FX fallback + pull-to-refresh (+ tests). |
| `40754fb` | **T4.3** | App launcher icon (Android + iOS). |

### T4.2 — end-to-end smoke test → `test/smoke_test.dart`
- **Deliberately a headless full-app widget test, NOT `integration_test/`.** This env has no Android emulator / no `adb`, and the repo has only `android`+`ios` platform dirs (no desktop/web runner), so on-device `integration_test` cannot run or be verified here. (User was asked and chose the headless route over adding a windows runner.)
- Drives the **real `PortoApp`** over the **real provider graph + a real on-disk SQLite DB**; only the Binance/Yahoo price clients are mocked (mocktail).
- Verifies: create portfolio → asset (crypto BTC + TH stock) → buy tx, and the rendered Overview **Net Worth == `NetWorthCalculator`**; then **kill → relaunch offline** (same db file, clients throw, clock advanced past the 60/90s cache TTL) → data + last-known cached prices still shown + the **"as of" offline banner** appears (live→cache fallback chain genuinely exercised).
- Run: `flutter test test/smoke_test.dart`.

### T4.3 — offline-FX fallback → `lib/src/state/overview_notifier.dart` (`fetchFxCached`)
- **Fixed a real offline-breaking bug:** `fxProvider` called `YahooClient(Dio()).getFxRate()` directly, so relaunching **offline threw** inside `OverviewNotifier.build` and Overview rendered an **error screen** instead of cached data — contradicting the app's core "usable offline" promise.
- Now: on success caches FX to `price_cache['fx']`; on failure returns the last cached rate; rethrows **only** on first-run-offline (never cached). Tested in `test/fx_cache_test.dart`.

### T4.3 — pull-to-refresh → `lib/src/ui/screens/overview.dart`
- `RefreshIndicator` wrapping the Overview scroll view → `overviewProvider.refresh()`. Tested in `test/overview_screen_test.dart`.

### T4.3 — launcher icon (delegated to Qwen, verified by Claude)
- `flutter_launcher_icons` from `porto/frontend/public/porto-1024.png` → `assets/icon/app_icon.png`; config in `pubspec.yaml`. Generated all 5 Android mipmap densities + the iOS AppIcon set. Simple config (no adaptive icon) for robustness.
- Verified: source copy byte-identical (555,374 B), all icon files present, analyze clean, 149-green suite.

### T4.3 — export/import round-trip test
- Already covered by **T2.09** (`test/settings_backup_test.dart:52` `BackupRepo export / import round-trip`). No new code needed.

---

## What is NOT done — follow-ups (each is a separate task, not Phase-4 polish)

1. **Display-currency toggle is not wired to reformat values.** `Formatters.money` **ignores its `currency` argument** — every money value renders THB-style (`฿`) regardless of `displayCurrency`. Settings has the THB↔USD picker (`สกุลเงินหลัก`) driving `displayCurrency`, but nothing converts/reformats on the screens. This is the real "currency switch" feature implied by design 1b. Scope: extend `Formatters` + a display-currency-aware money widget, convert THB↔USD via `fx`, swap `฿`/`$` prefix, thread `displayCurrency` into every money render.

2. **Dual-currency (USD+THB inline) — DELIBERATELY NOT DONE.** Design review of `tasks/design-*.md` shows mobile design **1b is THB-primary with a single display-currency toggle** — there is **no** dual inline display (the `0.72` in the design is opacity ranks, not currency). The plan's "dual-currency secondary styling (0.72em)" is a **web-app carry-over the mobile design contradicts.** Do not implement unless the design changes.

3. **On-device integration test.** `test/smoke_test.dart` covers the flow headlessly. If you want a true on-device `integration_test/` run (for CI or a real phone), it needs either an Android emulator/device or adding a platform runner. The headless test can be ported to `integration_test/app_test.dart` (add `integration_test:` sdk dev-dep + `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`) when a device is available.

4. **Thai UI copy has mojibake.** Several strings written by Qwen in Phase 3 are corrupted, e.g. in `lib/src/ui/app_shell.dart` (`ซื้้อสินทรพย์`, `ขายสินทรพย์`, `เพิ่่มหน้สิน`, `ข้อมลอย่ในเครื่องของคณ`) and `lib/src/ui/screens/overview.dart` (`ในเครื่่อง`, `พอรต์ของฉน`, `ดทู้งหมด`, `เริ่้มใช้เลย`, `วันนนี้`). A proofreading pass against `frontend/src/store/translations.ts` (or the design specs) would fix these. Left untouched this session (out of scope / surgical-changes discipline).

---

## How to build / run / test (Windows)

```bash
# always prepend Flutter to PATH first (Git Bash), from the repo root
export PATH="/c/src/flutter/bin:$PATH"
cd /c/Gits/porto-mobile

flutter pub get
flutter analyze lib test        # must be clean
flutter test                    # full suite → 149 green
flutter test test/smoke_test.dart   # the T4.2 end-to-end smoke flow

# codegen (after editing freezed/drift/riverpod-annotated files)
dart run build_runner build --delete-conflicting-outputs
```

- No emulator/adb here → cannot `flutter run` on Android in this env; `flutter devices` shows only windows/edge, which this mobile-only project can't target.

## Gotchas this session
- **Baseline was broken, not clean** — always run `flutter analyze lib test` for the *real* state; a stale "analyze clean" in memory was wrong. (Also: a backgrounded analyze that's still doing `pub get` can report exit 0 with empty output — re-run and read the tail.)
- **Bash tool cwd persists** within this session (unlike the PowerShell tool, which resets to `C:\Gits\porto\docs`). Still prefer absolute paths / chain `cd` in each command.
- **`flutter test integration_test/…` demands a device** and fails here ("No supported devices") — that's why T4.2 lives in `test/`.
- **Qwen** for launcher icon worked but always **verify its output yourself** (checked byte-identical source, generated files, build).

## Suggested skills for the next session
- **andrej-karpathy-skills:karpathy-guidelines** — surgical changes, verify each done-when.
- **qwen-agent** — for mechanical/bounded tasks (e.g. the Thai-copy proofread could be delegated with an explicit before/after string list).
- **verify / run** — drive the change end-to-end (once a device/emulator exists).
