import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
  id: root

  implicitHeight: 36
  implicitWidth: row.implicitWidth + 16
  radius: 12
  color: "#363a4f"

  property int cpuPct: 0
  property string cpuFreq: ""
  property int memPct: 0
  property string memUsed: ""
  property string memTotal: ""
  property int gpuPct: 0
  property int gpuTemp: 0
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

  Process {
    id: gpuProc
    command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null"]
    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(",").map(s => parseInt(s.trim()))
        if (parts.length >= 2) { root.gpuPct = parts[0]; root.gpuTemp = parts[1] }
      }
    }
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 6

    RingWidget {
      icon: ""
      value: root.cpuPct
      ringColor: "#f5a97f"
      tooltip: root.cpuFreq !== "" ? `CPU ${root.cpuPct}%  ${root.cpuFreq} GHz` : `CPU ${root.cpuPct}%`
    }

    RingWidget {
      icon: ""
      value: root.memPct
      ringColor: "#ed8796"
      tooltip: root.memUsed !== "" ? `RAM ${root.memUsed} / ${root.memTotal} Go` : `RAM ${root.memPct}%`
    }

    RingWidget {
      icon: ""
      value: root.gpuPct
      ringColor: "#f4dbd6"
      tooltip: `GPU ${root.gpuPct}%  ${root.gpuTemp}°C`
      visible: root.gpuPct > 0 || root.gpuTemp > 0
    }
  }
}
