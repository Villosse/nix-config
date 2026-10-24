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

  // LEFT
  RowLayout {
    anchors.left: parent.left
    anchors.leftMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Workspaces {}
    WindowTitle {}
  }

  // CENTER — ancré absolument au milieu
  Clock { anchors.centerIn: parent }

  // RIGHT
  RowLayout {
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Tray {}
    Network {}
    Brightness {}
    Audio {}
    Notifications {}
    SystemRings {}
    Battery {}
  }
}
