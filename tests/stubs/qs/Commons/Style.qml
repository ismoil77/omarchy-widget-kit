pragma Singleton
import QtQuick

// Just enough of the Omarchy shell's Style for the kit's components.
QtObject {
  readonly property real cornerRadius: 8
  readonly property QtObject font: QtObject {
    readonly property string family: "monospace"
    readonly property int caption: 11
    readonly property int bodySmall: 12
    readonly property int body: 12
    readonly property int subtitle: 13
    readonly property int title: 14
    readonly property int heading: 18
    readonly property int display: 22
    readonly property int displayLarge: 28
  }
  function space(n) { return n }
}
