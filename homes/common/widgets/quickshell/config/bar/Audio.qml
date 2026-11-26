import QtQuick
import Quickshell.Services.Pipewire

BarPill {
  id: root
  button: true
  // paper: muted is an "off" chip, like bluetooth off
  pillColor: muted && Theme.paper ? Theme.surface1 : Theme.green

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property int vol: Math.round((sink?.audio?.volume ?? 0) * 100)
  readonly property bool muted: sink?.audio?.muted ?? true

  // muted gets its own crossed speaker; 0% keeps the plain one
  text: `${muted ? "\u{F075F}" : vol === 0 ? "\u{F026}" : vol < 50 ? "\u{F027}" : "\u{F028}"} ${vol}%`
  tooltip: sink ? `${sink.description || sink.name}${muted ? " · muted" : ""}` : "No audio sink"

  // binds the sink so its audio properties are populated
  PwObjectTracker { objects: [root.sink] }

  onClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
  // same 150% ceiling as the volume Fn keys
  onWheel: delta => {
    if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1.5, (vol + delta) / 100))
  }
}
