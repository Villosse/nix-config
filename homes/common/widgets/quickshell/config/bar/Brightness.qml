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

  // backlight dir, e.g. /sys/class/backlight/amdgpu_bl2 (the number changes between boots)
  property string dir: ""

  Process {
    running: true
    command: ["sh", "-c", "ls -d /sys/class/backlight/* | head -1"]
    stdout: StdioCollector { onStreamFinished: root.dir = text.trim() }
  }

  // blocks hardware readback for 1s after last scroll action
  Timer {
    id: settleTimer
    interval: 1000
    repeat: false
    onTriggered: current.reload()
  }

  FileView {
    path: root.dir ? `${root.dir}/max_brightness` : ""
    onLoaded: root.maxRaw = parseInt(text()) || 0
  }

  // inotify fires on any userspace write to the file (Fn keys, brightnessctl), so no polling
  FileView {
    id: current
    path: root.dir ? `${root.dir}/brightness` : ""
    watchChanges: true
    onFileChanged: if (!settleTimer.running) reload()
    onLoaded: if (!settleTimer.running) root.currentRaw = parseInt(text()) || 0
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
