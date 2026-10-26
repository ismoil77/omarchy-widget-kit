// Loads the kit's QML JavaScript libraries (`.pragma library`) into plain Node.
import fs from "node:fs"
import path from "node:path"
import vm from "node:vm"
import { fileURLToPath } from "node:url"

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "kit")

export function load(file) {
  const sandbox = { Math, Date, Number, String, Array, Object, RegExp, parseInt, isFinite, isNaN, Infinity, NaN, console }
  const code = fs.readFileSync(path.join(root, file), "utf8")
    .split("\n")
    .filter(line => !/^\.(pragma|import)\b/.test(line))
    .join("\n")
  vm.createContext(sandbox)
  vm.runInContext(code, sandbox, { filename: file })
  // Top-level functions and vars become the library's exports, as in QML.
  const lib = {}
  for (const key of Object.keys(sandbox)) if (!(key in globalThis)) lib[key] = sandbox[key]
  return lib
}

export const Contrast = () => load("Contrast.js")
export const I18n = () => load("I18n.js")
