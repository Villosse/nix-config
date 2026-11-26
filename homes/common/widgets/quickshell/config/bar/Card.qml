import QtQuick

// Base surface of every pill and popup: ink outline and a hard shadow offset
// down-right in the paper look, a flat rounded rectangle otherwise.
Rectangle {
  radius: Theme.radius
  border.width: Theme.border
  border.color: Theme.ink

  // negative z draws it behind its parent
  Rectangle {
    z: -1
    x: Theme.shadow
    y: Theme.shadow
    width: parent.width
    height: parent.height
    radius: parent.radius
    color: Theme.ink
    visible: Theme.shadow > 0
  }
}
