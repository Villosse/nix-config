import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// Month calendar shown below its target. Scroll or the arrows change month, the title resets.
PopupWindow {
  id: root
  required property Item target
  property date today: new Date()
  property int month: today.getMonth()
  property int year: today.getFullYear()
  readonly property bool popupHovered: hover.hovered
  readonly property int cell: 30

  anchor.item: target
  anchor.edges: Edges.Bottom
  anchor.gravity: Edges.Bottom
  anchor.margins.top: 6
  anchor.rect.x: (target.width - implicitWidth) / 2

  implicitWidth: content.implicitWidth + 24
  implicitHeight: content.implicitHeight + 20
  color: "transparent"

  function shift(n) {
    const d = new Date(year, month + n, 1)
    month = d.getMonth()
    year = d.getFullYear()
  }
  function reset() {
    month = today.getMonth()
    year = today.getFullYear()
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.base
    border.color: Theme.yellow
    border.width: 1
    radius: 6

    HoverHandler { id: hover }
    WheelHandler {
      onWheel: e => { if (e.angleDelta.y !== 0) root.shift(e.angleDelta.y > 0 ? -1 : 1) }
    }

    ColumnLayout {
      id: content
      anchors.centerIn: parent
      spacing: 6

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "\u{F0141}"
          color: Theme.lavender
          font.family: Theme.font
          font.pixelSize: 16
          TapHandler { onTapped: root.shift(-1) }
        }
        Text {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
          color: Theme.text
          font.family: Theme.font
          font.pixelSize: 14
          font.bold: true
          font.capitalization: Font.Capitalize
          TapHandler { onTapped: root.reset() }
        }
        Text {
          text: "\u{F0142}"
          color: Theme.lavender
          font.family: Theme.font
          font.pixelSize: 16
          TapHandler { onTapped: root.shift(1) }
        }
      }

      GridLayout {
        columns: 2
        columnSpacing: 4
        rowSpacing: 2

        Item { width: 1; height: 1 }

        DayOfWeekRow {
          locale: Qt.locale()
          spacing: 0
          Layout.preferredWidth: root.cell * 7
          delegate: Text {
            required property string shortName
            text: shortName.slice(0, 2)
            horizontalAlignment: Text.AlignHCenter
            color: Theme.lavender
            font.family: Theme.font
            font.pixelSize: 12
            font.bold: true
          }
        }

        WeekNumberColumn {
          month: root.month
          year: root.year
          locale: Qt.locale()
          spacing: 0
          Layout.preferredHeight: root.cell * 6
          delegate: Text {
            required property int weekNumber
            text: weekNumber
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.surface1
            font.family: Theme.font
            font.pixelSize: 11
          }
        }

        MonthGrid {
          month: root.month
          year: root.year
          locale: Qt.locale()
          spacing: 0
          Layout.preferredWidth: root.cell * 7
          Layout.preferredHeight: root.cell * 6
          delegate: Rectangle {
            required property var model
            readonly property bool isToday: model.day === root.today.getDate()
              && model.month === root.today.getMonth()
              && model.year === root.today.getFullYear()
            radius: height / 2
            color: isToday ? Theme.yellow : "transparent"

            Text {
              anchors.centerIn: parent
              text: parent.model.day
              color: parent.isToday ? Theme.base : parent.model.month === root.month ? Theme.text : Theme.surface1
              font.family: Theme.font
              font.pixelSize: 12
              font.bold: parent.isToday
            }
          }
        }
      }
    }
  }
}
