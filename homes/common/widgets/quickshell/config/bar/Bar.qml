import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: root
  anchors { top: true; left: true; right: true }
  implicitHeight: Theme.pillHeight + 8 + Theme.shadow
  color: "transparent"
  exclusiveZone: implicitHeight

  // paper: one cream strip glued to the top edge, pills sit flat on it
  Card {
    id: strip
    visible: Theme.paper
    anchors { fill: parent; bottomMargin: Theme.shadow }
    radius: 0
    color: Theme.surface0
  }

  // thin ink rule between groups, paper only
  component Divider: Rectangle {
    visible: Theme.paper
    implicitWidth: 2
    implicitHeight: Theme.pillHeight - 14
    color: Theme.ink
  }

  // LEFT
  RowLayout {
    anchors.left: parent.left
    anchors.leftMargin: 10
    anchors.verticalCenter: strip.verticalCenter
    spacing: 4

    Workspaces {}
    Divider { visible: Theme.paper && title.visible }
    WindowTitle { id: title }
  }

  // CENTER — ancré absolument au milieu
  Clock { anchors.centerIn: strip }

  // RIGHT
  RowLayout {
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: strip.verticalCenter
    spacing: 4

    Tray {}
    Divider {}
    Network {}
    Bluetooth {}
    Divider {}
    Brightness {}
    Audio {}
    Divider {}
    Notifications {}
    Divider {}
    SystemRings {}
    Divider {}
    Battery {}
  }
}
