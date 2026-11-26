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

  implicitWidth: label.implicitWidth + 16 + Theme.shadow
  implicitHeight: label.implicitHeight + 8 + Theme.shadow
  color: "transparent"
  visible: shown && text !== ""

  Timer {
    id: delay
    interval: 400
    onTriggered: root.shown = true
  }

  function show() { delay.restart() }
  function hide() { delay.stop(); shown = false }

  Card {
    anchors { fill: parent; rightMargin: Theme.shadow; bottomMargin: Theme.shadow }
    color: Theme.popup
    border.color: Theme.paper ? Theme.ink : root.accent
    border.width: Math.max(1, Theme.border)
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
