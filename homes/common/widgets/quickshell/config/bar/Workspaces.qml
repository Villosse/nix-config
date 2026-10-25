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
        color: focused ? Theme.mauve : modelData.urgent ? Theme.red : Theme.surface1
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
          id: label
          anchors.centerIn: parent
          text: focused && Theme.spooky ? `\u{F0BA3} ${modelData.num}` : String(modelData.num)
          color: focused || modelData.urgent ? Theme.base : Theme.lavender
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
