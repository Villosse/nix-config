import QtQuick
import Quickshell.Io

Rectangle {
  required property color pillColor
  required property color textColor

  implicitHeight: 28
  implicitWidth: label.implicitWidth + 24
  radius: 12
  color: pillColor

  property string gpuInfo: " ..."

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: gpuProc.running = true
  }

  Process {
    id: gpuProc
    command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null || cat /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input 2>/dev/null | awk '{printf \"%dC\", $1/1000}'"]
    stdout: SplitParser {
      onRead: data => {
        const line = data.trim()
        if (line.includes(",")) {
          const parts = line.split(",").map(s => s.trim())
          gpuInfo = ` ${parts[0]}% ${parts[1]}C`
        } else if (line !== "") {
          gpuInfo = ` ${line}`
        }
      }
    }
    onExited: code => { if (code !== 0 && gpuInfo === "") gpuInfo = "" }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: gpuInfo
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 13
    font.bold: true
  }
}
