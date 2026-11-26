import QtQuick

Card {
  id: root
  property color pillColor: Theme.surface0
  property color textColor: Theme.base
  property string text: ""
  property string tooltip: ""
  property real fontSize: Theme.fontSize
  property bool bold: true
  property int padding: 24
  property int maxWidth: 0
  // false: no hover feedback, tooltip or clicks (display-only pills)
  property bool interactive: true
  // paper: clickable pills are raised buttons (outline + shadow) that press down
  property bool button: false
  readonly property bool raised: Theme.paper && button
  readonly property bool hovered: mouse.containsMouse
  signal clicked
  signal rightClicked
  signal wheel(int delta)

  implicitHeight: Theme.chipHeight
  implicitWidth: maxWidth > 0 ? Math.min(label.implicitWidth + padding, maxWidth) : label.implicitWidth + padding
  radius: Theme.radius
  color: pillColor
  // paper: buttons, and any pill that isn't plain cream (a state chip), are outlined
  border.width: raised || Theme.paper && !Qt.colorEqual(pillColor, Theme.surface0) ? Theme.border : 0
  shadowed: raised && !mouse.pressed
  transform: Translate {
    x: root.raised && mouse.pressed ? Theme.shadow : 0
    y: root.raised && mouse.pressed ? Theme.shadow : 0
  }

  Behavior on color { ColorAnimation { duration: 300 } }
  Behavior on opacity { NumberAnimation { duration: 150 } }

  Text {
    id: label
    anchors.centerIn: parent
    width: Math.min(implicitWidth, root.width - root.padding)
    text: root.text
    color: root.textColor
    elide: Text.ElideRight
    font.family: Theme.font
    font.pixelSize: root.fontSize
    font.bold: root.bold
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: root.interactive
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: root.button ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: e => e.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    onWheel: e => { if (e.angleDelta.y !== 0) root.wheel(e.angleDelta.y > 0 ? 1 : -1) }
    onEntered: { if (!root.raised) root.opacity = 0.85; tip.show() }
    onExited: { root.opacity = 1.0; tip.hide() }
  }

  Tooltip {
    id: tip
    target: root
    text: root.tooltip
    accent: root.pillColor
  }
}
