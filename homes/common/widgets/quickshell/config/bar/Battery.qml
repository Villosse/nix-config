import QtQuick
import Quickshell.Services.UPower

BarPill {
  id: root

  readonly property UPowerDevice bat: UPower.displayDevice
  // UPower reports 0..1
  readonly property int pct: bat?.ready ? Math.round(bat.percentage * 100) : 100
  readonly property bool charging: bat?.state === UPowerDeviceState.Charging || bat?.state === UPowerDeviceState.FullyCharged
  readonly property real secs: bat?.state === UPowerDeviceState.Charging ? bat.timeToFull : bat?.timeToEmpty ?? 0

  pillColor: charging ? Theme.green : pct <= 20 ? Theme.red : pct <= 30 ? Theme.yellow : Theme.mauve
  text: {
    const icon = charging ? "\u{F1E6}" : pct >= 90 ? "\u{F240}" : pct >= 70 ? "\u{F241}" : pct >= 40 ? "\u{F242}" : pct >= 20 ? "\u{F243}" : Theme.spooky ? "\u{F068C}" : "\u{F244}"
    return `${icon} ${pct}%`
  }
  tooltip: {
    if (!bat?.ready) return "No battery (is upower running?)"
    const state = UPowerDeviceState.toString(bat.state)
    if (secs <= 0) return state
    const h = Math.floor(secs / 3600), m = Math.floor(secs % 3600 / 60)
    return `${state} · ${h}h${String(m).padStart(2, "0")} ${bat.state === UPowerDeviceState.Charging ? "to full" : "left"}`
  }
}
