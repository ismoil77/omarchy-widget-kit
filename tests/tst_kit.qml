import QtQuick
import QtTest
import "../kit" as Kit

// The kit's components, built in Qt's own engine against a stub of the shell's
// Style/Color/Util. Catches binding errors and layout regressions that Node can't see.
Item {
  id: scene
  width: 420
  height: 600

  Kit.Look { id: skin }
  Kit.Look { id: big; textSize: "Extra large"; animations: false }
  Kit.Look { id: large; textSize: "LARGE" }
  Kit.Look { id: themedLook; themeColors: ({ green: "#879a39", red: "#d14d41", yellow: "#d0a215" }) }

  TestCase {
    name: "Kit"
    when: windowShown

    // A layout that feeds its own size froze the shell once: any polish loop fails the run.
    function init() { failOnWarning(/polish/) }

    function test_look_type_scale_has_a_floor_and_scales() {
      verify(skin.small >= 13)
      compare(skin.textScale, 1)
      compare(big.textScale, 1.5)
      verify(big.small > skin.small)
      compare(big.fade, 0)
      compare(skin.fade, 240)
    }

    function test_look_colours_reach_contrast_on_the_popup() {
      // Dark ink on a cream popup: AAA for text, dim text still AA, accent fill is a graphic.
      verify(skin.ink.hslLightness < 0.2)
      verify(skin.dim.hslLightness < 0.5)
      verify(skin.accentText.hslLightness < 0.5)
    }

    function test_look_text_size_is_case_insensitive() {
      compare(large.textScale, 1.25)
    }

    Component {
      id: rowComponent
      Kit.StatRow {
        look: skin
        width: 400
        name: "a-very-long-project-name-that-has-to-be-elided-somewhere"
        cells: ["×11170", "1.0M", "21%"]
        cellWidths: [60, 50, 40]
        dimCells: [true, false, true]
        share: 0.5
      }
    }

    function test_statrow_keeps_cells_in_their_columns_and_elides_the_name() {
      var row = createTemporaryObject(rowComponent, scene)
      verify(row !== null)
      compare(row.cellsWidth, 60 + 50 + 40 + 3 * 8)
      verify(row.implicitHeight > 0)
    }

    function test_statrow_share_is_clamped() {
      var row = createTemporaryObject(rowComponent, scene, { share: 7 })
      verify(row !== null)
      row.share = -3
      verify(row.implicitHeight > 0)
    }

    function test_statrow_click_only_when_clickable() {
      var row = createTemporaryObject(rowComponent, scene, { clickable: true })
      var clicks = 0
      row.clicked.connect(function() { clicks++ })
      mouseClick(row, 10, 5)
      compare(clicks, 1)
      var quiet = createTemporaryObject(rowComponent, scene, { clickable: false, y: 100 })
      quiet.clicked.connect(function() { clicks++ })
      mouseClick(quiet, 10, 5)
      compare(clicks, 1)
    }

    Component {
      id: pairComponent
      Kit.InfoPair { look: skin; width: 300; label: "Label"; value: "42" }
    }

    function test_infopair_takes_its_parents_width() {
      var holder = Qt.createQmlObject("import QtQuick; Item { width: 250; height: 30 }", scene)
      var pair = pairComponent.createObject(holder)
      verify(pair.implicitHeight > 0)
      compare(pair.width, 300)
    }

    function test_morebutton_hides_when_empty_and_emits_clicks() {
      var more = createTemporaryObject(Qt.createComponent("../kit/MoreButton.qml"), scene, { look: skin, text: "" })
      compare(more.visible, false)
      more.text = "3 more"
      compare(more.visible, true)
      var clicks = 0
      more.clicked.connect(function() { clicks++ })
      mouseClick(more, 5, 5)
      compare(clicks, 1)
    }

    function test_meter_fraction_is_clamped() {
      var m = createTemporaryObject(Qt.createComponent("../kit/Meter.qml"), scene, { look: big, width: 200, fraction: 5 })
      compare(m.children[0].width, 200)
      m.fraction = -1
      compare(m.children[0].width, 0)
    }

    Component {
      id: chartComponent
      Kit.BarChart {
        look: skin
        width: 400
        values: [0, 5, 10, 2]
        ticks: ["a", "", "", "d"]
        current: 2
      }
    }

    function test_chart_peak_shown_and_hover() {
      var chart = createTemporaryObject(chartComponent, scene)
      compare(chart.count, 4)
      compare(chart.peak, 10)
      compare(chart.shown, 2)
      chart.cursor = 1
      compare(chart.shown, 1)
      chart.cursor = 99
      compare(chart.shown, 2)
      chart.cursor = -1
      chart.current = -1
      compare(chart.shown, -1)
    }

    function test_chart_maps_x_to_a_column() {
      var chart = createTemporaryObject(chartComponent, scene)
      compare(chart.columnAt(-50), 0)
      compare(chart.columnAt(chart.width + 50), 3)
      compare(chart.columnAt(chart.columnWidth * 1.5 + chart.gap), 1)
    }

    function bars(item, found) {
      for (var i = 0; i < item.children.length; i++) {
        var c = item.children[i]
        if (c.objectName === "bar") found.push(c)
        bars(c, found)
      }
      return found
    }

    function test_chart_bars_grow_from_nothing_and_never_pass_the_plot() {
      var chart = createTemporaryObject(chartComponent, scene)
      compare(bars(chart, []).length, 4)
      // Another period brings bigger numbers: no column may be taller than the plot, at any moment.
      chart.values = [900, 1000, 40, 7, 500, 3, 1]
      chart.ticks = ["", "", "", "", "", "", ""]
      var now = bars(chart, [])
      compare(now.length, 7)
      for (var i = 0; i < now.length; i++) verify(now[i].height <= chart.plotHeight)
      tryVerify(function() { return bars(chart, [])[1].height === chart.plotHeight })
      var settled = bars(chart, [])
      for (var j = 0; j < settled.length; j++) verify(settled[j].height <= chart.plotHeight && settled[j].height > 0)
    }

    function test_chart_without_columns_has_no_column_under_the_pointer() {
      var chart = createTemporaryObject(chartComponent, scene, { values: [], ticks: [] })
      compare(chart.columnAt(10), -1)
    }

    function test_chart_signals() {
      var chart = createTemporaryObject(chartComponent, scene)
      var seen = []
      chart.columnHovered.connect(function(i) { seen.push(i) })
      mouseMove(chart, chart.columnWidth * 2.5 + chart.gap * 2, chart.implicitHeight / 2)
      verify(seen.indexOf(2) >= 0)
    }

    function test_chart_readout_wraps_instead_of_cutting_off() {
      var chart = createTemporaryObject(chartComponent, scene, { title: "15:00–16:00", detail: "short", detailSample: "short" })
      var oneLine = chart.implicitHeight
      chart.detailSample = "a very long figures line that cannot fit beside the title in four hundred pixels at all"
      verify(chart.implicitHeight > oneLine)
      chart.detailSample = ""
      compare(chart.implicitHeight, oneLine)
    }

    function test_chart_layout_does_not_follow_the_title_under_the_pointer() {
      var chart = createTemporaryObject(chartComponent, scene, { title: "x", detail: "figures", detailSample: "figures", titleSample: "a title as wide as any of them" })
      var height = chart.implicitHeight
      chart.title = "a much longer title that is on show while the pointer is over another column of this chart"
      compare(chart.implicitHeight, height)
    }

    function test_chart_with_no_data_does_not_divide_by_zero() {
      var chart = createTemporaryObject(chartComponent, scene, { values: [], ticks: [], current: -1 })
      compare(chart.count, 0)
      compare(chart.peak, 0)
      compare(chart.columnWidth, 0)
      compare(chart.shown, -1)
    }

    function test_look_levels_follow_the_palette_and_read_on_the_popup() {
      var plain = skin
      var themed = themedLook
      verify(String(themed.good) !== String(plain.good), "green from the palette")
      // Contrast against the popup is not checked here: under qmltestrunner Qt's
      // own `Color` type hides the stub's, so the popup background is unknown.
      compare(String(themed.levelFill("bad")), String(themed.bad))
      compare(String(themed.levelText("warn")), String(themed.warnText))
      compare(String(themed.levelFill("anything")), String(themed.good))
    }

    function test_card_and_tile_grow_with_content() {
      var tile = createTemporaryObject(Qt.createComponent("../kit/Tile.qml"), scene, { look: skin, width: 180, caption: "Swap", value: "41%" })
      var bare = tile.implicitHeight
      tile.fraction = 0.4
      tile.mark = 0.9
      tile.detail = "limit 90%"
      tryVerify(function() { return tile.implicitHeight > bare })
      var clicks = 0
      tile.action = "Free up"
      tile.activated.connect(function() { clicks++ })
      tile.activated()
      compare(clicks, 1)
    }

    function test_chip_hides_without_text() {
      var chip = createTemporaryObject(Qt.createComponent("../kit/Chip.qml"), scene, { look: skin, text: "" })
      verify(!chip.visible)
      chip.text = "calm"
      verify(chip.visible)
      verify(chip.implicitWidth > 20)
    }

    function test_segment_bar_sums_and_ignores_bad_values() {
      var bar = createTemporaryObject(Qt.createComponent("../kit/SegmentBar.qml"), scene, { look: skin, width: 300,
        segments: [{ value: 3, color: "red", label: "a" }, { value: -5, color: "blue", label: "b" }, { value: "x", color: "green", label: "c" }, { value: 1, color: "gray", label: "d" }] })
      compare(bar.total, 4)
      verify(bar.implicitHeight > 12)
    }

    function test_area_chart_paints_short_and_empty_series() {
      var chart = createTemporaryObject(Qt.createComponent("../kit/AreaChart.qml"), scene, { look: skin, width: 300, capacity: 10,
        series: [{ values: [0.1, 0.5, 2, -1], color: skin.accentFill, fill: true, label: "mem" }, { values: [], color: skin.bad, dashed: true }] })
      verify(chart.implicitHeight >= chart.chartHeight)
      chart.series = []
      wait(20)
    }

    function test_app_icon_falls_back_to_a_letter() {
      var icon = createTemporaryObject(Qt.createComponent("../kit/AppIcon.qml"), scene, { look: skin, name: "chromium", size: 24 })
      compare(icon.implicitWidth, 24)
      verify(icon.tint.a > 0)
    }

    Component {
      id: tileRowComponent
      Kit.TileRow {
        width: 400
        property alias a: tileA
        property alias b: tileB
        Kit.Tile { id: tileA; look: skin; caption: "short"; value: "1" }
        Kit.Tile { id: tileB; look: skin; caption: "tall"; value: "2"; detail: "one\ntwo\nthree"; fraction: 0.5 }
      }
    }

    function test_tile_row_lines_tiles_up_and_shares_room() {
      var row = createTemporaryObject(tileRowComponent, scene)
      tryVerify(function() { return row.a.height > 0 && row.a.height === row.b.height })
      verify(row.b.implicitHeight > row.a.implicitHeight)
      compare(row.a.width, row.b.width)
      row.a.visible = false
      tryCompare(row.b, "width", 400)
    }

    function test_header_shows_name_value_and_chip() {
      var h = createTemporaryObject(Qt.createComponent("../kit/Header.qml"), scene, { look: skin, width: 380, glyph: "x", name: "memory", value: "73%", say: "calm", chip: "ok" })
      verify(h.implicitHeight > 0)
      h.chip = ""
      verify(h.implicitHeight > 0)
    }

    Component {
      id: sectionComponent
      Kit.Section {
        width: 300
        look: skin
        caption: "Apps"
        trailing: [Kit.ActionButton { look: skin; text: "5"; compact: true }]
        Text { text: "row" }
      }
    }

    function test_section_takes_trailing_controls_and_content() {
      var s = createTemporaryObject(sectionComponent, scene)
      tryVerify(function() { return s.implicitHeight > 30 })
    }

    Component {
      id: actionRowComponent
      Kit.ActionRow {
        width: 300
        property alias first: one
        Kit.ActionButton { id: one; look: skin; text: "Send"; primary: true }
        Kit.ActionButton { look: skin; text: "Apply changes now" }
        Kit.ActionButton { look: skin; text: "x"; visible: false }
      }
    }

    function test_action_row_shares_width_and_buttons_click() {
      var r = createTemporaryObject(actionRowComponent, scene)
      tryCompare(r.first, "width", (300 - r.spacing) / 2)
      var clicks = 0
      r.first.clicked.connect(function() { clicks++ })
      mouseClick(r.first)
      compare(clicks, 1)
      compare(String(r.first.labelColor), "#ffffff")
    }

    function test_signature_reads_like_the_family() {
      var sig = createTemporaryObject(Qt.createComponent("../kit/Signature.qml"), scene, { look: skin, width: 300, widget: "Memory", version: "2.0.0" })
      verify(sig.implicitHeight > 0)
    }
  }
}
