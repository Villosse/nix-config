import QtQuick
import Quickshell.Io

Rectangle {
  required property color pillColor
  required property color textColor

  implicitHeight: 28
  implicitWidth: label.implicitWidth + 24
  radius: 12
  color: pillColor

  property string netInfo: "󰤯"

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: netProc.running = true
  }

  Process {
    id: netProc
    command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev | grep ':connected:' | head -1"]
    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(":")
        const type = parts[0]
        const conn = parts[2] ?? ""
        if (type === "wifi") netInfo = `󰤨 ${conn}`
        else if (type === "ethernet") netInfo = "󰈀"
        else netInfo = "󰤯"
      }
    }
    onExited: code => { if (code !== 0) netInfo = "󰤯" }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: netInfo
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 13
    font.bold: true
  }
}
