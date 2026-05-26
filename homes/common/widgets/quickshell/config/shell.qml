//@ pragma UseQApplication
import QtQuick
import Quickshell
import "bar"

ShellRoot {
  Variants {
    model: Quickshell.screens

    delegate: Component {
      Bar {
        required property var modelData
        screen: modelData
      }
    }
  }
}
