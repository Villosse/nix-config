import QtQuick
import Quickshell.Io

Rectangle {
  required property color normalColor
  required property color chargingColor
  required property color warningColor
  required property color criticalColor
  required property color textColor

  property int pct: 100
  property bool charging: false

  implicitHeight: 28
  implicitWidth: label.implicitWidth + 24
  radius: 12
  color: charging ? chargingColor : pct <= 20 ? criticalColor : pct <= 30 ? warningColor : normalColor

  Behavior on color { ColorAnimation { duration: 300 } }

  Text {
    id: label
    anchors.centerIn: parent
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 13
    font.bold: true
    text: {
      const icon = charging ? "\u{F1E6}" : pct >= 90 ? "\u{F240}" : pct >= 70 ? "\u{F241}" : pct >= 40 ? "\u{F242}" : pct >= 20 ? "\u{F243}" : "\u{F244}"
      return `${icon} ${pct}%`
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: batProc.running = true
  }

  Process {
    id: batProc
    command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
    stdout: SplitParser {
      property int lineIdx: 0
      onRead: data => {
        const line = data.trim()
        if (lineIdx === 0) pct = parseInt(line) || 100
        else { charging = (line === "Charging" || line === "Full"); lineIdx = -1 }
        lineIdx++
      }
    }
  }
}
