# Design spec — shared components & chart geometry (Porto Mobile, direction 1b "Bold Hero")

> Source of truth: `claude_design` project "Multi Portfolio Tracker" → `Porto Mobile - 1b.dc.html`
> (direction **1b Bold Hero**). Read this session via DesignSync. Tokens live in
> `design-tokens.md`; this file adds the reusable components + the three chart geometries that
> Phase-3 tasks build against. Device frame: **402 × 874** (iPhone logical px).

## 0. Global screen frame

Every primary screen is a full-bleed **brand gradient** with a cream sheet sliding up over it:

- Root: `linear-gradient(170deg, #EC6530 0%, #C24A1E 60–70%, #9A3614 100%)`.
- **Hero region** (on the gradient): `padding: 68px 22px 20px` (top 68 clears the status bar / notch;
  detail screens use 64–68). Text is cream `#FAF5EC` / white `#FFFFFF`.
- **Sheet region**: `background #FAF5EC; border-radius: 30px 30px 0 0; padding: 20px 20px 110px`
  (bottom 110 clears the floating tab bar). `flex: 1`, column, `gap: 11–13px`, `overflow: hidden`.
- Screens WITHOUT a gradient hero (First run is full-gradient; forms use a thin gradient header
  then the sheet fills the rest).

## 1. Bottom nav — floating capsule (`ui/widgets/app_bottom_nav.dart`, built in T3.05)

Absolutely positioned: `left/right: 24px; bottom: 40px`. Capsule:
`background rgba(61,51,40,0.92)` + `backdrop blur(10)`, `border-radius 999`, `padding 9px 12px`,
`box-shadow 0 14px 34px rgba(61,51,40,0.35)`. Row of 5 slots (`flex: 1` each), center slot is the FAB.

- **4 tabs + center FAB**, left→right: `Overview · Portfolios · [＋ FAB] · Transactions · Settings`.
- Tab icon 22×22, `stroke rgba(250,245,236,0.55)` inactive. **Active tab**: stroke `#FFAE6E` +
  a 4px `#FFAE6E` dot centered below the icon (slot is a column, `gap: 2px`, `align center`).
- Icons (stroke, no fill): Overview = circle `r=7 stroke-width=3.5`; Portfolios = 2×2 rounded
  squares (`rect 7×7 rx=2`); Transactions = 3 lines (top/mid full, bottom short); Settings =
  2 slider rows (line + a `r=2.6` knob on each).
- **FAB**: 46×46 circle, `background #EC6530`, white `+` at `font-size 24`,
  `box-shadow 0 6px 16px rgba(236,101,48,0.5)`. Opens the **Add sheet** (§ in design-overview).

## 2. Sheet shell — bottom sheet (`ui/widgets/sheet_shell.dart`, T3.04)

Modal bottom sheet used by Add/Buy-Sell/Asset/Liability/Chart. Structure:

- Scrim behind: `rgba(41,28,18,0.45)` over the (blurred) screen.
- Panel: anchored bottom, full width, `background #FAF5EC`, `border-radius 30px 30px 0 0`,
  `padding 14px 20px 46px`, `box-shadow 0 -18px 44px rgba(41,28,18,0.35)`, column, `gap 14px`.
- **Grab handle**: `width 40; height 5; radius 999; background #E2D6C2; margin: 0 auto`.
- **Title row**: title `font 17px/700`; trailing close button = 28×28 circle `background #F0E7D6`,
  glyph `✕` 13px `#8A7D6C`, `margin-left: auto`.
- `SheetShell` API (T3.04): `SheetShell({required String title, required Widget child, VoidCallback? onClose})`
  → renders handle + title row + close, then `child` in a column. Full-screen forms (Buy form)
  reuse the sheet-region look but as a route, not a sheet — see design-transactions.md.

## 3. Card (`ui/widgets/cards.dart`, T3.04)

- **PlainCard**: `background #FFFFFF; border-radius 18px; padding 15px 16px`. (List cards that hold
  divided rows use `padding: 4px 15px` and put a `1px solid #F5EDDE` bottom border on every row
  except the last.)
- **StatCard** (Overview trio): `flex: 1; background #FFFFFF; radius 16px; padding 11px 13px`.
  Label `font 10.5px color #8A7D6C`; value `font 15px/700 tabular-nums`. Optional value color:
  liabilities `#A8341C`, gain `#177E81`.
- **ListRow** (asset/portfolio/tx row): height driven by `padding: 12px 0`, `display flex`,
  `align center`, `gap 11–12px`. Leading = 38–42px rounded-square icon/avatar
  (`radius 12–14`, tinted bg). Middle = column (title `14px/700`, subtitle `11px color #A89A86`).
  Trailing = right-aligned column (value `14–15px/700 tabular-nums`, sub `11px/700` colored
  gain/loss or `#A89A86` for time).
- **Avatar tints** (bg → fg) by category: crypto `#FFE9DB`→`#C24A1E`; th-stock `#DDF3F3`→`#177E81`;
  us-stock `#FBEBD2`→`#B57F22`; fund/deposit `#F6E4EA`→`#A84E71`. Donut-in-avatar uses the same bg
  with a 18–20px conic donut inside (see §6).

## 4. Pills, chips, toggles

- **Gain/loss pill** (on gradient): `background rgba(255,255,255,0.92)`, gain text `#177E81` /
  loss `#A8341C`, `font 12px/700`, `padding 3px 12px`, `radius 999`. Prefix `▲`/`▼`.
- **Timeframe / filter pills**: active = `background rgba(255,255,255,0.92) color #C24A1E`;
  inactive = `background rgba(255,255,255,0.14) color rgba(250,245,236,0.85)`. `font 11px/700`,
  `padding 4px 13–14px`, `radius 999`, row `gap 7px`. (On cream sheets the inactive variant is
  `background #FFFFFF color #6B5D49`; active = `#3D3328`/`#FAF5EC`.)
- **% allocation chip** (portfolio card): tinted to the category — bg matches avatar tint,
  fg matches avatar fg, `font 11px/700`, `padding 3px 9px`, `radius 999`.
- **Toggle switch**: track 42×25 `radius 999`; ON `background #177E81`, knob to the right;
  OFF `background #E2D6C2`, knob left. Knob 21×21 white circle, `padding 2px`.
- **Segmented portfolio chips** (Buy form "เข้าพอร์ต"): selected `background #3D3328 color #FAF5EC/700`;
  unselected `background #FFFFFF color #6B5D49/600`; `padding 7px 15px; font 12.5px; radius 999`.

## 5. Allocation bar (segmented, `ui/widgets/allocation_bar.dart` — part of T3.04 or inline in screens)

Horizontal stacked bar shown under a portfolio/total value on the gradient hero:
`height 12px; radius 999; overflow hidden; gap 2px between segments`. Segments in **white with
decreasing opacity** by rank: `#FFFFFF`, `rgba(255,255,255,0.72)`, `0.48`, `0.28` (or 0.65/0.35 for
3-way). Widths = each slice's % of total. Legend row below: `font 11px color rgba(250,245,236,0.85)`,
`gap 13–14px`, items like `Crypto 43%`.

---

## 6. Chart geometry — the three CustomPainters

All charts are hand-painted (no chart lib), mirroring the web's SVG. Colors from `AppColors`.

### 6a. AreaChartPainter (T3.01) — `ui/widgets/area_chart.dart`

Net-worth / price history area chart. Reference: hero sparkline uses `viewBox="0 0 358 74"`.

- **Inputs**: `List<double> values` (chronological), `Color line`, `Color fill` (or a gradient),
  `bool showEndDot`. The painter maps values → a smooth path across the full width, baseline at bottom.
- **Path**: normalize x across `[0, w]` evenly by index; y = `h - (v-min)/(max-min) * h` with a small
  top/bottom inset (~8% top, 0 bottom). Draw a **smooth curve** (Catmull-Rom → cubic béziers, matching
  the web's `C` bezier feel) through the points.
- **Fill**: same path closed down to the baseline (`L w,h L 0,h Z`), painted with the fill/gradient.
- **Stroke**: `strokeWidth 2.5` (hero) / `2` (row sparkline), `strokeCap round`, no fill.
- **Variants**: (i) *Hero on gradient*: line `#FFFFFF`, fill `rgba(255,255,255,0.14)`, end dot =
  `r 4 #FFFFFF`. (ii) *Row sparkline*: line `#1E9396` (gain) / `#C73B22` (loss), no fill, thin.
  (iii) *Chart sheet on cream*: line `AppColors.brand`, fill vertical gradient brand→transparent.
- **Golden (T3.01 done-when)**: a widget test pumps the painter at 358×74 with a fixed 8-point series
  and asserts it paints without error + the end-dot variant draws a circle at the last point.

### 6b. DonutChartPainter (T3.02) — `ui/widgets/donut_chart.dart`

Allocation donut (web uses CSS `conic-gradient`; mobile paints arcs). Two uses: small avatar donut
(18–20px) and larger allocation donut.

- **Inputs**: `List<DonutSlice> slices` where `DonutSlice = (double value, Color color)`,
  `double strokeFraction` (ring thickness as fraction of radius; avatar donut ~0.34 → mask hole 33%).
- **Paint**: sum values → each slice = `sweep = value/total * 2π`, drawn as an arc starting at
  `-π/2` (12 o'clock), clockwise, `PaintingStyle.stroke`, `strokeWidth = radius*strokeFraction`,
  no gaps (butt caps) for the tight avatar donut; larger donut may use a 2° gap.
- **Avatar donut colors** come in pairs from the design, e.g. crypto `#EC6530 0–62%, #FFC79A 62–100%`;
  th `#1E9396 / #8FDDDF`; us `#E6A23C / #F3D9A8`; fund `#C76B8E / #F7AEC8`. General donut uses
  `AppColors.palette`.
- **Golden (T3.02 done-when)**: pump with 3 slices `[50,26,24]` and assert total sweep = 2π and each
  arc paints; a 1-slice `[1]` case paints a full ring.

### 6c. BarChartPainter (T3.03) — `ui/widgets/bar_chart.dart`

Vertical bars (monthly buy/sell or history bars; web uses `<rect>`).

- **Inputs**: `List<double> values`, `Color barColor`, optional `List<Color> perBar`,
  `double gap` (px between bars), `double radius` (top-rounded bars).
- **Paint**: evenly divide width into `n` columns minus gaps; each bar height =
  `value/maxAbs * h`; positive bars grow up from baseline, negative (if any) down. Top corners
  rounded by `radius`. Baseline at `h` (or mid-height if negatives present).
- **Golden (T3.03 done-when)**: pump with `[3,7,5,9,4]`, assert 5 bars painted, tallest = full height.

### Notes for all painters
- Implement `shouldRepaint` comparing the input lists/colors.
- Guard empty/uniform inputs: empty → paint nothing; all-equal → flat line at mid (area) / equal bars.
- No text inside painters (labels/axes are Flutter widgets around them; the design charts are
  axis-less sparkline style).
