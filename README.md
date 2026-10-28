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
| `Look.qml` | The popup's look: `ink` / `dim` / `line` / `track` colours, `accentText` / `accentFill` / `accentSoft` / `urgentText`, all held to WCAG contrast on the popup background; `small` … `heroLarge` type scale (13 px floor, scaled by `textSize`); `fade` (0 when animations are off); `onPopup(color, min)`. |
| `StatRow.qml` | A ranked-list line: a name, right-aligned `cells` in columns given by `cellWidths`, the row's `share` painted behind it, optional click. |
| `BarChart.qml` | Columns from `values` with `ticks`, a readout (`title`, `detail`) that wraps instead of being cut off, hover → `columnHovered(i)`. |
| `Meter.qml` | A thin meter, `fraction` 0..1, from the left or the right. |
| `InfoPair.qml` | A label on the left, a value on the right; the label gives way when tight. |
| `MoreButton.qml` | "3 more" / "Collapse" under a cut list; hidden while its text is empty. |
| `Contrast.js` | `ratio`, `mix`, `over`, `ensure(fg, bg, min)` — nudges a colour until it reaches a contrast ratio, keeping its hue. |
| `I18n.js` | `resolve(setting, locale, langs, names)`, `t(tables, lang, key, params)`, `plural` (en, ru), `count`, `num` (decimal comma). The widget owns its tables. |

## Tests

```bash
tests/run.sh   # Node: Contrast + I18n (every theme's palette for contrast); Qt: the components, against a stub of the shell's Style/Color/Util
```

The Qt part needs `qmltestrunner` (Qt 6); without it `run.sh` skips that part and says so, and the CI workflow runs the Node part only.

## License

MIT
