import QtQuick
import Quickshell.Io

BarPill {
  id: root

  property int pct: 100
  property string status: ""
  readonly property bool charging: status === "Charging" || status === "Full"

  pillColor: charging ? Theme.green : pct <= 20 ? Theme.red : pct <= 30 ? Theme.yellow : Theme.mauve
  text: {
    const icon = charging ? "\u{F1E6}" : pct >= 90 ? "\u{F240}" : pct >= 70 ? "\u{F241}" : pct >= 40 ? "\u{F242}" : pct >= 20 ? "\u{F243}" : "\u{F244}"
    return `${icon} ${pct}%`
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: batProc.running = true
  }

  // capacity, status (may contain spaces, so last)
  Process {
    id: batProc
    command: ["sh", "-c", "b=$(ls -d /sys/class/power_supply/BAT* | head -1); echo $(cat $b/capacity) $(cat $b/status)"]
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = text.trim().split(" ")
        if (parts.length < 2) return
        root.pct = parseInt(parts[0]) || 100
        root.status = parts.slice(1).join(" ")
      }
    }
  }
}
