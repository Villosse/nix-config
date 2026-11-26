// Lockscreen: flat paper cards with ink outlines and hard offset shadows over
// the wallpaper (clock, password, battery, network/uptime, media).
// Run standalone: quickshell -p ~/.config/quickshell/lock (sway binds it to Mod+x).
// Wallpaper comes from LOCK_WALLPAPER, set by the sway binding.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Services.UPower
import Quickshell.Services.Mpris

ShellRoot {
  id: root

  // same values as the bar's paper look (bar/Theme.qml), which this separate
  // instance can't import
  readonly property color paper: "#f3e9c6"
  readonly property color paperDark: "#e3d6aa"
  readonly property color ink: "#2b2a27"
  readonly property color inkDim: "#6e6656"
  readonly property color bad: "#e07a5f"
  // DepartureMono is drawn on an 11px grid: keep sizes multiples of 11
  readonly property string font: "DepartureMono Nerd Font"

  property date now: new Date()
  property string network: ""
  property real uptime: 0
  property bool capsLock: false
  // no dependencies, so evaluated once: when the lock started
  readonly property date lockedAt: new Date()
  property int failures: 0
  property bool failed: false
  signal rejected()

  readonly property UPowerDevice bat: UPower.displayDevice
  // sticky: pausing must not hand the card to another player (another tab)
  property MprisPlayer player: null
  function pickPlayer() {
    const players = Mpris.players.values
    const playing = players.find(p => p.isPlaying)
    if (playing) player = playing
    else if (!players.includes(player)) player = players[0] ?? null
  }

  Component.onCompleted: pickPlayer()

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      root.now = new Date()
      root.pickPlayer()
      capsProc.running = true
      if (root.now.getSeconds() % 15 === 0) sysProc.running = true
    }
  }

  // /proc/uptime, not `uptime -p`: sway's PATH has coreutils' uptime, which lacks -p
  Process {
    id: sysProc
    running: true
    command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev | grep -m1 -E '^(wifi|ethernet):connected:'; echo \"up:$(cut -d' ' -f1 /proc/uptime)\""]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")
        const up = lines.find(l => l.startsWith("up:"))
        const net = lines.find(l => !l.startsWith("up:"))?.split(":")
        root.uptime = up ? parseFloat(up.slice(3)) : 0
        root.network = net ? `${net[0] === "wifi" ? "\u{F05A9}" : "\u{F0200}"} ${net.slice(2).join(":")}` : "\u{F05AA} offline"
      }
    }
  }

  // any keyboard's LED, so an external keyboard counts too
  Process {
    id: capsProc
    command: ["sh", "-c", "cat /sys/class/leds/*::capslock/brightness"]
    stdout: StdioCollector {
      onStreamFinished: root.capsLock = text.split("\n").some(l => parseInt(l) > 0)
    }
  }

  PamContext {
    id: pam
    config: "swaylock"
    property string pending: ""
    onResponseRequiredChanged: if (responseRequired) { respond(pending); pending = "" }
    onCompleted: result => {
      if (result === PamResult.Success) {
        lock.locked = false
        Qt.quit()
      } else {
        root.failed = true
        root.failures++
        root.rejected()
      }
    }
  }

  function submit(pw) {
    if (pam.active || pw === "") return
    root.failed = false
    pam.pending = pw
    pam.start()
  }

  function duration(secs) {
    const d = Math.floor(secs / 86400), h = Math.floor(secs % 86400 / 3600), m = Math.floor(secs % 3600 / 60)
    if (!d && !h) return `${m}m`
    return (d ? `${d}d ` : "") + `${h}h${String(m).padStart(2, "0")}`
  }

  WlSessionLock {
    id: lock
    locked: true

    WlSessionLockSurface {
      color: "black"

      Image {
        anchors.fill: parent
        source: Quickshell.env("LOCK_WALLPAPER") ? "file://" + Quickshell.env("LOCK_WALLPAPER") : ""
        fillMode: Image.PreserveAspectCrop
      }

      Column {
        id: cluster
        anchors.centerIn: parent
        spacing: 28

        // Clock: one card per unit, like flip-clock tiles
        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 16

          Repeater {
            model: [["HH", "hours"], ["mm", "minutes"], ["ss", "seconds"]]

            Row {
              required property var modelData
              required property int index
              spacing: 16

              Card {
                width: 154
                height: 132

                Column {
                  anchors.centerIn: parent
                  Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(root.now, modelData[0])
                    font { family: root.font; pixelSize: 77 }
                    color: root.ink
                  }
                  Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData[1]
                    font { family: root.font; pixelSize: 11 }
                    color: root.inkDim
                  }
                }
              }

              Column {
                visible: index < 2
                anchors.verticalCenter: parent.verticalCenter
                spacing: 22
                // not a thrown card: fade in once the tiles have landed
                opacity: 0
                SequentialAnimation on opacity {
                  PauseAnimation { duration: 750 }
                  NumberAnimation { to: 1; duration: 250; easing.type: Easing.OutCubic }
                }
                Repeater {
                  model: 2
                  Rectangle { width: 12; height: 12; color: root.ink }
                }
              }
            }
          }
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 20

          // Password
          Card {
            id: pwCard
            width: 374
            height: 176

            Connections {
              target: root
              function onRejected() { shakeAnim.restart() }
            }
            SequentialAnimation {
              id: shakeAnim
              loops: 2
              NumberAnimation { target: pwCard; property: "shakeX"; to: -8; duration: 40 }
              NumberAnimation { target: pwCard; property: "shakeX"; to: 8; duration: 70 }
              NumberAnimation { target: pwCard; property: "shakeX"; to: 0; duration: 40 }
            }

            Column {
              anchors { fill: parent; margins: 22 }
              spacing: 16

              Row {
                spacing: 14
                Rectangle {
                  width: 44
                  height: 44
                  radius: 4
                  color: root.ink
                  Text {
                    anchors.centerIn: parent
                    text: (Quickshell.env("USER") ?? "?").charAt(0).toUpperCase()
                    font { family: root.font; pixelSize: 22 }
                    color: root.paper
                  }
                }
                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 4
                  Text {
                    text: Quickshell.env("USER") ?? ""
                    font { family: root.font; pixelSize: 22 }
                    color: root.ink
                  }
                  Text {
                    text: Qt.formatDate(root.now, "dddd d MMMM").toLowerCase()
                    font { family: root.font; pixelSize: 11 }
                    color: root.inkDim
                  }
                }
              }

              Rectangle {
                width: parent.width
                height: 44
                radius: 4
                color: root.paperDark
                border { width: 2; color: root.failed ? root.bad : root.ink }

                Text {
                  anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                  visible: input.text === ""
                  text: "\u{F033E} password"
                  font { family: root.font; pixelSize: 11 }
                  color: root.inkDim
                }
                TextInput {
                  id: input
                  anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                  verticalAlignment: TextInput.AlignVCenter
                  echoMode: TextInput.Password
                  passwordCharacter: "■"
                  cursorDelegate: Rectangle { width: 2; color: root.ink; visible: input.activeFocus }
                  font { family: root.font; pixelSize: 22 }
                  color: root.ink
                  selectionColor: root.ink
                  enabled: !pam.active
                  focus: true
                  onAccepted: { root.submit(text); text = "" }
                  onTextChanged: if (text !== "") root.failed = false
                }
              }

              Item {
                width: parent.width
                height: 22

                Text {
                  readonly property real since: (root.now - root.lockedAt) / 1000
                  anchors.verticalCenter: parent.verticalCenter
                  text: pam.active ? "checking..." : root.failures ? `${root.failures} failed attempt${root.failures > 1 ? "s" : ""}` : since < 60 ? "locked just now" : `locked for ${root.duration(since)}`
                  font { family: root.font; pixelSize: 11 }
                  color: root.failures && !pam.active ? root.bad : root.inkDim
                }
                Rectangle {
                  visible: root.capsLock
                  anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                  width: caps.implicitWidth + 12
                  height: 22
                  radius: 4
                  color: root.bad
                  Text {
                    id: caps
                    anchors.centerIn: parent
                    text: "\u{F0632} CAPS"
                    font { family: root.font; pixelSize: 11 }
                    color: root.paper
                  }
                }
              }
            }
          }

          Column {
            spacing: 20

            // Battery
            Card {
              id: batCard
              visible: root.bat?.isLaptopBattery ?? false
              width: 220
              height: 88

              readonly property int pct: Math.round((root.bat?.percentage ?? 0) * 100)
              readonly property bool charging: root.bat?.state === UPowerDeviceState.Charging
              readonly property bool low: pct <= 20 && !charging
              readonly property real secs: charging ? root.bat.timeToFull : root.bat?.timeToEmpty ?? 0

              Column {
                anchors { fill: parent; margins: 16 }
                spacing: 8
                Text {
                  text: `${batCard.charging ? "\u{F1E6}" : "\u{F240}"} ${batCard.pct}%`
                  font { family: root.font; pixelSize: 22 }
                  color: batCard.low ? root.bad : root.ink
                }
                // pixel segments, one per 10%
                Row {
                  spacing: 3
                  Repeater {
                    model: 10
                    Rectangle {
                      required property int index
                      width: 16
                      height: 8
                      color: index < Math.round(batCard.pct / 10) ? (batCard.low ? root.bad : root.ink) : root.paperDark
                    }
                  }
                }
                Text {
                  text: batCard.secs > 0 ? `${root.duration(batCard.secs)} ${batCard.charging ? "to full" : "left"}` : UPowerDeviceState.toString(root.bat?.state ?? 0).toLowerCase()
                  font { family: root.font; pixelSize: 11 }
                  color: root.inkDim
                }
              }
            }

            // Network + uptime
            Card {
              width: 220
              height: 88

              Column {
                anchors { fill: parent; margins: 16 }
                spacing: 10
                Text {
                  width: parent.width
                  elide: Text.ElideRight
                  text: root.network
                  font { family: root.font; pixelSize: 22 }
                  color: root.ink
                }
                Text {
                  text: "up " + root.duration(root.uptime)
                  font { family: root.font; pixelSize: 11 }
                  color: root.inkDim
                }
              }
            }
          }
        }
      }

      // Media: pinned to the screen bottom, outside the cluster so the cards
      // above don't shift when it hides
      Card {
        anchors { bottom: parent.bottom; bottomMargin: 56; horizontalCenter: parent.horizontalCenter }
        opacity: root.player ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        width: Math.min(parent.width - 96, 960)
        height: 148

        Row {
          anchors { fill: parent; margins: 18 }
          spacing: 22
          Rectangle {
            width: 112
            height: 112
            radius: 4
            color: root.ink

            Image {
              id: art
              anchors { fill: parent; margins: 3 }
              source: root.player?.trackArtUrl ?? ""
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              // keep the old cover until the new one is decoded, no black flash
              retainWhileLoading: true
            }
            // play state: the whole square without art, a corner badge over it
            Rectangle {
              readonly property bool badge: art.status === Image.Ready || art.status === Image.Loading
              anchors { right: parent.right; bottom: parent.bottom }
              width: badge ? 32 : parent.width
              height: badge ? 32 : parent.height
              radius: badge ? 2 : 4
              color: root.ink
              Text {
                anchors.centerIn: parent
                text: root.player?.isPlaying ? "\u{F03E4}" : "\u{F040A}"
                font { family: root.font; pixelSize: parent.badge ? 22 : 44 }
                color: root.paper
              }
            }
          }
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 134
            spacing: 8
            Text {
              width: parent.width
              elide: Text.ElideRight
              text: root.player?.trackTitle || "nothing playing"
              font { family: root.font; pixelSize: 33 }
              color: root.ink
            }
            Text {
              width: parent.width
              elide: Text.ElideRight
              text: [root.player?.trackArtist, root.player?.identity].filter(s => s).join(" · ")
              font { family: root.font; pixelSize: 22 }
              color: root.inkDim
            }
          }
        }
      }
    }
  }

  // paper card: ink outline and a hard, unblurred shadow offset down-right
  // Thrown onto the screen: each card flies in from off-screen in a random
  // direction, spinning, after a random short delay, and lands slightly tilted.
  component Card: Item {
    id: card
    default property alias content: face.data
    property real shakeX: 0

    readonly property real throwAngle: Math.random() * 2 * Math.PI
    readonly property real landTilt: (Math.random() - 0.5) * 3
    property real spin: (Math.random() - 0.5) * 50
    rotation: landTilt + spin
    transform: [
      Translate { id: toss; x: Math.cos(card.throwAngle) * 1600; y: Math.sin(card.throwAngle) * 1600 },
      Translate { x: card.shakeX }
    ]

    SequentialAnimation {
      running: true
      PauseAnimation { duration: Math.random() * 300 }
      ParallelAnimation {
        NumberAnimation { target: toss; properties: "x,y"; to: 0; duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
        NumberAnimation { target: card; property: "spin"; to: 0; duration: 600; easing.type: Easing.OutCubic }
      }
    }

    Rectangle {
      x: 6
      y: 6
      width: parent.width
      height: parent.height
      radius: 8
      color: root.ink
    }
    Rectangle {
      id: face
      anchors.fill: parent
      radius: 8
      color: root.paper
      border { width: 3; color: root.ink }
    }
  }
}
