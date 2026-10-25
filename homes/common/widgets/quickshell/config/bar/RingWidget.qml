import QtQuick

Item {
  id: root
  required property color ringColor
  required property string icon
  required property int value  // 0-100
  property string label: value + "%"
  property string tooltip: ""

  implicitWidth: Theme.pillHeight
  implicitHeight: Theme.pillHeight

  Canvas {
    id: canvas
    anchors.fill: parent

    onPaint: {
      const ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)

      const cx = width / 2
      const cy = height / 2
      const r = Math.min(width, height) / 2 - 2
      const startAngle = -Math.PI / 2
      const endAngle = startAngle + (2 * Math.PI * root.value / 100)

      ctx.beginPath()
      ctx.arc(cx, cy, r, 0, 2 * Math.PI)
      ctx.strokeStyle = Theme.surface0
      ctx.lineWidth = 3
      ctx.stroke()

      if (root.value > 0) {
        ctx.beginPath()
        ctx.arc(cx, cy, r, startAngle, endAngle)
        ctx.strokeStyle = root.ringColor
        ctx.lineWidth = 3
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
      font.family: Theme.font
      font.pixelSize: 11
      font.bold: true
    }

    Text {
      text: root.label
      color: root.ringColor
      font.family: Theme.font
      font.pixelSize: 11
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: tip.show()
    onExited: tip.hide()
  }

  Tooltip {
    id: tip
    target: root
    text: root.tooltip
    accent: root.ringColor
  }

  onValueChanged: canvas.requestPaint()
  onRingColorChanged: canvas.requestPaint()
}
