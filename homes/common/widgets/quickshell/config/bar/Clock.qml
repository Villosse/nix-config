import QtQuick

BarPill {
  id: root
  pillColor: Theme.yellow
  fontSize: 14
  padding: 32

  property date now: new Date()

  text: Qt.formatDateTime(now, "HH:mm   dd/MM/yyyy")
  tooltip: Qt.formatDate(now, "dddd d MMMM yyyy")

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }
}
