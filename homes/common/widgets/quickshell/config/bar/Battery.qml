import QtQuick
import Quickshell.Io

BarPill {
  id: root

  property int pct: 100
  property string status: ""
  property real energyNow: 0
  property real energyFull: 0
  property real powerNow: 0
  readonly property bool charging: status === "Charging" || status === "Full"

  pillColor: charging ? Theme.green : pct <= 20 ? Theme.red : pct <= 30 ? Theme.yellow : Theme.mauve
  text: {
    const icon = charging ? "\u{F1E6}" : pct >= 90 ? "\u{F240}" : pct >= 70 ? "\u{F241}" : pct >= 40 ? "\u{F242}" : pct >= 20 ? "\u{F243}" : "\u{F244}"
    return `${icon} ${pct}%`
  }
  tooltip: {
    if (powerNow <= 0 || status === "Full") return status
    const hours = status === "Charging" ? (energyFull - energyNow) / powerNow : energyNow / powerNow
    const h = Math.floor(hours)
    const m = String(Math.round((hours - h) * 60)).padStart(2, "0")
    return `${status} · ${h}h${m} ${status === "Charging" ? "until full" : "left"}`
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: batProc.running = true
  }

  // capacity, energy (or charge) now/full, power (or current) now, status (may contain spaces, so last)
  Process {
    id: batProc
    command: ["sh", "-c", "b=$(ls -d /sys/class/power_supply/BAT* | head -1); r() { cat $b/$1 2>/dev/null || cat $b/$2 2>/dev/null || echo 0; }; echo $(r capacity capacity) $(r energy_now charge_now) $(r energy_full charge_full) $(r power_now current_now) $(cat $b/status)"]
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = text.trim().split(" ")
        if (parts.length < 5) return
        root.pct = parseInt(parts[0]) || 100
        root.energyNow = Number(parts[1])
        root.energyFull = Number(parts[2])
        root.powerNow = Number(parts[3])
        root.status = parts.slice(4).join(" ")
      }
    }
  }
}
