pragma Singleton
import QtQuick

QtObject {
  property color accent: "#205ea6"
  property color urgent: "#af3029"
  property color foreground: "#100f0f"
  readonly property QtObject popups: QtObject {
    property color background: "#fffcf0"
    property color text: "#100f0f"
  }
}
