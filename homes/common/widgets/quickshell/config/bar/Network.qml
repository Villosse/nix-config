import QtQuick
import Quickshell.Io

BarPill {
  id: root
  pillColor: Theme.teal

  property string type: ""
  property string conn: ""

  text: type === "wifi" ? `󰤨 ${conn}` : type === "ethernet" ? "󰈀" : "󰤯"

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: netProc.running = true
  }

  Process {
    id: netProc
    command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev | grep ':connected:' | head -1"]
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = text.trim().split(":")
        root.type = parts[0] === "wifi" || parts[0] === "ethernet" ? parts[0] : ""
        root.conn = parts[2] ?? ""
      }
    }
  }
}
