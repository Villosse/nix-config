import QtQuick
import Quickshell.Io

Rectangle {
  required property color pillColor
  required property color textColor

  implicitHeight: 28
  implicitWidth: Math.min(title.implicitWidth + 24, 280)
  radius: 12
  color: pillColor
  visible: windowTitle !== ""

  property string windowTitle: ""

  Process {
    command: ["sh", "-c", "swaymsg -t subscribe '[\"window\",\"workspace\"]' -m"]
    running: true
    stdout: SplitParser {
      onRead: _ => refreshTitle.running = true
    }
  }

  Process {
    id: refreshTitle
    running: true
    command: ["sh", "-c", "swaymsg -t get_tree | python3 -c \"import sys,json; t=json.load(sys.stdin); f=lambda n: n.get('name','') if n.get('focused') else next((f(c) for c in n.get('nodes',[])+n.get('floating_nodes',[]) if f(c)), ''); print(f(t))\""]
    stdout: SplitParser {
      onRead: data => windowTitle = data.trim()
    }
  }

  Text {
    id: title
    anchors.centerIn: parent
    text: windowTitle
    color: textColor
    font.family: "IosevkaTerm Nerd Font"
    font.pixelSize: 13
    font.bold: false
    elide: Text.ElideRight
    width: parent.implicitWidth - 24
    horizontalAlignment: Text.AlignHCenter
  }
}
