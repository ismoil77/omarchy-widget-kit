import test from "node:test"
import assert from "node:assert/strict"
import { Theme } from "./loader.mjs"

const T = Theme()

test("parseColors reads key = \"#hex\" lines only", () => {
  const p = T.parseColors('mode = "light"\naccent = "#205EA6"\n  green="#879A39"\nbad = "#12345"\n# red = "#ff0000"\n')
  assert.deepEqual({ ...p }, { accent: "#205ea6", green: "#879a39" })
  assert.deepEqual({ ...T.parseColors(null) }, {})
})

test("tintFor: same name, same colour; falls back without a palette", () => {
  const palette = { blue: "#1", cyan: "#2", magenta: "#3", orange: "#4", green: "#5", yellow: "#6", red: "#7" }
  assert.equal(T.tintFor("chromium", palette, "#x"), T.tintFor("chromium", palette, "#x"))
  assert.ok(Object.values(palette).includes(T.tintFor("claude", palette, "#x")))
  assert.equal(T.tintFor("claude", {}, "#fallback"), "#fallback")
  const seen = new Set(["a", "b", "chromium", "claude", "code", "node", "ghostty", "python3"].map(n => T.tintFor(n, palette, "")))
  assert.ok(seen.size >= 4, "names spread over the palette")
})
