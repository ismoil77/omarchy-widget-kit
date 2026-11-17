.pragma library

// A bar has little room on a narrow screen (a laptop panel, a tablet): there
// the widgets show less, so the bar's sections do not run into each other.
// `setting`: "auto" (by screen width), "always" or "never"; `screenWidth` in
// logical pixels (Screen.width).
var NARROW = 1700

function compact(setting, screenWidth) {
  var s = String(setting || "auto").toLowerCase()
  return s === "always" || (s !== "never" && Number(screenWidth) > 0 && Number(screenWidth) < NARROW)
}
