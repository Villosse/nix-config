import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
  spacing: Theme.paper ? 8 : 4

  Repeater {
    model: SystemTray.items

    // paper: raised buttons like the other clickable pills
    delegate: Card {
      id: trayIcon
      required property var modelData

      implicitWidth: Theme.chipHeight
      implicitHeight: Theme.chipHeight
      radius: Theme.radius
      color: Theme.surface0
      shadowed: !trayMouse.pressed
      transform: Translate { x: trayMouse.pressed ? Theme.shadow : 0; y: trayMouse.pressed ? Theme.shadow : 0 }

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
        id: trayMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
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
