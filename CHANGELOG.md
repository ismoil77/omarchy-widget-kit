# Changelog

## 1.1.0

- `BarChart`: the quiet and the picked columns are both solid 3:1 graphics (`Look.accentSoft` /
  `accentText`); before, the quiet ones were 55% transparent and fell below 3:1 on most themes.
- `Look`: a translucent popup background is judged over the theme's own background, not as if opaque
  (`Contrast.flatten`).

## 1.0.0

First version, extracted from the rtk widget: `Look`, `StatRow`, `BarChart`, `Meter`, `InfoPair`,
`MoreButton`, `Contrast.js` (shared by several widgets until now as copies) and `I18n.js`.
