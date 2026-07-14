# Design spec — Overview screen (Porto Mobile, direction 1b "Bold Hero")

> Screen file: `Porto Mobile - 1b.dc.html` → "1b Overview". See `design-components.md` for the
> shared frame, bottom nav, cards, pills, and chart geometry. Device 402×874.

## Layout (top → bottom)

### A. Gradient hero (`padding 68px 22px 20px`, cream/white text, column `gap 4px`)

1. **Top bar row** (`align center; gap 8px`):
   - App mark 24×24 squircle (`radius 7`, brand gradient, inset ring) with a mini 16px conic donut +
     tiny `P` bottom-right. Then wordmark **Porto** `font 14px/700`.
   - `margin-left:auto` → two right chips: (a) **"ในเครื่อง"** (on-device) — `font 11px`,
     `background rgba(255,255,255,0.16)`, `radius 999`, `padding 3px 11px`, a small lock glyph before
     the text; (b) **currency chip** `฿ THB` — `font 11.5px/700`, same bg, `padding 3px 12px`.
2. **"Net Worth"** label `font 13px color rgba(250,245,236,0.75)`, `margin-top 14px`.
3. **Net-worth value** `font 46px/700 #FFFFFF tabular-nums`, `letter-spacing -0.015em`, `line-height 1.1`.
4. **Change row** (`align center; gap 8px; margin-top 6px`): gain pill `▲ +฿312,480` (see components §4)
   + secondary text `font 12px color rgba(250,245,236,0.8)` → `+7.86% · วันนี้ +฿18,240`.
5. **Area chart** (AreaChartPainter hero variant): full width, `margin-top 12px`, ~74px tall,
   white line + `rgba(255,255,255,0.14)` fill + end dot. **← T3.01 golden reference.**
6. **Timeframe pills**: `1D 1W 1M 1Y ALL`, `gap 7px; margin-top 8px` (components §4, `1D` active).

### B. Cream sheet (`radius 30 30 0 0; padding 20 20 110; gap 13px`)

1. **Stat trio** — row `gap 9px` of 3 StatCards (components §3): **Assets** `฿4.67M`,
   **Liabilities** `฿384.7K` (value color `#A8341C`), **กำไรรวม** `+7.86%` (value color `#177E81`).
   → Tapping the **Liabilities** card navigates to the Liabilities screen (T3.08).
2. **Section header** row: **"พอร์ตของฉัน"** `font 15px/700` + `margin-left:auto` **"ดูทั้งหมด"**
   `font 12px/700 color #EC6530` (→ Portfolios tab).
3. **Portfolio list card** — one `PlainCard` in divided-row mode (`padding 4px 15px`, each row
   `padding 12px 0` + `1px #F5EDDE` bottom border except last). Each **ListRow** (components §3):
   - Leading 40×40 rounded-square (`radius 13`) tinted avatar holding an 18px conic **donut**.
   - Middle: portfolio name `14px/700` + subtitle (member symbols) `11px color #A89A86`.
   - Trailing: value `14px/700 tabular-nums` + %-change `11px/700` gain/loss colored.
   - Example rows: `Crypto หลัก / BTC·ETH·SOL / ฿1,842,300 / +12.4%`, `หุ้นไทย`, `หุ้น US`,
     `กองทุน + เงินฝาก`.

### C. Bottom nav — floating capsule, Overview tab active (components §1).

## Add sheet (opened by the center FAB) — spec for T3.05/T3.07

Bottom sheet (SheetShell, components §2), title **"เพิ่มรายการ"** + close ✕. Behind it the screen
is blurred (`blur(2px) opacity .55`) under a `rgba(41,28,18,0.45)` scrim.

- **2×2 action grid** (`display grid; 1fr 1fr; gap 10px`), each cell a white card
  (`radius 18; padding 16px 15px; gap 8px`): a 38×38 tinted icon square, a `14px/700` title, an
  `11px #A89A86` subtitle:
  - **ซื้อสินทรัพย์** — icon `↓` on `#DDF3F3`/`#177E81`; sub "หุ้น คริปโต กองทุน ทอง"
  - **ขายสินทรัพย์** — icon `↑` on `#FCDFD4`/`#A8341C`; sub "บันทึก Realized P/L อัตโนมัติ"
  - **ฝาก / ถอนเงิน** — icon `＋` on `#FBEBD2`/`#B57F22`; sub "เงินฝาก บัญชีออมทรัพย์"
  - **เพิ่มหนี้สิน** — icon `−` on `#F6E4EA`/`#A84E71`; sub "สินเชื่อ บัตรเครดิต ผ่อนชำระ"
- **Local-data note** below: `background #FFE9DB; radius 16; padding 12px 16px`, `font 12px #6B5D49`,
  with "ในเครื่องของคุณ" emphasized `700 #C24A1E`.

## First-run onboarding (spec for T3.05 empty-state / T4.1)

Full-gradient screen, centered column: 84×84 rounded-square glass tile with a 44px conic donut;
wordmark **Porto** `34px/700`; tagline `16px rgba(250,245,236,0.88)` two lines; two feature cards
(`rgba(255,255,255,0.12); radius 18; padding 14px 16px`) — "ไม่มีบัญชี ไม่ต้องล็อกอิน" (lock icon)
and "ข้อมูลอยู่ในเครื่องคุณเท่านั้น" (phone icon), each with a `12px` subtitle; primary CTA
**"เริ่มใช้เลย"** (cream pill, `#C24A1E` text) + text link **"นำเข้าจากไฟล์สำรอง"**.

## State mapping (T3.05, OverviewNotifier — see CONTRACTS §12)
- Net worth / change / area series / stat trio ← `OverviewState` (totals, todayPl, history series).
- Portfolio list ← per-portfolio rollup. Offline → show an "as of <time>" banner (plan T3.05
  done-when: "offline banner"): a thin pill/bar using `#FFE9DB`/`#C24A1E` text under the hero.
