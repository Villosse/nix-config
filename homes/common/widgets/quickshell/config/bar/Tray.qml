import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
  spacing: 4

  Repeater {
    model: SystemTray.items

    delegate: Rectangle {
      id: trayIcon
      required property var modelData

      implicitWidth: Theme.pillHeight
      implicitHeight: Theme.pillHeight
      radius: Theme.radius
      color: Theme.paper ? "transparent" : Theme.surface0

      Image {
        anchors.centerIn: parent
        width: 20
        height: 20
        source: modelData.icon
        // ask the icon provider for a big icon and scale it down, or it hands
        // back a tiny one that gets upscaled (blurry on the 1.5x panel)
        sourceSize: Qt.size(64, 64)
        smooth: true
        mipmap: true
      }

      QsMenuAnchor {
        id: menuAnchor
        menu: trayIcon.modelData.menu
        anchor.item: trayIcon
        anchor.edges: Edges.Bottom
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => {
          if (e.button === Qt.RightButton && trayIcon.modelData.hasMenu)
            menuAnchor.open()
          else
            trayIcon.modelData.activate()
        }
      }
    }
  }
}
