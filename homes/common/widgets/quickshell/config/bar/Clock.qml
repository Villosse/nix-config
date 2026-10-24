import QtQuick

BarPill {
  id: root
  pillColor: Theme.yellow
  fontSize: 14
  padding: 32

  property date now: new Date()
  // pill or popup under the pointer; the grace timer bridges the gap between them
  readonly property bool wanted: hovered || cal.popupHovered

  text: Qt.formatDateTime(now, "HH:mm   dd/MM/yyyy")

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  onWantedChanged: {
    if (wanted) { hideDelay.stop(); if (!cal.visible) showDelay.restart() }
    else { showDelay.stop(); hideDelay.restart() }
  }

  Timer { id: showDelay; interval: 400; onTriggered: cal.visible = true }
  Timer {
    id: hideDelay
    interval: 250
    onTriggered: { cal.visible = false; cal.reset() }
  }

  onWheel: delta => cal.shift(-delta)

  CalendarPopup {
    id: cal
    target: root
    today: root.now
  }
}
