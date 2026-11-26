import QtQuick
import Quickshell.Io

BarPill {
  id: root
  pillColor: Theme.teal

  property string type: ""
  property string conn: ""
  property int signal: 0
  property string ip: ""

  text: type === "wifi" ? `${signal >= 75 ? "󰤨" : signal >= 50 ? "󰤥" : signal >= 25 ? "󰤢" : "󰤟"} ${conn}` : type === "ethernet" ? "󰈀" : "󰤯"
  tooltip: type ? `${conn}${type === "wifi" ? ` · ${signal}%` : ""}${ip ? `\n${ip}` : ""}` : "Disconnected"

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: netProc.running = true
  }

  // line 1: TYPE:STATE:DEVICE:CONNECTION, 2: wifi signal, 3: IPv4/prefix
  // --rescan no: read the cached scan, never trigger one every 5s
  Process {
    id: netProc
    command: ["sh", "-c", `
      l=$(nmcli -t -f TYPE,STATE,DEVICE,CONNECTION dev | grep -E '^(wifi|ethernet):connected:' | head -1)
      [ -n "$l" ] || exit 0
      echo "$l"
      nmcli -t -f IN-USE,SIGNAL dev wifi list --rescan no 2>/dev/null | awk -F: '$1=="*"{s=$2} END{print s}'
      nmcli -g IP4.ADDRESS dev show "$(echo "$l" | cut -d: -f3)" | head -1`]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.split("\n")
        const parts = lines[0].split(":")
        root.type = parts[0] === "wifi" || parts[0] === "ethernet" ? parts[0] : ""
        root.conn = parts.slice(3).join(":").replace(/\\:/g, ":")
        root.signal = parseInt(lines[1]) || 0
        root.ip = (lines[2] ?? "").trim()
      }
    }
  }
}
