# Design spec — Portfolios screen + Portfolio detail + Asset sheet (1b "Bold Hero")

> Screens: `Porto Mobile - 1b.dc.html` → "1b พอร์ต" (list) and "1b Portfolio detail". See
> `design-components.md` for frame/nav/cards/pills/donut/allocation-bar. Device 402×874.
> Covers plan **T3.06** (Portfolios + Asset sheet).

## Portfolios (list) — Portfolios tab

### A. Gradient hero (`padding 68px 22px 22px`)
1. Title row: **"พอร์ตของฉัน"** `font 22px/700` + `margin-left:auto` create button
   `+ สร้างพอร์ต` — cream pill `background rgba(255,255,255,0.92) color #C24A1E`, `font 11.5px/700`,
   `padding 5px 14px`, `radius 999` (→ opens create-portfolio sheet).
2. Label **"มูลค่าการลงทุนรวม"** `font 13px rgba(250,245,236,0.75)`, `margin-top 10px`.
3. Total value `font 38px/700 #FFFFFF tabular-nums`.
4. **Allocation bar** (components §5) `margin-top 14px` + legend row (Crypto/หุ้นไทย/หุ้น US/กองทุน %).

### B. Cream sheet (`gap 11px`)
Per portfolio, a `PlainCard` (`padding 15px 16px`) as a **ListRowTile**:
- Leading 42×42 rounded-square (`radius 14`) tinted avatar with a 20px conic donut.
- Middle: name `14.5px/700` + subtitle `11px muted2` = `{n} สินทรัพย์ · กำไร +฿…`.
- A tinted **% chip** (components §4) right after the middle block (e.g. `43%`), `flex-shrink:0`.
- Trailing column: value `15px/700 tabular` + %-change `11px/700` gain/loss.
- Tapping a card → **Portfolio detail**.
Then a **dashed "create new" card**: `border 1.5px dashed #D9CBB4; radius 18; padding 13px 16px`,
centered `+ สร้างพอร์ตใหม่` `font 12.5px/700 color #A89A86`.

### C. Bottom nav — Portfolios tab active.

## Portfolio detail (sub-route, pushed from a list card or Overview)

### A. Gradient hero (`padding 68px 22px 22px`)
1. Row: 32×32 circle back button (`rgba(255,255,255,0.16)`, glyph `‹`), portfolio name `14px/700`,
   `margin-left:auto` **"แก้ไข"** chip (`rgba(255,255,255,0.16)`, `11.5px/700`, `padding 3px 12px`).
2. Value `font 40px/700 #FFFFFF tabular`, `margin-top 12px`.
3. Change row: gain pill `▲ +12.4%` + secondary `ต้นทุน ฿… · กำไร +฿…`.
4. **Allocation bar** (`margin-top 16px`) + per-asset legend (`BTC 50% · ETH 26% · SOL 24%`).

### B. Cream sheet (`gap 12px`)
1. Section **"สินทรัพย์ในพอร์ต"** `15px/700`.
2. **Featured asset card** (first/expanded): `PlainCard` column `gap 8px`:
   - ListRowTile-like header (38×38 tinted symbol tile e.g. `BTC` on `#FFE9DB`/`#C24A1E`; name
     `14px/700`; subtitle `qty @ price`; trailing value + %-change).
   - A row **sparkline** (AreaChart row variant, ~34px tall, gain/loss color).
   - Two action buttons row (`gap 8px`): **ซื้อเพิ่ม** (`background #DDF3F3 color #177E81`) and
     **ขาย** (`background #FCDFD4 color #A8341C`), each `flex:1; padding 9px 0; radius 999;
     font 12.5px/700; center`. → open Buy / Sell form (design-transactions.md).
3. **Remaining assets** in a `DividedCard` (ETH, SOL rows as ListRowTile).
4. **Realized P/L banner**: `background #FFE9DB; radius 18; padding 13px 16px`, text `12.5px #6B5D49`
   with `Realized P/L ปีนี้ +฿…` emphasized `700 #C24A1E`, trailing `›` (→ Transactions filtered).

### C. Bottom nav present (Portfolios tab active).

## Asset sheet (add / edit asset) — T3.06

Bottom sheet (SheetShell, title **"เพิ่มสินทรัพย์"** / **"แก้ไขสินทรัพย์"**). Fields (cream, per
components form styling — label `12px/700 #8A7D6C`, white input `radius 16; padding 13px 15px`):
- **ประเภท** (AssetType) segmented chips: `คริปโต · หุ้นไทย · หุ้น US · กองทุน · เงินฝาก`
  (crypto/th/us/fund/deposit). Selected chip = `#3D3328`/`#FAF5EC`.
- **สัญลักษณ์ (symbol)** text input + **ชื่อ (name)** text input.
- **สกุลเงิน (currency)** segmented `฿ THB · $ USD`. **Locked after create** — on edit render it
  disabled/greyed with a note "ล็อกหลังสร้างแล้ว". Defaults: crypto/us → USD, th/fund/deposit → THB.
- Optional: **manualPrice** (fund/deposit/manual) input; **cgId / yahooSymbol** advanced inputs
  (collapsible "ขั้นสูง").
- Footer primary button **บันทึก** (brand pill). Validation (repo-enforced, mirror inline):
  name non-empty; symbol matches `^[A-Za-z0-9.\-^=]{1,15}$`.

### T3.06 done-when (plan): "currency-locked-after-create test" — the widget test drives the Asset
sheet in edit mode against a fake Assets/PortfoliosNotifier and asserts the currency control is
disabled (cannot change), and create mode allows choosing it.

## State mapping (PortfoliosNotifier — CONTRACTS §8/§10, confirm exact names in Stage 2)
List/detail values, per-portfolio rollups, allocation slices ← notifier state; mutations
(create/edit portfolio, add/edit asset) call the repo then `ref.invalidateSelf()`.
