import QtQuick
import Quickshell.Io

Rectangle {
  required property color pillColor
  required property color textColor

  implicitHeight: 28
  implicitWidth: label.implicitWidth + 24
  radius: 12
  color: pillColor

  property string audioInfo: "\u{F026} 0%"

  property int currentVol: 0
  property int pending: 0

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: audioProc.running = true
  }

  FileView {
    path: "/tmp/qs-audio-refresh"
    watchChanges: true
    onFileChanged: audioProc.running = true
  }

  Process {
    id: audioProc
    command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1; pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'"]
    stdout: SplitParser {
      property int vol: 0
      property int lineIdx: 0
      onRead: data => {
        const line = data.trim()
        if (lineIdx === 0) vol = parseInt(line) || 0
        else {
          currentVol = vol
          const muted = line === "yes"
          const icon = muted || vol === 0 ? "\u{F026}" : vol < 33 ? "\u{F027}" : vol < 66 ? "\u{F027}" : "\u{F028}"
          audioInfo = `${icon} ${vol}%`
          lineIdx = -1
        }
        lineIdx++
      }
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: audioInfo
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 13
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: toggleProc.running = true
    onWheel: e => {
      if (e.angleDelta.y === 0) return
      pending += e.angleDelta.y > 0 ? 1 : -1
      if (!volProc.running) flushPending()
    }
  }

  function flushPending() {
    if (pending === 0) return
    const target = Math.max(0, Math.min(100, currentVol + pending))
    pending = 0
    currentVol = target
    const icon = target === 0 ? "\u{F026}" : target < 33 ? "\u{F027}" : "\u{F028}"
    audioInfo = `${icon} ${target}%`
    volProc.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", `${target}%`]
    volProc.running = true
  }

  Process {
    id: toggleProc
    command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    onRunningChanged: if (!running) audioProc.running = true
  }

  Process {
    id: volProc
    command: []
    onRunningChanged: {
      if (!running) {
        if (pending !== 0) flushPending()
        else audioProc.running = true
      }
    }
  }
}
