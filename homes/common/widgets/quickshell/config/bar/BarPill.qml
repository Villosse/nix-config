import QtQuick

Rectangle {
  id: root
  property color pillColor: Theme.surface0
  property color textColor: Theme.base
  property string text: ""
  property string tooltip: ""
  property real fontSize: Theme.fontSize
  property bool bold: true
  property int padding: 24
  property int maxWidth: 0
  readonly property bool hovered: mouse.containsMouse
  signal clicked
  signal rightClicked
  signal wheel(int delta)

  implicitHeight: Theme.pillHeight
  implicitWidth: maxWidth > 0 ? Math.min(label.implicitWidth + padding, maxWidth) : label.implicitWidth + padding
  radius: Theme.radius
  color: pillColor

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
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    onClicked: e => e.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    onWheel: e => { if (e.angleDelta.y !== 0) root.wheel(e.angleDelta.y > 0 ? 1 : -1) }
    onEntered: { root.opacity = 0.85; tip.show() }
    onExited: { root.opacity = 1.0; tip.hide() }
  }

  Tooltip {
    id: tip
    target: root
    text: root.tooltip
    accent: root.pillColor
  }
}
