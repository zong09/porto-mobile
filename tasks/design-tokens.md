# Design tokens — Porto Mobile (Phase 1: T1.14 Theme)

> Source: `claude_design` MCP (`Porto Mobile - 1b.dc.html`) was unavailable this session, so
> tokens are taken from the web app's default **sunset** theme (`frontend/src/index.css`,
> `frontend/src/utils/themes.ts`, and the modal specs in `CLAUDE.md`) per the plan's fallback
> rule ("tailwind/web is the fallback where the design is silent"). Values are exact.

## Colors — `lib/src/ui/theme/colors.dart` (class `AppColors`, all `static const Color`)

| Token | Hex |
|---|---|
| `bg` | `#FAF5EC` |
| `bgAlt` | `#FAF6ED` |
| `surface` (card) | `#FFFFFF` |
| `text` | `#3D3328` |
| `text2` | `#6B5D49` |
| `muted` | `#8A7D6C` |
| `muted2` | `#A89A86` |
| `muted3` | `#B3A692` |
| `border` | `#E0D5C2` |
| `brand` (primary) | `#EC6530` |
| `brandD` | `#C24A1E` |
| `brandDd` | `#9A3614` |
| `secondary` | `#FFAE6E` |
| `secondaryL` | `#FFC79A` |
| `soft` | `#FFE3E3` |
| `softH` | `#FFD4D4` |
| `gain` (positive text) | `#1E9396` |
| `gainBg` | `#DDF3F3` |
| `loss` (negative text) | `#C73B22` |
| `lossBg` | `#FCDFD4` |
| `gold` | `#E6A23C` |
| `rose` | `#C76B8E` |

Portfolio / chart palette (index 0–5) — `static const List<Color> palette`:
`['#EC6530', '#FFAE6E', '#3AA9AC', '#E6A23C', '#C76B8E', '#5FBEC0']`

Dart `Color` literal form: `Color(0xFFEC6530)` (prefix `0xFF` + the 6 hex digits).

## Typography — `lib/src/ui/theme/typography.dart` (class `AppType`)

- Font family: **`Anuphan`** (bundled asset; weights 400/500/600/700).
- Provide `static const String fontFamily = 'Anuphan';`
- `static const TextStyle` roles (fontFamily Anuphan, color `AppColors.text`):
  - `display` — size 30, weight 700
  - `heading` — size 20, weight 700
  - `title` — size 16, weight 600
  - `body` — size 14, weight 400
  - `label` — size 12.5, weight 600, color `AppColors.muted`
  - `caption` — size 12, weight 400, color `AppColors.muted`
  - `numTabular` — size 14, weight 500, `fontFeatures: [FontFeature.tabularFigures()]`

## Spacing & radii — `lib/src/ui/theme/spacing.dart`

`class AppSpacing` (`static const double`): `xs=6, sm=10, md=14, lg=18, xl=22, xxl=26, page=28`.

`class AppRadii` (`static const double`): `input=12, card=16, modal=24, pill=999`.

Modal/layout reference (from `CLAUDE.md`, for Phase 3 — not built in T1.14):
- Modal: `maxWidth 440`, padding `vertical 26 / horizontal 28`, radius `24`, form `gap 14`.
- Input/select: padding `vertical 10 / horizontal 14`, radius `12`, text `14`.
- Segmented toggle: padding `vertical 9`, radius `12`.
- Footer buttons: `vertical 9 / horizontal 18` (cancel) & `/ horizontal 22` (save), text `13.5`.

## T1.14 done-when
`flutter analyze lib/src/ui/theme/` clean, and a widget test pumps a `MaterialApp` whose theme uses
these tokens and asserts `AppColors.brand == const Color(0xFFEC6530)` and `AppColors.palette.length == 6`.
Font asset wiring (pubspec `fonts:` + .ttf files) is NOT part of T1.14 — `fontFamily` string only.
