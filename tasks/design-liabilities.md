# Design spec — Liabilities screen + Adjust sheet (1b "Bold Hero")

> **The 1b design has no dedicated Liabilities screen** (the tab bar is Overview/Portfolios/＋/
> Transactions/Settings, and "เพิ่มหนี้สิน" is one of the Add-sheet actions). This screen is
> **extrapolated** from the 1b visual language + the web app's `LiabilityModal`/Liabilities page.
> Reached as a **sub-route** by tapping the **Liabilities** stat card on Overview. Covers plan
> **T3.08** (Liabilities + adjust sheet). See `design-components.md`. Device 402×874.

## Liabilities (list) — sub-route (back to Overview)

### A. Gradient hero (`padding 68px 22px 22px`)
1. Row: 32×32 circle back `‹`, title **"หนี้สิน"** `font 22px/700`, `margin-left:auto`
   `+ เพิ่มหนี้สิน` cream pill (`rgba(255,255,255,0.92) color #C24A1E`, `11.5px/700`, `padding 5px 14px`).
2. Label **"หนี้สินรวม"** `13px rgba(250,245,236,0.75)`, `margin-top 10px`.
3. Total value `font 38px/700 #FFFFFF tabular` (rendered in a loss-leaning tone is NOT needed on the
   gradient — keep white; the amount is a liability by context).

### B. Cream sheet (`gap 11px`)
Per liability, a `PlainCard` **ListRowTile**:
- Leading 42×42 rounded-square (`radius 14`) on `#F6E4EA` with a `−` glyph `#A84E71` (or a small
  category icon).
- Middle: name `14.5px/700` + subtitle `11px muted2` (e.g. currency, or "อัปเดตล่าสุด <date>").
- Trailing: amount `15px/700 tabular color #A8341C`.
- Tapping → **Adjust sheet**.
Then a **dashed "add" card** (`border 1.5px dashed #D9CBB4; radius 18; padding 13px 16px`), centered
`+ เพิ่มหนี้สินใหม่` `12.5px/700 #A89A86`.
Empty state: a centered muted note "ยังไม่มีหนี้สิน — เพิ่มเพื่อให้ Net Worth แม่นยำขึ้น".

### C. Bottom nav present (no tab highlighted, or Overview dimmed — it's a sub-route).

## Adjust sheet (pay / add) — T3.08

Bottom sheet (SheetShell, title = liability name, e.g. **"ผ่อนรถ"**). Body:
1. Current balance banner: `background #FFE9DB; radius 16; padding 12px 16px`, label
   `ยอดคงเหลือ` `12.5px/600 #6B5D49` + amount right `17px/700 #C24A1E tabular`.
2. **ประเภท** segmented toggle (components §4): **จ่าย (pay)** vs **เพิ่ม (add)**. `pay` decrements,
   `add` increments the balance.
3. **จำนวนเงิน** amount input (`฿`/`$` suffix per liability currency), `> 0`.
4. **วันที่** date field (default today).
5. Footer primary **บันทึก** — brand pill. On save: calls `LiabilityRepo.adjust` (atomic: updates
   `liabilities.amount` **and** writes a `liability_transaction` row of type pay/add) via the notifier.

Create-liability sheet (from `+ เพิ่มหนี้สิน` / Add-sheet action): fields **ชื่อ** (name, non-empty),
**จำนวนเงิน** (amount > 0), **สกุลเงิน** (฿ THB / $ USD segmented). Footer **บันทึก**.

### T3.08 done-when (plan): "pay/add flow test" — widget test against a fake LiabilitiesNotifier
asserts choosing **จ่าย** + amount calls the notifier's adjust(pay) and the displayed balance
decreases; choosing **เพิ่ม** increases it.

## State mapping (LiabilitiesNotifier — CONTRACTS §8/§11, confirm names in Stage 2)
List + total ← notifier; adjust/create/delete → repo then `ref.invalidateSelf()`.
