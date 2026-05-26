import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: root
  anchors { top: true; left: true; right: true }
  implicitHeight: 46
  color: "transparent"
  exclusiveZone: implicitHeight

  readonly property color base:     "#24273a"
  readonly property color surface0: "#363a4f"
  readonly property color surface1: "#494d64"
  readonly property color text:     "#cad3f5"
  readonly property color mauve:    "#c6a0f6"
  readonly property color pink:     "#f5bde6"
  readonly property color red:      "#ed8796"
  readonly property color peach:    "#f5a97f"
  readonly property color yellow:   "#eed49f"
  readonly property color green:    "#a6da95"
  readonly property color teal:     "#8bd5ca"
  readonly property color blue:     "#8aadf4"
  readonly property color lavender: "#b7bdf8"

  // LEFT
  RowLayout {
    id: leftSection
    anchors.left: parent.left
    anchors.leftMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Workspaces { surface0: root.surface0; surface1: root.surface1; mauve: root.mauve; lavender: root.lavender }
    WindowTitle { pillColor: root.surface0; textColor: root.pink }
  }

  // CENTER — ancré absolument au milieu
  Clock {
    pillColor: root.yellow
    textColor: root.base
    anchors.centerIn: parent
  }

  // RIGHT
  RowLayout {
    id: rightSection
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Tray        {}
    Network     { pillColor: root.teal;   textColor: root.base }
    Brightness  { pillColor: root.yellow; textColor: root.base }
    Audio       { pillColor: root.green;  textColor: root.base }
    SystemRings {}
    Battery  { normalColor: root.mauve; chargingColor: root.green; warningColor: root.yellow; criticalColor: root.red; textColor: root.base }
  }
}
