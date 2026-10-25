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
      color: Theme.surface0

      Image {
        anchors.centerIn: parent
        width: 20
        height: 20
        source: modelData.icon
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
