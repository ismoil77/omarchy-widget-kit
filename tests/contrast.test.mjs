import test from "node:test"
import assert from "node:assert/strict"
import fs from "node:fs"
import { Contrast as load } from "./loader.mjs"

const C = load()
const palettes = JSON.parse(fs.readFileSync(new URL("./fixtures/palettes.json", import.meta.url)))

test("parse understands #rgb, #rrggbb and Qt's #aarrggbb", () => {
  assert.deepEqual({ ...C.parse("#fff") }, { r: 255, g: 255, b: 255, a: 1 })
  assert.deepEqual({ ...C.parse("#102030") }, { r: 16, g: 32, b: 48, a: 1 })
  const q = C.parse("#80ff0000")
  assert.equal(q.r, 255)
  assert.ok(Math.abs(q.a - 0.502) < 0.01)
  assert.deepEqual({ ...C.parse("nonsense") }, { r: 0, g: 0, b: 0, a: 1 })
})

test("ratio matches the WCAG reference values", () => {
  assert.equal(C.ratio("#000000", "#ffffff").toFixed(2), "21.00")
  assert.equal(C.ratio("#777777", "#777777").toFixed(2), "1.00")
  assert.equal(C.ratio("#767676", "#ffffff").toFixed(2), "4.54") // the classic AA grey
})

test("mix and over", () => {
  assert.equal(C.mix("#000000", "#ffffff", 0), "#000000")
  assert.equal(C.mix("#000000", "#ffffff", 1), "#ffffff")
  assert.equal(C.mix("#000000", "#ffffff", 0.5), "#808080")
  assert.equal(C.over("#ff0000", 0.5, "#000000"), "#800000")
})

test("ensure leaves a readable colour alone and fixes an unreadable one", () => {
  assert.equal(C.ensure("#100f0f", "#fffcf0", 4.5), "#100f0f")
  const yellow = C.ensure("#d0a215", "#fffcf0", 4.5) // theme yellow on a cream popup
  assert.notEqual(yellow, "#d0a215")
  assert.ok(C.ratio(yellow, "#fffcf0") >= 4.5)
})

test("ensure keeps the hue: a darkened yellow is still a yellow", () => {
  const { r, g, b } = C.parse(C.ensure("#d0a215", "#fffcf0", 4.5))
  assert.ok(r >= g && g > b, "red ≥ green > blue")
})

test("ensure lightens on a dark background", () => {
  const c = C.ensure("#a55555", "#101315", 4.5)
  assert.ok(C.ratio(c, "#101315") >= 4.5)
  assert.ok(C.luminance(C.parse(c)) > C.luminance(C.parse("#a55555")))
})

test("every installed theme: status colours and dim text reach AA on its background", () => {
  const names = Object.keys(palettes)
  assert.ok(names.length >= 10, "palette fixture is not empty")
  for (const name of names) {
    const p = palettes[name]
    for (const level of ["red", "yellow", "green"]) {
      const text = C.ensure(p[level], p.background, 4.5)
      assert.ok(C.ratio(text, p.background) >= 4.5, `${name} ${level} text`)
      const fill = C.ensure(p[level], p.background, 3)
      assert.ok(C.ratio(fill, p.background) >= 3, `${name} ${level} fill`)
      // Pill: the level colour at 16% over the background, text on top of it.
      const pill = C.over(p[level], 0.16, p.background)
      const onPill = C.ensure(p[level], pill, 4.5)
      assert.ok(C.ratio(onPill, pill) >= 4.5, `${name} ${level} pill text`)
    }
    const dim = C.ensure(C.mix(p.foreground, p.background, 0.22), p.background, 4.5)
    assert.ok(C.ratio(dim, p.background) >= 4.5, `${name} dim text`)
  }
})

test("ensure terminates and stays valid for any background", () => {
  for (const bg of ["#000000", "#ffffff", "#777777", "#808080", "#7f7f7f", "#ff00ff"])
    for (const fg of ["#000000", "#ffffff", "#ff0000", "#00ff00", "#0000ff", "#777777"]) {
      const c = C.ensure(fg, bg, 4.5)
      assert.match(c, /^#[0-9a-f]{6}$/)
      assert.ok(C.ratio(c, bg) >= 4.5, `${fg} on ${bg}`)
    }
})

test("flatten: opaque colours pass through, translucent ones are judged over what is behind", () => {
  assert.equal(C.flatten("#336699", "#ffffff"), "#336699")
  assert.equal(C.flatten("#ff336699", "#ffffff"), "#336699")
  assert.equal(C.flatten("#80000000", "#ffffff"), "#7f7f7f")
  assert.equal(C.flatten("#00ff0000", "#102030"), "#102030")
})

test("every installed theme: the selected and the quiet chart shades are graphics, and tell apart", () => {
  for (const [name, p] of Object.entries(palettes)) {
    for (const level of ["red", "yellow", "green"]) {
      const lit = C.ensure(p[level], p.background, 4.5)
      const soft = C.ensure(C.mix(p[level], p.background, 0.45), p.background, 3)
      assert.ok(C.ratio(soft, p.background) >= 3, `${name} ${level} quiet shade`)
      assert.ok(C.ratio(lit, p.background) > C.ratio(soft, p.background), `${name} ${level} lit is stronger`)
    }
  }
})
