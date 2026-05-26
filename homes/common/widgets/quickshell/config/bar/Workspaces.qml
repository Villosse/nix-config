import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
  id: root
  required property color surface0
  required property color surface1
  required property color mauve
  required property color lavender

  implicitHeight: 28
  radius: 12
  color: surface0
  implicitWidth: Math.max(row.implicitWidth + 16, 40)

  property var workspaces: []
  property int focusedNum: 1
  property string wsBuf: ""

  // Subscribe to workspace events
  Process {
    command: ["sh", "-c", "swaymsg -t subscribe '[\"workspace\"]' -m"]
    running: true
    stdout: SplitParser {
      onRead: _ => refreshWorkspaces.running = true
    }
  }

  // Fetch workspaces - collect full output then parse
  Process {
    id: refreshWorkspaces
    command: ["sh", "-c", "swaymsg -t get_workspaces"]
    running: true
    stdout: SplitParser {
      onRead: data => root.wsBuf += data
    }
    onExited: {
      try {
        const wss = JSON.parse(root.wsBuf)
        root.workspaces = wss.sort((a, b) => a.num - b.num)
        const fw = wss.find(w => w.focused)
        if (fw) root.focusedNum = fw.num
      } catch(e) {}
      root.wsBuf = ""
    }
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: root.workspaces
      delegate: Rectangle {
        required property var modelData
        implicitWidth: 28
        implicitHeight: 20
        radius: 8
        color: modelData.num === root.focusedNum ? root.mauve : root.surface1

        Text {
          anchors.centerIn: parent
          text: String(modelData.num)
          color: modelData.num === root.focusedNum ? "#24273a" : root.lavender
          font.family: "IosevkaTerm Nerd Font"
          font.pixelSize: 13
          font.bold: true
        }

        MouseArea {
          anchors.fill: parent
          onClicked: wsProc.running = true
          Process {
            id: wsProc
            command: ["swaymsg", "workspace", "number", String(modelData.num)]
          }
        }
      }
    }
  }
}
