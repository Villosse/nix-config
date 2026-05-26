import QtQuick

Item {
  id: root
  required property color ringColor
  required property string icon
  required property int value  // 0-100
  property string tooltip: ""

  implicitWidth: 36
  implicitHeight: 36

  property bool hovered: false

  Rectangle {
    id: tooltipBox
    visible: hovered && tooltip !== ""
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.top
    anchors.bottomMargin: 6
    color: "#24273a"
    border.color: ringColor
    border.width: 1
    radius: 6
    width: tooltipText.implicitWidth + 16
    height: tooltipText.implicitHeight + 8
    z: 100

    Text {
      id: tooltipText
      anchors.centerIn: parent
      text: root.tooltip
      color: "#cad3f5"
      font.family: "IosevkaTerm Nerd Font"
      font.pixelSize: 12
    }
  }

  Canvas {
    id: canvas
    anchors.fill: parent

    onPaint: {
      const ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)

      const cx = width / 2
      const cy = height / 2
      const r = Math.min(width, height) / 2 - 3
      const startAngle = -Math.PI / 2
      const endAngle = startAngle + (2 * Math.PI * root.value / 100)

      ctx.beginPath()
      ctx.arc(cx, cy, r, 0, 2 * Math.PI)
      ctx.strokeStyle = "#363a4f"
      ctx.lineWidth = 4
      ctx.stroke()

      if (root.value > 0) {
        ctx.beginPath()
        ctx.arc(cx, cy, r, startAngle, endAngle)
        ctx.strokeStyle = root.ringColor
        ctx.lineWidth = 4
        ctx.lineCap = "round"
        ctx.stroke()
      }
    }
  }

  Row {
    anchors.centerIn: parent
    spacing: 1

    Text {
      text: root.icon
      color: root.ringColor
      font.family: "IosevkaTerm Nerd Font"
      font.pixelSize: 11
      font.bold: true
    }

    Text {
      text: root.value + "%"
      color: root.ringColor
      font.family: "IosevkaTerm Nerd Font"
      font.pixelSize: 11
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.hovered = true
    onExited: root.hovered = false
  }

  onValueChanged: canvas.requestPaint()
}
