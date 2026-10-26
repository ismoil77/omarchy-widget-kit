import test from "node:test"
import assert from "node:assert/strict"
import { I18n as load } from "./loader.mjs"

const I = load()
const tables = {
  en: { hello: "Hello, {name}", only: "only English", items: ["item", "items"] },
  ru: { hello: "Привет, {name}", items: ["штука", "штуки", "штук"] }
}

test("resolve: explicit language, locale, names, fallback", () => {
  const langs = ["en", "ru"]
  assert.equal(I.resolve("ru", "en_US", langs), "ru")
  assert.equal(I.resolve("RU", "en_US", langs), "ru")
  assert.equal(I.resolve("auto", "ru_RU.UTF-8", langs), "ru")
  assert.equal(I.resolve("auto", "ru-RU", langs), "ru")
  assert.equal(I.resolve("auto", "ru", langs), "ru")
  assert.equal(I.resolve("auto", "en_GB", langs), "en")
  assert.equal(I.resolve("auto", "de_DE", langs), "en")
  assert.equal(I.resolve("auto", "", langs), "en")
  assert.equal(I.resolve(undefined, undefined, langs), "en")
  assert.equal(I.resolve("klingon", "ru_RU", langs), "ru")
  assert.equal(I.resolve("русский", "", langs, { "русский": "ru" }), "ru")
  assert.equal(I.resolve("rustic", "", langs), "en")
})

test("t: fills placeholders, falls back to English, then to the key", () => {
  assert.equal(I.t(tables, "en", "hello", { name: "Ann" }), "Hello, Ann")
  assert.equal(I.t(tables, "ru", "hello", { name: "Аня" }), "Привет, Аня")
  assert.equal(I.t(tables, "ru", "only"), "only English")
  assert.equal(I.t(tables, "fr", "hello", { name: "X" }), "Hello, X")
  assert.equal(I.t(tables, "en", "missing"), "missing")
  assert.equal(I.t(tables, "en", "hello"), "Hello, {name}")
  assert.equal(I.t(tables, "en", "hello", { name: 0 }), "Hello, 0")
})

test("plural: English", () => {
  const f = ["item", "items"]
  assert.equal(I.plural("en", 1, f), "item")
  for (const n of [0, 2, 5, 11, 21, 100]) assert.equal(I.plural("en", n, f), "items", String(n))
})

test("plural: Russian follows the CLDR rules", () => {
  const f = ["штука", "штуки", "штук"]
  const expect = { 0: 2, 1: 0, 2: 1, 4: 1, 5: 2, 11: 2, 12: 2, 14: 2, 21: 0, 22: 1, 25: 2, 101: 0, 111: 2, 112: 2, 121: 0 }
  for (const [n, i] of Object.entries(expect)) assert.equal(I.plural("ru", Number(n), f), f[i], n)
})

test("plural: negative and fractional counts, short form lists, unknown language", () => {
  assert.equal(I.plural("ru", -1, ["a", "b", "c"]), "a")
  assert.equal(I.plural("en", 1.2, ["a", "b"]), "a")
  assert.equal(I.plural("ru", 5, ["a", "b"]), "b") // fewer forms than classes: the last one
  assert.equal(I.plural("fr", 2, ["a", "b"]), "b")
  assert.equal(I.plural("en", "x", ["a", "b"]), "b")
})

test("count: number and noun", () => {
  assert.equal(I.count(tables, "en", "items", 1), "1 item")
  assert.equal(I.count(tables, "en", "items", 3), "3 items")
  assert.equal(I.count(tables, "ru", "items", 3), "3 штуки")
  assert.equal(I.count(tables, "ru", "items", 25), "25 штук")
  assert.equal(I.count(tables, "en", "nope", 4), "4")
})

test("num: decimal comma in Russian only", () => {
  assert.equal(I.num("en", 7.25, 1), "7.3")
  assert.equal(I.num("ru", 7.2, 1), "7,2")
  assert.equal(I.num("ru", 7), "7")
  assert.equal(I.num("en", 1234.5, 2), "1234.50")
  assert.equal(I.num("de", 1.5, 1), "1,5")
})
