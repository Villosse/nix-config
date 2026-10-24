import QtQuick
import Quickshell

// Hover tooltip shown below its target, outside the bar surface.
PopupWindow {
  id: root
  required property Item target
  property string text: ""
  property color accent: Theme.lavender
  property bool shown: false

  anchor.item: target
  anchor.edges: Edges.Bottom
  anchor.gravity: Edges.Bottom
  anchor.margins.top: 6
  anchor.rect.x: (target.width - implicitWidth) / 2

  implicitWidth: label.implicitWidth + 16
  implicitHeight: label.implicitHeight + 8
  color: "transparent"
  visible: shown && text !== ""

  Timer {
    id: delay
    interval: 400
    onTriggered: root.shown = true
  }

  function show() { delay.restart() }
  function hide() { delay.stop(); shown = false }

  Rectangle {
    anchors.fill: parent
    color: Theme.base
    border.color: root.accent
    border.width: 1
    radius: 6

    Text {
      id: label
      anchors.centerIn: parent
      text: root.text
      color: Theme.text
      font.family: Theme.font
      font.pixelSize: 12
    }
  }
}
