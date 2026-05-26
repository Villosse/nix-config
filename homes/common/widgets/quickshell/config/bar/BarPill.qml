import QtQuick

Rectangle {
  id: root
  required property color color
  required property color textColor
  required property string text
  property real fontSize: 14
  signal clicked

  implicitHeight: 28
  implicitWidth: label.implicitWidth + 24
  radius: 12
  color: root.color

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    color: root.textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: root.fontSize
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
    hoverEnabled: true
    onEntered: root.opacity = 0.85
    onExited: root.opacity = 1.0
  }

  Behavior on opacity { NumberAnimation { duration: 150 } }
}
