import QtQuick
import Quickshell.Io

Rectangle {
  required property color pillColor
  required property color textColor

  implicitHeight: 28
  implicitWidth: label.implicitWidth + 24
  radius: 12
  color: pillColor

  property string brightnessInfo: "󰃞 0%"
  property int maxRaw: 0
  property int currentRaw: 0
  property int pending: 0

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
    onFileChanged: if (!settleTimer.running) brightnessProc.running = true
  }

  Process {
    id: brightnessProc
    command: ["sh", "-c", "brightnessctl -m | awk -F, '{print $3, $5}'"]
    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(" ")
        if (parts.length < 2) return
        const cur = parseInt(parts[0])
        const mx  = parseInt(parts[1])
        if (!mx) return
        maxRaw = mx
        currentRaw = cur
        const pct = Math.round(cur / mx * 100)
        const icon = pct < 25 ? "󰃞" : pct < 50 ? "󰃟" : "󰃠"
        brightnessInfo = `${icon} ${pct}%`
      }
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: brightnessInfo
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 13
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    onWheel: e => {
      if (!maxRaw || e.angleDelta.y === 0) return
      pending += e.angleDelta.y > 0 ? 1 : -1
      settleTimer.restart()
      if (!brightProc.running) flushPending()
    }
  }

  function flushPending() {
    if (pending === 0 || !maxRaw) return
    const targetPct = Math.max(0, Math.min(100, Math.round(currentRaw / maxRaw * 100) + pending))
    pending = 0
    currentRaw = Math.round(targetPct / 100 * maxRaw)
    const icon = targetPct < 25 ? "󰃞" : targetPct < 50 ? "󰃟" : "󰃠"
    brightnessInfo = `${icon} ${targetPct}%`
    brightProc.command = ["brightnessctl", "set", String(currentRaw), "-q"]
    brightProc.running = true
  }

  Process {
    id: brightProc
    command: []
    onRunningChanged: {
      if (!running && pending !== 0) flushPending()
    }
  }
}
