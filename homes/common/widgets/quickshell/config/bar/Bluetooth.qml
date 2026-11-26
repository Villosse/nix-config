import QtQuick
import Quickshell.Bluetooth

BarPill {
  id: root
  button: true

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property bool on: adapter?.enabled ?? false
  readonly property var connected: Bluetooth.devices.values.filter(d => d.connected)
  readonly property var first: connected[0] ?? null

  // device battery is 0..1
  function label(d) {
    return d.name + (d.batteryAvailable ? ` ${Math.round(d.battery * 100)}%` : "")
  }

  visible: adapter !== null
  maxWidth: 220
  // paper's lavender is ink (a text color): on = plain cream, connected = the teal accent
  pillColor: !on ? Theme.surface1 : Theme.paper ? (first ? Theme.active : Theme.surface0) : first ? Theme.blue : Theme.lavender
  textColor: on ? Theme.base : Theme.text
  text: !on ? "󰂲" : first ? `󰂱 ${label(first)}${connected.length > 1 ? ` +${connected.length - 1}` : ""}` : "󰂯"
  tooltip: !on ? "Bluetooth off" : first ? connected.map(label).join("\n") : "No device connected"

  onClicked: if (adapter) adapter.enabled = !adapter.enabled
}
