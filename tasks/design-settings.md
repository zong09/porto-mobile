# Design spec — Settings screen + Chart sheet (1b "Bold Hero")

> Screens: `Porto Mobile - 1b.dc.html` → "1b ตั้งค่า" (Settings). The **Chart sheet** is
> **extrapolated** (1b design is silent on it) from the hero sparkline + the web `ChartModal`.
> Covers plan **T3.09** (Settings + Chart sheet). See `design-components.md`. Device 402×874.

## Settings — Settings tab

### A. Gradient hero (`padding 68px 22px 20px`)
1. Title **"ตั้งค่า"** `font 22px/700`.
2. **On-device banner** (`margin-top 10px`): `background rgba(255,255,255,0.14); radius 16;
   padding 12px 14px`, row `gap 10px`: lock icon, then a column — `ไม่มีบัญชี ไม่ต้องล็อกอิน`
   `13.5px/700` + `ข้อมูลทั้งหมดเก็บในเครื่องของคุณเท่านั้น` `11.5px rgba(250,245,236,0.78)`.

### B. Cream sheet (`gap 11px`)
Three sections, each a `font 12px/700 color #A89A86` header + a `DividedCard` of rows
(row `padding 13px 0`, label `13.5px/600`, trailing `12.5px muted2` value or a toggle):

1. **ทั่วไป**
   - **สกุลเงินหลัก** → trailing `฿ THB ›` (opens THB/USD picker; drives `displayCurrency`).
   - **ธีม** → trailing `สว่าง ›` (light/dark — v1 may be light only; keep the row).
   - **ภาษา** → trailing `ไทย ›` (th/en; drives i18n).
2. **ความปลอดภัย**
   - **ปลดล็อกด้วย Face ID** → trailing **toggle** (components §4; shown ON `#177E81`).
   - **ซ่อนยอดเงินเมื่อเปิดแอป** → trailing **toggle** (shown OFF).
   (v1 scope note: these may be persisted-but-inert flags if biometrics aren't wired — keep the UI.)
3. **ข้อมูลของคุณ**
   - **สำรองข้อมูลลงไฟล์** (two-line: title + `ส่งออกทั้งหมดเป็นไฟล์เดียว…` `11px muted2`),
     trailing `›` → export DB→JSON via `BackupRepo` + `share_plus`/`file_picker`.
   - **นำเข้าข้อมูล** (`จากไฟล์สำรอง หรือ CSV`), trailing `›` → import JSON (file picker → restore).
   - **ลบข้อมูลทั้งหมด** — label + trailing `›` both `color #A8341C` (destructive; confirm dialog).
4. Footer: centered `11px muted2` `Porto 1.0 · ทำงานออฟไลน์ได้ 100%`.

### C. Bottom nav — Settings tab active.

## Chart sheet (price history) — T3.09

Opened from an asset row / asset detail (e.g. the featured-asset sparkline in Portfolio detail).
Bottom sheet (SheetShell), title = asset name + symbol (e.g. **"Bitcoin · BTC"**). Body:
1. Big current price `font 28px/700 tabular` + gain/loss pill (change over the selected range).
2. **AreaChart** (chart-sheet variant, components §6a): line `AppColors.brand`, brand fill gradient,
   ~160px tall, `showEndDot: true`.
3. **Range pills** (components §4, cream variant): crypto = `7D 30D 90D 1Y`; stock = `1M 3M 6M 1Y ALL`.
   Switching range refetches history via the price-history client (T1.13) / PriceRepository.
4. Optional stat row (high/low/avg cost) as small StatCards.
Loading = a shimmer/placeholder; offline/no-data = muted "ไม่มีข้อมูลราคาย้อนหลัง".

### T3.09 done-when (plan): "toggle + export/import picker test" — widget test against a fake
SettingsNotifier asserts (a) toggling **สกุลเงินหลัก** THB↔USD updates displayed state, and
(b) tapping **สำรองข้อมูลลงไฟล์** / **นำเข้าข้อมูล** invokes the backup export/import callbacks
(picker mocked). Chart sheet: pumping with a fixed history series renders the AreaChart without error
and range pills switch the active range.

## State mapping (SettingsNotifier + BackupRepo — CONTRACTS §13, confirm names in Stage 2)
displayCurrency/language/theme + security flags ← SettingsNotifier (persisted to `settings` kv table);
export/import ← BackupRepo (full DB ↔ JSON round-trip, T2.09).
