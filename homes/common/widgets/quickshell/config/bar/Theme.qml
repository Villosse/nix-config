pragma Singleton

import QtQuick
import Quickshell

// Pick a look: "catppuccin" (Macchiato), "spooky" (moonlit pixel-art Halloween,
// matches assets/Wallpapers/spooky-pixel.png) or "paper" (neo-brutalist cream
// cards with ink outlines and hard shadows, same as the lockscreen) or "rosepine"
// (the same neo-brutalist style in Rosé Pine Dawn colors) + shared bar metrics
Singleton {
  readonly property string look: "paper"
  readonly property bool spooky: look === "spooky"
  // the neo-brutalist style (strip, outlines, hard shadow), whatever its colors
  readonly property bool paper: look === "paper" || look === "rosepine"

  // paper: every accent is the same cream card, only red (the wallpaper's
  // coral) keeps a meaning: low battery, urgent workspace. Ink is used for
  // text, outlines and the rings. lock/shell.qml mirrors these values
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
      blue: "#f3e9c6", lavender: "#2b2a27",
      active: "#9ad8c8", muted: "#6e6656"
    },
    // https://rosepinetheme.com/palette — base #faf4ed, overlay #f2e9e1,
    // muted #9893a5, text #575279 as ink, love #b4637a; the active chip is a
    // pale rose (#ebbcba, Rosé Pine main) so it stays light
    rosepine: {
      base: "#575279", surface0: "#faf4ed", surface1: "#f2e9e1", text: "#575279",
      rosewater: "#575279", mauve: "#faf4ed", pink: "#575279", red: "#b4637a",
      peach: "#575279", yellow: "#faf4ed", green: "#faf4ed", teal: "#faf4ed",
      blue: "#faf4ed", lavender: "#575279",
      active: "#ebbcba", muted: "#9893a5", popup: "#fffaf3"
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

  // focused workspace (and today in the calendar): an outlined chip in the
  // look's accent, mauve when the look has none
  readonly property color active:   p.active ?? p.mauve
  readonly property color onActive: p.base

  // popups (tooltips, calendar): a cream card on paper, dark elsewhere
  readonly property color popup: p.popup ?? (paper ? p.surface0 : p.base)
  readonly property color muted: p.muted ?? p.surface1

  // Card outline and hard shadow; 0 keeps the flat pills of the other looks
  readonly property color ink: p.base
  readonly property int border: paper ? 2 : 0
  readonly property int shadow: paper ? 3 : 0

  readonly property string font: look === "catppuccin" ? "IosevkaTerm Nerd Font" : "DepartureMono Nerd Font"
  readonly property int fontSize: 13
  readonly property int pillHeight: 32
  readonly property int radius: paper ? 6 : 12
}
