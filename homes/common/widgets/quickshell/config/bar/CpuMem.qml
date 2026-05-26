import QtQuick
import QtQuick.Layouts
import Quickshell.Io

RowLayout {
  required property color cpuColor
  required property color memColor
  required property color textColor
  spacing: 4

  property int cpuPct: 0
  property int memPct: 0
  property real prevTotal: 0
  property real prevIdle: 0

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: { cpuProc.running = true; memProc.running = true }
  }

  Process {
    id: cpuProc
    command: ["sh", "-c", "awk 'NR==1{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat"]
    stdout: SplitParser {
      onRead: data => {
        const p = data.trim().split(" ").map(Number)
        const idle = p[3] + p[4]
        const total = p.reduce((a, b) => a + b, 0)
        const dt = total - prevTotal
        const di = idle - prevIdle
        if (dt > 0) cpuPct = Math.round(((dt - di) / dt) * 100)
        prevTotal = total
        prevIdle = idle
      }
    }
  }

  Process {
    id: memProc
    command: ["sh", "-c", "free | awk '/^Mem/{printf \"%d\", $3/$2*100}'"]
    stdout: SplitParser {
      onRead: data => memPct = parseInt(data.trim()) || 0
    }
  }

  Rectangle {
    implicitHeight: 28
    implicitWidth: cpuLabel.implicitWidth + 24
    radius: 12
    color: cpuColor
    Text {
      id: cpuLabel
      anchors.centerIn: parent
      text: ` ${cpuPct}%`
      color: textColor
      font.family: "IosevkaTerm Nerd Font"
      font.pixelSize: 13
      font.bold: true
    }
  }

  Rectangle {
    implicitHeight: 28
    implicitWidth: memLabel.implicitWidth + 24
    radius: 12
    color: memColor
    Text {
      id: memLabel
      anchors.centerIn: parent
      text: ` ${memPct}%`
      color: textColor
      font.family: "IosevkaTerm Nerd Font"
      font.pixelSize: 13
      font.bold: true
    }
  }
}
