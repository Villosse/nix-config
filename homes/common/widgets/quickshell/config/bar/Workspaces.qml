import QtQuick
import QtQuick.Layouts
import Quickshell.I3

Rectangle {
  id: root

  implicitHeight: Theme.pillHeight
  implicitWidth: Math.max(row.implicitWidth + 16, 40)
  radius: Theme.radius
  color: Theme.surface0

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: Array.from(I3.workspaces.values).sort((a, b) => a.num - b.num)

      delegate: Rectangle {
        required property var modelData
        readonly property bool focused: modelData.focused

        implicitWidth: Math.max(label.implicitWidth + 14, 32)
        implicitHeight: Theme.pillHeight - 10
        radius: 8
        border.width: focused ? Theme.border : 0
        border.color: Theme.ink
        color: focused ? Theme.active : modelData.urgent ? Theme.red : Theme.paper ? "transparent" : Theme.surface1
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
          id: label
          anchors.centerIn: parent
          text: !focused ? String(modelData.num) : Theme.spooky ? `\u{F0BA3} ${modelData.num}` : Theme.paper ? `\u{F0AE2} ${modelData.num}` : String(modelData.num)
          color: focused ? Theme.onActive : modelData.urgent ? Theme.base : Theme.lavender
          font.family: Theme.font
          font.pixelSize: Theme.fontSize
          font.bold: true
        }

        MouseArea {
          anchors.fill: parent
          onClicked: modelData.activate()
        }
      }
    }
  }
}
