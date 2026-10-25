pragma Singleton

import QtQuick
import Quickshell

// Catppuccin Macchiato, or a moonlit pixel-art Halloween palette when `spooky`
// (matches assets/Wallpapers/spooky-pixel.png) + shared bar metrics
Singleton {
  readonly property bool spooky: true

  readonly property color base:      spooky ? "#10151f" : "#24273a"
  readonly property color surface0:  spooky ? "#1f293b" : "#363a4f"
  readonly property color surface1:  spooky ? "#2b3850" : "#494d64"
  readonly property color text:      spooky ? "#dfe3ea" : "#cad3f5"
  readonly property color rosewater: spooky ? "#e6e2d3" : "#f4dbd6"
  readonly property color mauve:     spooky ? "#8f7fc4" : "#c6a0f6"
  readonly property color pink:      spooky ? "#c49ac9" : "#f5bde6"
  readonly property color red:       spooky ? "#c4545d" : "#ed8796"
  readonly property color peach:     spooky ? "#d9834a" : "#f5a97f"
  readonly property color yellow:    spooky ? "#f0c477" : "#eed49f"
  readonly property color green:     spooky ? "#8fae7a" : "#a6da95"
  readonly property color teal:      spooky ? "#6fa9a8" : "#8bd5ca"
  readonly property color blue:      spooky ? "#56698c" : "#8aadf4"
  readonly property color lavender:  spooky ? "#a9b4d6" : "#b7bdf8"

  readonly property string font: spooky ? "DepartureMono Nerd Font" : "IosevkaTerm Nerd Font"
  readonly property int fontSize: 13
  readonly property int pillHeight: 32
  readonly property int radius: 12
}
