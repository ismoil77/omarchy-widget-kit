import test from "node:test"
import assert from "node:assert/strict"
import { Bar } from "./loader.mjs"

const B = Bar()

test("compact: narrow screens by default, or as told", () => {
  assert.equal(B.compact("auto", 1536), true)    // a 1920 laptop panel at 1.25
  assert.equal(B.compact("auto", 1280), true)
  assert.equal(B.compact("auto", 2048), false)
  assert.equal(B.compact(undefined, 1700), false)
  assert.equal(B.compact("Always", 2560), true)
  assert.equal(B.compact("never", 1280), false)
  assert.equal(B.compact("auto", 0), false, "an unknown width is not narrow")
})
