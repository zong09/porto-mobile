# Design spec — Transactions screen + Transaction form sheet (1b "Bold Hero")

> Screens: `Porto Mobile - 1b.dc.html` → "1b รายการ" (Transactions) and "1b ฟอร์มซื้อ" (Buy form).
> See `design-components.md`. Covers plan **T3.07** (Transactions + sheet). Device 402×874.

## Transactions (list) — Transactions tab

### A. Gradient hero (`padding 68px 22px 20px`)
1. Title **"รายการ"** `font 22px/700`.
2. Summary line `font 12.5px rgba(250,245,236,0.8)`, `margin-top 2px` — e.g.
   `ก.ค. 2026 · ซื้อ ฿86,400 · ขาย ฿32,000`.
3. **Filter pills** row (`margin-top 12px; gap 7px`, components §4): `ทั้งหมด · ซื้อ · ขาย · ฝาก/ถอน`
   (`ทั้งหมด` active). Maps to TxSide filter (all / buy / sell / deposit+withdraw).

### B. Cream sheet (`gap 11px`)
**Grouped by date.** Each group: a `font 12px/700 color #A89A86` header (`วันนี้`, `เมื่อวาน · 9 ก.ค.`,
or an absolute date), then a `DividedCard` of transaction rows. Each row (ListRowTile):
- Leading 38×38 rounded-square (`radius 12`) by side:
  - **buy** `↓` on `#DDF3F3`/`#177E81`
  - **sell** `↑` on `#FCDFD4`/`#A8341C`
  - **deposit** `＋` on `#FBEBD2`/`#B57F22`
  - **withdraw** `−` on `#F6E4EA`/`#A84E71`
  (icon `font 16px/700`).
- Middle: title `ซื้อ BTC` `14px/700`; subtitle `11px muted2` = `qty @ price · <portfolio>`.
- Trailing: signed amount `14px/700 tabular` — buy `−฿26,032` (default text color), sell/deposit
  `+฿…` colored `#177E81`; below it the time `11px muted2` (e.g. `09:12`).
- Tapping a row → edit that transaction (opens the form sheet in edit mode).

### C. Bottom nav — Transactions tab active.

## Transaction form (Buy / Sell / Deposit-Withdraw) — pushed route (not a sheet); T3.07

The design shows this as a full route with a thin gradient header, not a bottom sheet (it's long).

### A. Gradient header (`padding 64px 22px 18px`, row `gap 12px`)
32×32 circle back `‹`, then a column: title **"ซื้อสินทรัพย์"** (or ขาย / ฝาก / ถอน) `18px/700` +
subtitle `11.5px rgba(250,245,236,0.75)` = `บันทึกลงในเครื่อง · ไม่มีการส่งคำสั่งซื้อจริง`.

### B. Cream sheet (`radius 30 30 0 0; padding 20px 20px 40px; gap 14px`)
Form fields (label `12px/700 #8A7D6C`; white inputs `radius 16; padding 13px 15px`):
1. **สินทรัพย์** — asset selector card: 36×36 tinted symbol tile, name+symbol `14.5px/700`,
   `ราคาล่าสุด ฿…` `11px muted2`, trailing `เปลี่ยน ›` (→ asset picker). For deposit, this is the
   deposit account instead.
2. **จำนวน / ราคาต่อหน่วย** — 2-col grid. Amount input is focused-styled
   (`border 1.5px solid #EC6530`, a 2px brand caret bar), unit suffix right-aligned (`BTC` / `฿`).
   Price input shows `฿` suffix. (Values entered in the **display currency**, converted to native
   on save via `toNative`.)
3. **มูลค่ารวม** banner: `background #FFE9DB; radius 16; padding 12px 16px`, label left `12.5px/600
   #6B5D49`, total right `17px/700 #C24A1E tabular` = qty×price(+fee).
4. **เข้าพอร์ต** — segmented portfolio chips (components §4) incl. a `+ ใหม่` chip.
5. **วันที่ / ค่าธรรมเนียม (ถ้ามี)** — 2-col grid: date picker field (`13.5px/600`) and fee input
   (`฿` suffix, placeholder `0.00`).
6. **โน้ต (ไม่บังคับ)** — text input, placeholder `เช่น DCA ประจำเดือน…`.
7. Footer primary **บันทึกรายการ** — brand pill (`#EC6530`, white, `radius 999; padding 16;
   16px/700`), `margin-top auto`.

Sell form = same layout, title **"ขายสินทรัพย์"**, primary-action tint may shift to loss red; it
records realized P/L automatically (per PositionCalculator). Deposit/Withdraw form drops qty/price
for a single **amount** field + account + date.

### T3.07 done-when (plan): "grouped-list + form test" — widget test against a fake
TransactionsNotifier asserts (a) rows are grouped under date headers in order, and (b) the form
computes มูลค่ารวม = qty×price+fee and calls the notifier's add method with converted native values.

## State mapping (TransactionsNotifier — CONTRACTS §8/§11, confirm names in Stage 2)
Group-by-date + filter come from the notifier; the form uses `toNative`/`fromNative` (from T1.10
currency converter) to store in the asset's native currency.
