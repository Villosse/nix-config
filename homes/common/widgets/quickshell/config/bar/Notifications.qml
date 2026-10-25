import QtQuick
import Quickshell.Io

BarPill {
  id: root

  property int count: 0
  property bool dnd: false

  pillColor: dnd ? Theme.red : Theme.surface0
  textColor: dnd ? Theme.base : Theme.lavender
  readonly property string icon: Theme.spooky ? "\u{F02A0}" : "󰂚"
  text: dnd ? (Theme.spooky ? "\u{F09F5}" : "󰂛") : count > 0 ? `${icon} ${count}` : icon

  // swaync emits one JSON line per state change: {"text": "<count>", "alt": "[dnd-]notification|none", ...}
  Process {
    running: true
    command: ["swaync-client", "--subscribe-waybar"]
    stdout: SplitParser {
      onRead: data => {
        try {
          const s = JSON.parse(data)
          root.count = parseInt(s.text) || 0
          root.dnd = s.alt.startsWith("dnd")
        } catch (e) {}
      }
    }
  }

  Process { id: toggleDnd; command: ["swaync-client", "--toggle-dnd", "--skip-wait"] }
  Process { id: togglePanel; command: ["swaync-client", "--toggle-panel", "--skip-wait"] }

  onClicked: toggleDnd.running = true
  onRightClicked: togglePanel.running = true
}
