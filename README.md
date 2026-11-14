# Omarchy widget kit

The parts of an [Omarchy](https://omarchy.org) bar widget that are not about what the widget shows:
contrast-checked colours, translation helpers, a type scale that follows the user's text size, and a
few popup components — a ranked list row, a column chart, a meter, a label/value pair.

Marketplace plugins are installed from their own repository, so a widget cannot import from another
one. Instead each widget carries a copy of `kit/`, and `sync.sh` keeps the copies identical:

```bash
./sync.sh ~/.config/omarchy/plugins/ismoil.rtk      # copies kit/ into <widget>/kit/ and stamps kit/VERSION
```

Edit the kit here, run `tests/run.sh`, bump `VERSION`, sync the widgets that use it. Never edit a
widget's `kit/` by hand.

## Use it

```qml
import "kit" as Kit
import "kit/I18n.js" as I18n

Panel {
  Kit.Look { id: skin; textSize: String(setting("textSize", "Normal")); animations: setting("animations", true) !== false }

  Kit.StatRow { look: skin; name: "grep"; cells: ["×542", "46.7K", "31%"]; cellWidths: [60, 56, 44]; share: 0.31 }
}
```

Do **not** call the `Look` instance `look`: inside a component that has a `look` property, a binding
`look: look` reads the property itself, not the id, and loops. `skin` is the name the widgets use.

| File | What it is |
|---|---|
| `Look.qml` | The popup's look: `ink` / `dim` / `track` / `surface`, accent and level colours (`good` / `warn` / `bad`, as graphics and as text) held to WCAG contrast on the popup background; the type scale (13 px floor, scaled by `textSize`); `fade`; `themed(name)`, `hue(name)`, `onPopup(color, min)`. |
| `ThemePalette.qml`, `Theme.js` | The current theme's named colours, followed live; a stable colour per name. |
| `Header.qml` | The top of a popup: a glyph in a square tinted with the state, NAME, one big figure, a sentence, a status chip. |
| `Section.qml`, `Card.qml` | A raised card with a caption and a hint or controls on the right; `Card` is one without a caption. |
| `Tile.qml`, `TileRow.qml` | A card with a caption, a big value, a meter with a limit mark, a detail; tiles in a row share one size. |
| `ActionButton.qml`, `ActionRow.qml` | The family's button (`primary`, `selected`, `danger`, `compact`); buttons in a row share the width. The row sets its children's size: do not bind it. |
| `Signature.qml` | The last line: `ismoil · name`, version on the right. |
| `Glyph.qml` | An icon glyph centred on its ink, not on its character cell. |
| `Chip.qml` | A status pill: a dot and a word. |
| `AppIcon.qml` | An app's icon, or its first letter (any script) on a theme-coloured tile. |
| `AreaChart.qml` | Recent history as lines; paints only while `live`. |
| `SegmentBar.qml` | What a whole is made of: one split bar and a legend. |
| `BarChart.qml` | Columns with ticks and a readout that wraps; hover → `columnHovered(i)`. |
| `StatRow.qml` | A ranked-list line: a name, right-aligned cells in columns, the row's share behind it. |
| `Meter.qml`, `InfoPair.qml`, `MoreButton.qml` | A thin meter; a label with a value; "3 more" / "Collapse". |
| `Contrast.js` | `ratio`, `mix`, `over`, `flatten`, `ensure(fg, bg, min)`. |
| `I18n.js` | `resolve`, `t`, `plural` (en, ru), `count`, `num`. The widget owns its tables. |

A layout must never read a size it sets: an `ActionButton` sized from its own laid-out label once put
the whole shell into a polish loop. Measure with `TextMetrics`; the tests fail on any polish warning.

## Tests

```bash
tests/run.sh   # Node: Contrast + I18n (every theme's palette for contrast); Qt: the components, against a stub of the shell's Style/Color/Util
```

The Qt part needs `qmltestrunner` (Qt 6); without it `run.sh` skips that part and says so, and the CI workflow runs the Node part only.

## License

MIT
