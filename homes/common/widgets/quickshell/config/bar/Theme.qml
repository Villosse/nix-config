pragma Singleton

import QtQuick
import Quickshell

// Catppuccin Macchiato + shared bar metrics
Singleton {
  readonly property color base:      "#24273a"
  readonly property color surface0:  "#363a4f"
  readonly property color surface1:  "#494d64"
  readonly property color text:      "#cad3f5"
  readonly property color rosewater: "#f4dbd6"
  readonly property color mauve:     "#c6a0f6"
  readonly property color pink:      "#f5bde6"
  readonly property color red:       "#ed8796"
  readonly property color peach:     "#f5a97f"
  readonly property color yellow:    "#eed49f"
  readonly property color green:     "#a6da95"
  readonly property color teal:      "#8bd5ca"
  readonly property color blue:      "#8aadf4"
  readonly property color lavender:  "#b7bdf8"

  readonly property string font: "IosevkaTerm Nerd Font"
  readonly property int fontSize: 13
  readonly property int pillHeight: 28
  readonly property int radius: 12
}
