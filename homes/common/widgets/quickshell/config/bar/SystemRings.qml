import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
  id: root

  implicitHeight: Theme.pillHeight
  implicitWidth: row.implicitWidth + 16
  radius: Theme.radius
  color: Theme.surface0

  property int cpuPct: 0
  property string cpuFreq: ""
  property int memPct: 0
  property string memUsed: ""
  property string memTotal: ""
  property int gpuPct: 0
  property int gpuTemp: 0
  property string gpuState: "error" // "on" | "idle" | "off" | "error"
  property real prevTotal: 0
  property real prevIdle: 0

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      cpuProc.running = true
      cpuFreqProc.running = true
      memProc.running = true
      gpuProc.running = true
    }
  }

  Process {
    id: cpuProc
    command: ["sh", "-c", "awk 'NR==1{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat"]
    stdout: SplitParser {
      onRead: data => {
        const p = data.trim().split(" ").map(Number)
        const idle = p[3] + p[4]
        const total = p.reduce((a, b) => a + b, 0)
        const dt = total - root.prevTotal
        const di = idle - root.prevIdle
        if (dt > 0) root.cpuPct = Math.round(((dt - di) / dt) * 100)
        root.prevTotal = total
        root.prevIdle = idle
      }
    }
  }

  Process {
    id: cpuFreqProc
    command: ["sh", "-c", "awk '{sum+=$1; n++} END{printf \"%.1f\", sum/n/1000000}' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null || echo \"\""]
    stdout: SplitParser {
      onRead: data => root.cpuFreq = data.trim()
    }
  }

  Process {
    id: memProc
    command: ["sh", "-c", "free -b | awk '/^Mem/{printf \"%d %d %d\", $3/$2*100, $3, $2}'"]
    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(" ").map(Number)
        if (parts.length >= 3) {
          root.memPct = parts[0]
          root.memUsed = (parts[1] / 1073741824).toFixed(1)
          root.memTotal = (parts[2] / 1073741824).toFixed(1)
        }
      }
    }
  }

  // nvidia-smi wakes the dGPU, and polling it every 2s would keep it out of RTD3 forever.
  // So only query when something other than sway (which always holds it for the HDMI port)
  // has /dev/nvidiaN open. A failing nvidia-smi (e.g. kernel module older than userspace
  // until reboot) gives "error".
  Process {
    id: gpuProc
    command: ["sh", "-c", "[ \"$(cat /sys/bus/pci/drivers/nvidia/0000:*/power/runtime_status 2>/dev/null)\" = suspended ] && { echo off; exit 0; }; find /proc/[0-9]*/fd -lname '/dev/nvidia[0-9]*' 2>/dev/null | cut -d/ -f3 | sort -u | sed 's|.*|/proc/&/comm|' | xargs -r cat 2>/dev/null | grep -qvx sway || { echo idle; exit 0; }; nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null"]
    stdout: StdioCollector { id: gpuOut }
    onExited: code => {
      const text = gpuOut.text.trim()
      if (text === "off" || text === "idle") {
        root.gpuState = text
        root.gpuPct = 0
        return
      }
      const parts = text.split(",").map(s => parseInt(s.trim()))
      const ok = code === 0 && parts.length >= 2 && !isNaN(parts[0])
      root.gpuState = ok ? "on" : "error"
      root.gpuPct = ok ? parts[0] : 0
      root.gpuTemp = ok ? parts[1] : 0
    }
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 6

    RingWidget {
      icon: ""
      value: root.cpuPct
      ringColor: Theme.peach
      tooltip: root.cpuFreq !== "" ? `CPU ${root.cpuPct}%  ${root.cpuFreq} GHz` : `CPU ${root.cpuPct}%`
    }

    RingWidget {
      icon: ""
      value: root.memPct
      ringColor: Theme.red
      tooltip: root.memUsed !== "" ? `RAM ${root.memUsed} / ${root.memTotal} Go` : `RAM ${root.memPct}%`
    }

    RingWidget {
      icon: ""
      value: root.gpuPct
      ringColor: root.gpuState === "on" ? Theme.rosewater : Theme.surface1
      label: ({ on: `${root.gpuPct}%`, idle: "0%", off: "off", error: "--" })[root.gpuState]
      tooltip: ({
        on: `GPU ${root.gpuPct}%  ${root.gpuTemp}°C`,
        idle: "GPU awake, no app using it",
        off: "GPU powered off (RTD3)",
        error: "GPU unavailable (driver mismatch? reboot)"
      })[root.gpuState]
    }
  }
}
