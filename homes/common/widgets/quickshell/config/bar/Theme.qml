pragma Singleton

import QtQuick
import Quickshell

// Pick a look: "catppuccin" (Macchiato), "spooky" (moonlit pixel-art Halloween,
// matches assets/Wallpapers/spooky-pixel.png) or "paper" (neo-brutalist cream
// cards with ink outlines and hard shadows, same as the lockscreen) + shared bar metrics
Singleton {
  readonly property string look: "paper"
  readonly property bool spooky: look === "spooky"
  readonly property bool paper: look === "paper"

  // paper: every accent is the same cream card, only red keeps a meaning (low
  // battery, DND); ink is used for text, outlines and the rings
  readonly property var palettes: ({
    catppuccin: {
      base: "#24273a", surface0: "#363a4f", surface1: "#494d64", text: "#cad3f5",
      rosewater: "#f4dbd6", mauve: "#c6a0f6", pink: "#f5bde6", red: "#ed8796",
      peach: "#f5a97f", yellow: "#eed49f", green: "#a6da95", teal: "#8bd5ca",
      blue: "#8aadf4", lavender: "#b7bdf8"
    },
    spooky: {
      base: "#10151f", surface0: "#1f293b", surface1: "#2b3850", text: "#dfe3ea",
      rosewater: "#e6e2d3", mauve: "#8f7fc4", pink: "#c49ac9", red: "#c4545d",
      peach: "#d9834a", yellow: "#f0c477", green: "#8fae7a", teal: "#6fa9a8",
      blue: "#56698c", lavender: "#a9b4d6"
    },
    paper: {
      base: "#2b2a27", surface0: "#f3e9c6", surface1: "#e3d6aa", text: "#2b2a27",
      rosewater: "#2b2a27", mauve: "#f3e9c6", pink: "#2b2a27", red: "#e07a5f",
      peach: "#2b2a27", yellow: "#f3e9c6", green: "#f3e9c6", teal: "#f3e9c6",
      blue: "#f3e9c6", lavender: "#2b2a27"
    }
  })
  readonly property var p: palettes[look]

  readonly property color base:      p.base
  readonly property color surface0:  p.surface0
  readonly property color surface1:  p.surface1
  readonly property color text:      p.text
  readonly property color rosewater: p.rosewater
  readonly property color mauve:     p.mauve
  readonly property color pink:      p.pink
  readonly property color red:       p.red
  readonly property color peach:     p.peach
  readonly property color yellow:    p.yellow
  readonly property color green:     p.green
  readonly property color teal:      p.teal
  readonly property color blue:      p.blue
  readonly property color lavender:  p.lavender

  // focused workspace (and today in the calendar): an outlined soft teal
  // chip on paper, mauve elsewhere
  readonly property color active:   paper ? "#9ad8c8" : p.mauve
  readonly property color onActive: p.base

  // popups (tooltips, calendar): a cream card on paper, dark elsewhere
  readonly property color popup: paper ? p.surface0 : p.base
  readonly property color muted: paper ? "#8a8170" : p.surface1

  // Card outline and hard shadow; 0 keeps the flat pills of the other looks
  readonly property color ink: p.base
  readonly property int border: paper ? 2 : 0
  readonly property int shadow: paper ? 3 : 0

  readonly property string font: look === "catppuccin" ? "IosevkaTerm Nerd Font" : "DepartureMono Nerd Font"
  readonly property int fontSize: 13
  readonly property int pillHeight: 32
  readonly property int radius: paper ? 6 : 12
}
