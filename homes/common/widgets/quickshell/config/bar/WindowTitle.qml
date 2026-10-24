import QtQuick
import Quickshell.Wayland

BarPill {
  readonly property var active: ToplevelManager.activeToplevel
  // activeToplevel lingers after focus moves to an empty workspace
  readonly property string windowTitle: active && active.activated ? active.title : ""

  pillColor: Theme.surface0
  textColor: Theme.pink
  bold: false
  maxWidth: 280
  visible: windowTitle !== ""
  text: windowTitle
  tooltip: implicitWidth >= maxWidth ? windowTitle : ""
}
