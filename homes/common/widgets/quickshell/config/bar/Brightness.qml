import QtQuick
import Quickshell.Io

BarPill {
  id: root
  pillColor: Theme.yellow

  property int maxRaw: 0
  property int currentRaw: 0
  property int pending: 0
  readonly property int pct: maxRaw ? Math.round(currentRaw / maxRaw * 100) : 0

  text: `${pct < 25 ? "󰃞" : pct < 50 ? "󰃟" : "󰃠"} ${pct}%`
  tooltip: `Brightness ${pct}%`

  // blocks hardware readback for 1s after last scroll action
  Timer {
    id: settleTimer
    interval: 1000
    repeat: false
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!settleTimer.running) brightnessProc.running = true
  }

  FileView {
    path: "/tmp/qs-brightness-refresh"
    watchChanges: true
    printErrors: false
    onFileChanged: if (!settleTimer.running) brightnessProc.running = true
  }

  Process {
    id: brightnessProc
    command: ["sh", "-c", "brightnessctl -m | awk -F, '{print $3, $5}'"]
    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(" ").map(Number)
        if (parts.length < 2 || !parts[1]) return
        root.currentRaw = parts[0]
        root.maxRaw = parts[1]
      }
    }
  }

  onWheel: delta => {
    if (!maxRaw) return
    pending += delta
    settleTimer.restart()
    if (!brightProc.running) flushPending()
  }

  function flushPending() {
    if (pending === 0 || !maxRaw) return
    const targetPct = Math.max(0, Math.min(100, pct + pending))
    pending = 0
    currentRaw = Math.round(targetPct / 100 * maxRaw)
    brightProc.command = ["brightnessctl", "set", String(currentRaw), "-q"]
    brightProc.running = true
  }

  Process {
    id: brightProc
    command: []
    onRunningChanged: if (!running && root.pending !== 0) root.flushPending()
  }
}
