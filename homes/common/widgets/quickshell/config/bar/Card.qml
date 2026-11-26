import QtQuick

// Base surface of every pill and popup: ink outline and a hard shadow offset
// down-right in the paper look, a flat rounded rectangle otherwise.
Rectangle {
  // horizontal shadow offset; 0 for edge-to-edge surfaces, or the shadow leaves a notch
  property int shadowX: Theme.shadow
  // false hides the shadow, e.g. while a button is pressed down into it
  property bool shadowed: true

  radius: Theme.radius
  border.width: Theme.border
  border.color: Theme.ink

  // negative z draws it behind its parent
  Rectangle {
    z: -1
    x: parent.shadowX
    y: Theme.shadow
    width: parent.width
    height: parent.height
    radius: parent.radius
    color: Theme.ink
    visible: parent.shadowed && Theme.shadow > 0
  }
}
