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

      implicitWidth: 28
      implicitHeight: 28
      radius: 6
      color: "#363a4f"

      Image {
        anchors.centerIn: parent
        width: 18
        height: 18
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
