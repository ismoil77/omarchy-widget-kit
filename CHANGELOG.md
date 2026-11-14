# Changelog

## 2.1.0 — audit

- Rows: `ActionRow` no longer forces its height (a closed popup measured 0 and resized on every open),
  never gives a negative width; `TileRow` is an `ActionRow` with a wider gap; `Card` is a `Section`
  without a caption.
- `Look` uses `Commons.Color`, qualified: QtQuick's own `Color` type shadowed the test stub, so colour
  assertions passed vacuously. They are real now. `Look.line` and `Tile.actionTip` removed (unused).
- `AppIcon` finds the first letter in any script (Ё, Tajik, CJK). `AreaChart` accepts colour names and
  repaints only while `live`. `SegmentBar` no longer leaves a gap for an empty segment.
  `ThemePalette` reads again when the shell's accent changes.

## 2.0.x

- 2.0.4 `Glyph` centres icons on their ink. 2.0.3 rows skip their Repeaters. 2.0.2 the header sentence
  runs under the chip. 2.0.1 `ActionButton` sized from measured text (no polish loop), tests fail on
  polish warnings. 2.0.0 the family look: `Header`, `Section`, `ActionButton`, `ActionRow`, `Signature`.

## 1.2.x

- `TileRow`; theme colours, `Card`, `Tile`, `Chip`, `AreaChart`, `SegmentBar`, `AppIcon`.

## 1.1.0

- `BarChart`: the quiet and the picked columns are both solid 3:1 graphics (`Look.accentSoft` /
  `accentText`); before, the quiet ones were 55% transparent and fell below 3:1 on most themes.
- `Look`: a translucent popup background is judged over the theme's own background, not as if opaque
  (`Contrast.flatten`).

## 1.0.0

First version, extracted from the rtk widget: `Look`, `StatRow`, `BarChart`, `Meter`, `InfoPair`,
`MoreButton`, `Contrast.js` (shared by several widgets until now as copies) and `I18n.js`.
