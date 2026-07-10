# Porto Mobile App — Kotlin Multiplatform Plan (Local-First)

Goal: **standalone** native mobile app. All user data — portfolios, assets, transactions,
liabilities, net-worth history — stored **on-device** in SQLDelight. No account, no login,
no backend at runtime. Network is used **only** to fetch live prices + FX; without network
the app is fully usable with last-cached prices.

**All logic lives in KMP `shared`** (models, local DB, price clients, position math,
net-worth aggregation, currency/format, ViewModels). Android UI = Jetpack Compose.
iOS UI = SwiftUI consuming shared ViewModels via SKIE.

The existing `backend/` is **not a runtime dependency** — it is the reference
implementation whose logic gets ported (position math, net-worth summary, price fetching).

The plan is contract-first: Phase 0 produces frozen contracts (DB schema, ViewModel
interfaces, design tokens) so later tasks can be executed **independently and in parallel
by small models**, each with explicit deps, files, and done-criteria.

---

## 1. Architecture decisions

| Decision | Choice | Why |
|---|---|---|
| Repo location | **new separate repo `porto-mobile`** (folder `~/Gits/porto-mobile`) | independent release cycle; reference logic from `porto` is copied in at T0.1 (see below) |
| Data storage | SQLDelight in `shared` — single source of truth | requirement: all data on-device |
| Schema shape | mirror backend entities (UUID ids, same columns, `NUMERIC`→`REAL`, dates `YYYY-MM-DD` TEXT) | logic ports 1:1; future backend-sync stays possible |
| Prices | direct from source: Binance (crypto), Yahoo Finance w/ crumb auth (TH/US stocks, `THB=X` FX) — port `prices.service.ts` | no server to host; fallback chain → cached price → manualPrice → avgCost |
| Price cache | in-memory TTL (60s crypto / 90s stocks / 60s FX) + last-known persisted in DB (`price_cache` table) | offline shows "as of \<time\>" |
| Networking | Ktor client + kotlinx.serialization | standard KMP |
| ViewModels | shared `androidx.lifecycle:lifecycle-viewmodel` (KMP) + `StateFlow` | Compose consumes directly; SwiftUI via SKIE |
| iOS interop | **SKIE** | Flow → AsyncSequence, sealed class → Swift enum |
| DI | Koin | KMP support, lightweight |
| Charts | Compose Canvas / SwiftUI Canvas, hand-drawn | web uses custom SVG — mirror that |
| Min targets | Android minSdk 26, iOS 16 | SwiftUI Canvas + modern APIs |

Out of scope v1: auth/accounts, backend sync, multi-device, backup/restore to server.
In scope as cheap wins: **export/import JSON file** (device backup — data lives only on the
phone, user needs an escape hatch), TH/EN strings (reuse `frontend/src/store/translations.ts`).

## 2. Module layout

```
porto-mobile/                     ← new git repo
  PLAN.md                         ← this plan, copied over at T0.1
  CONTRACTS.md                    ← frozen contracts (T0.1)
  reference/                      ← read-only copies from porto repo (T0.1):
                                    position.service.ts (+spec), net-worth.service.ts,
                                    prices.service.ts, liabilities.service.ts,
                                    seed.service.ts, tailwind.config.js, translations.ts
  settings.gradle.kts, gradle/libs.versions.toml
  shared/
    src/commonMain/sqldelight/app/porto/db/Porto.sq   ← schema + queries
    src/commonMain/kotlin/app/porto/shared/
      model/      domain types + enums (kotlinx.serialization for export/import)
      db/         DriverFactory (expect/actual), DAO wrappers
      prices/     BinanceClient, YahooClient (crumb), FxProvider, PriceRepository
      domain/     PositionCalculator, NetWorthCalculator, CurrencyConverter, Formatters
      repo/       PortfolioRepository, AssetRepository, TransactionRepository,
                  LiabilityRepository, NetWorthHistoryRepository, BackupRepository
      vm/         OverviewViewModel, PortfoliosViewModel, TransactionsViewModel,
                  LiabilitiesViewModel, SettingsViewModel
      di/         Koin modules
    src/commonTest/kotlin/...
  androidApp/     Compose UI only
  iosApp/         SwiftUI UI only (Xcode project)
```

## 3. Data contract (source of truth: backend entities — port, don't redesign)

Tables (all ids TEXT UUID, generated on-device; dates TEXT `YYYY-MM-DD`):

| Table | Columns (from backend entity) |
|---|---|
| `portfolios` | id, name, color INT (0–5), sortOrder INT |
| `assets` | id, portfolioId FK CASCADE, type, symbol, name, currency, cgId?, yahooSymbol?, manualPrice REAL?, direction, sortOrder |
| `transactions` | id, assetId FK CASCADE, side, quantity REAL, price REAL, fee REAL, date, createdAt |
| `liabilities` | id, name, amount REAL, currency |
| `liability_transactions` | id, liabilityId FK CASCADE, type, amount REAL, date, createdAt |
| `net_worth_history` | date PK, totalAssetsThb REAL, totalLiabilitiesThb REAL, netWorthThb REAL, fxRate REAL |
| `price_cache` | key PK (e.g. `crypto:BTC`, `stock:AAPL`, `fx`), price REAL, chg24h REAL, currency, fetchedAt |
| `settings` | key PK, value (displayCurrency THB\|USD, ฯลฯ) |

Enums (freeze in `model/`): `AssetType = crypto|th|us|fund|deposit`, `Currency = THB|USD`,
`TxSide = buy|sell|deposit|withdraw`, `Direction = long|short`, `LiabilityTxType = pay|add`.

Validation rules port from backend DTOs: quantity/amount > 0, price/fee ≥ 0, name non-empty,
portfolio color 0–5. Enforce in repositories (no server to catch it now).

## 4. Logic to port from backend (reference files)

Paths below are the originals in the `porto` repo; T0.1 copies each into
`porto-mobile/reference/` so dispatched tasks never need a `porto` checkout.

| Shared component | Port from | Notes |
|---|---|---|
| `PositionCalculator` | `backend/src/position/position.service.ts` | long & short branches, date sort, 1e-9 reset; tests from its `.spec.ts` |
| `NetWorthCalculator` | `backend/src/net-worth/net-worth.service.ts#getSummary` | pure function: (assets+txs, liabilities, prices, fx) → `{totalAssetsThb, totalLiabilitiesThb, netWorthThb, todayPlThb, totalCostThb, fx}`; deposit price=1, fund uses manualPrice, short subtracts, 24h P&L formula |
| Snapshot upsert | same file `#recordSnapshot` | upsert by date into `net_worth_history`, run after each successful price refresh |
| `BinanceClient` | `backend/src/prices/prices.service.ts` | batch ticker first → per-symbol fallback |
| `YahooClient` | same file | direct → on 401 fetch crumb from `query2.finance.yahoo.com/v1/test/getcrumb` → retry; TH stocks append `.BK`; FX from `THB=X` |
| Price fallback chain | `net-worth.service.ts` catch-block | live → `price_cache` last-known → manualPrice → avgCost |
| Liability adjust | `backend/src/liabilities/liabilities.service.ts#adjust` | pay decrements / add increments amount + writes liability_transaction, atomically |

## 5. Execution plan — phases & parallel tasks

Legend: **Deps** = must be merged first. **Files** = only files the task may touch.
**Done-when** = merge criteria. Tasks in the same phase run **in parallel**.

### Phase 0 — Scaffold & contracts (sequential, 1 task, do first)

**T0.1 New repo scaffold + frozen contracts**
- Create git repo `porto-mobile` at `~/Gits/porto-mobile` (default branch `main`).
- Files: Gradle KMP project (shared + androidApp skeleton + iosApp Xcode skeleton),
  version catalog (Kotlin, SQLDelight, Ktor, kotlinx-serialization, coroutines, Koin, SKIE),
  empty Koin wiring, CI task `./gradlew :shared:allTests`.
  Copy this plan → `PLAN.md`; copy §4 reference files + `position.service.spec.ts`,
  `frontend/tailwind.config.js`, `frontend/src/store/translations.ts` from `porto` →
  `reference/` (verbatim, read-only).
  Plus `CONTRACTS.md`: §3 schema + enums + §4 port table + ViewModel interface
  signatures (state data classes + intents per screen, defined here once).
- Done-when: `./gradlew :shared:allTests :androidApp:assembleDebug` passes; iosApp builds an
  empty SwiftUI screen linking `shared`.

### Phase 1 — Foundations (6 tasks, all parallel after T0.1)

**T1.1 DB schema + DAOs** — Deps: T0.1
- Files: `shared/.../Porto.sq`, `db/DriverFactory` (expect/actual android+ios), thin DAO
  wrappers returning Flows.
- Done-when: commonTest (in-memory driver) covers CRUD per table, FK cascade delete
  (portfolio→assets→transactions), reorder updates, snapshot upsert-by-date.

**T1.2 Price clients** — Deps: T0.1
- Files: `prices/BinanceClient.kt`, `YahooClient.kt`, `FxProvider.kt`, `ApiError.kt`.
  Port per §4. Ktor MockEngine tests: batch→fallback, crumb 401 retry flow, `.BK` suffix,
  FX parse.
- Done-when: tests green + one integration test against real endpoints (tagged, excluded
  from CI).

**T1.3 Position calculator** — Deps: T0.1 (pure math)
- Files: `domain/PositionCalculator.kt` + tests.
- Done-when: every case in `position.service.spec.ts` ported + long/short golden cases.

**T1.4 Net-worth calculator** — Deps: T0.1 (pure; takes T1.3's interface from CONTRACTS.md)
- Files: `domain/NetWorthCalculator.kt` + tests.
- Done-when: golden test — feed the sample dataset from `backend/src/seed/seed.service.ts`
  with fixed prices/fx, output matches backend `getSummary` for the same input (compute
  expected values once by running the backend locally, hardcode into the test).

**T1.5 Currency & formatting** — Deps: T0.1
- Files: `domain/CurrencyConverter.kt`, `Formatters.kt` — native→THB multiplier, dual-currency
  display values, USD strictly 2 decimals, THB grouping, percent, compact quantity
  (per CLAUDE.md "Currency Display").
- Done-when: golden table matches web output for ~20 sample values.

**T1.6 Design tokens ×2** — Deps: T0.1
- Files: `androidApp/.../theme/` (Compose) + `iosApp/.../Theme.swift` — from
  `frontend/tailwind.config.js`: surface `#FAF5EC`, dark `#3d3328`, primary `#b45a3c`,
  muted `#8a7d6c`, positive/negative + bg variants, Anuphan font bundled.
- Done-when: both compile; token-preview screen renders all colors/typography.

### Phase 2 — Repositories + ViewModels, per domain (5 tasks, parallel)

Each = repository over DAOs (+ validation per §3) + ViewModel(s) implementing CONTRACTS.md
interfaces + commonTest with in-memory DB / fake price source.

- **T2.1 Portfolios & Assets** — Deps: T1.1; uses T1.3/T1.5. CRUD + reorder,
  `PortfoliosViewModel` (portfolio cards with per-asset positions & values).
- **T2.2 Transactions** — Deps: T1.1; uses T1.5. CRUD, `TransactionsViewModel` (list grouped
  by date, add/edit form state, native-currency entry conversion).
- **T2.3 Liabilities** — Deps: T1.1. CRUD + atomic pay/add adjust, `LiabilitiesViewModel`.
- **T2.4 Prices & Net-worth** — Deps: T1.1, T1.2, T1.4. `PriceRepository` (TTL cache →
  `price_cache` persist → fallback chain), refresh orchestration → `NetWorthCalculator` →
  snapshot upsert, `OverviewViewModel` (summary cards, donut data, history chart data,
  "as of" staleness flag).
- **T2.5 Settings & Backup** — Deps: T1.1. Display-currency setting, `BackupRepository`
  export/import full DB ↔ JSON (kotlinx.serialization; import = validate then replace-all
  in transaction), `SettingsViewModel`.
- Done-when (each): ViewModel commonTests cover load/refresh/error/mutation → state
  transitions; repository tests on in-memory DB.

### Phase 3 — UI screens (10 tasks: 5 screens × 2 platforms, all parallel; Deps: T1.6 + owning T2.x)

Screens (mirror `frontend/src/pages/`, minus Login): Overview (summary + area chart +
donut), Portfolios (cards + asset rows + Asset sheet), Transactions (list + Transaction
sheet), Liabilities (list + adjust sheet), Settings (currency toggle, export/import file
pickers, language).

- Android A3.1–A3.5: Compose, one screen each; A3.1 (Overview) owns bottom-nav scaffold.
- iOS I3.1–I3.5: SwiftUI, one screen each via SKIE (`for await state in vm.state`);
  I3.1 owns TabView shell.
- Done-when (each): renders against preview/fake VM state; screenshot attached;
  loading/error/empty + offline "as of" state handled; charts drawn with Canvas where present.

### Phase 4 — Integration & hardening

- **T4.1 Wire-up** (Deps: all P3): final Koin graph, DB driver init, refresh-on-foreground,
  snapshot after refresh.
- **T4.2 Smoke test** (Deps: T4.1): scripted UI run — create portfolio → asset (crypto BTC +
  TH stock) → buy tx → Overview totals match `NetWorthCalculator` unit expectation; kill
  app → relaunch offline → data + last prices still shown.
- **T4.3 Polish** (Deps: T4.2): dual-currency secondary styling (`0.72em`-equivalent),
  pull-to-refresh, error toasts, app icon (reuse set in `frontend/public/`), export/import
  round-trip test.

## 6. Dependency graph (concurrency)

```
T0.1 ──► T1.1  T1.2  T1.3  T1.4  T1.5  T1.6      (6 in parallel)
T1.x ──► T2.1  T2.2  T2.3  T2.4  T2.5            (5 in parallel)
T1.6+T2.x ──► A3.1–A3.5, I3.1–I3.5               (10 in parallel)
all P3 ──► T4.1 ──► T4.2 ──► T4.3
```

Max concurrency: 6 → 5 → 10. Total 24 tasks.

## 7. Rules for dispatched (small-model) tasks

1. **Contract is law**: implement exactly the schema/interfaces in `CONTRACTS.md`;
   never rename or "improve" them. Contract changes go through the orchestrator only.
2. **Port, don't redesign**: where §4 names a backend reference file, match its behavior
   exactly — including edge cases (1e-9 reset, short subtraction, crumb retry).
3. **Stay in your files**: each task lists its file paths; touch nothing else.
4. **Done = tests green**: every shared task ships commonTest; every UI task ships a
   preview/screenshot. `./gradlew :shared:allTests` must pass before merge.
5. Tasks run inside the `porto-mobile` repo only — the `porto` repo is not available;
   all porting references live in `reference/` (read-only, never modify).
6. One branch per task (`task/T2.2-transactions`), merged by orchestrator in phase order.
