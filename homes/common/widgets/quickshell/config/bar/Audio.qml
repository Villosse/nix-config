import QtQuick
import Quickshell.Services.Pipewire

BarPill {
  id: root
  pillColor: Theme.green

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property int vol: Math.round((sink?.audio?.volume ?? 0) * 100)
  readonly property bool muted: sink?.audio?.muted ?? true

  text: `${muted || vol === 0 ? "\u{F026}" : vol < 50 ? "\u{F027}" : "\u{F028}"} ${vol}%`
  tooltip: sink ? `${sink.description || sink.name}${muted ? " · muted" : ""}` : "No audio sink"

  // binds the sink so its audio properties are populated
  PwObjectTracker { objects: [root.sink] }

  onClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
  // same 150% ceiling as the volume Fn keys
  onWheel: delta => {
    if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1.5, (vol + delta) / 100))
  }
}
