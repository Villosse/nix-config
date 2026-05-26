import QtQuick

Rectangle {
  required property color pillColor
  required property color textColor

  implicitHeight: 28
  implicitWidth: timeText.implicitWidth + 32
  radius: 12
  color: pillColor

  Text {
    id: timeText
    anchors.centerIn: parent
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 14
    font.bold: true
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      const now = new Date()
      const h = String(now.getHours()).padStart(2, '0')
      const m = String(now.getMinutes()).padStart(2, '0')
      const d = String(now.getDate()).padStart(2, '0')
      const mo = String(now.getMonth() + 1).padStart(2, '0')
      const y = now.getFullYear()
      timeText.text = `${h}:${m}   ${d}/${mo}/${y}`
    }
  }
}
