{
  lib,
  config,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.ubuntuVm;

  monitorSock = "/tmp/stm32-vm-monitor.sock";
  pidFile = "/tmp/stm32-vm.pid";

  cloudImageUrl = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img";

  helperScript = pkgs.writeShellScriptBin "stm32-vm" ''
    set -euo pipefail

    DISK_PATH="${cfg.diskPath}"
    DISK_SIZE="${toString cfg.diskSizeGB}G"
    MEMORY="${toString cfg.memoryMiB}"
    CPUS="${toString cfg.cpuCores}"
    SSH_PORT="${toString cfg.sshPort}"
    MONITOR_SOCK="${monitorSock}"
    PID_FILE="${pidFile}"
    SEED_ISO="$(dirname "$DISK_PATH")/seed.iso"

    usage() {
      echo "Usage: stm32-vm <command> [args]"
      echo ""
      echo "Commands:"
      echo "  setup              Download cloud image, create seed, and start VM"
      echo "  start              Start the VM"
      echo "  stop               Gracefully shut down the VM (ACPI)"
      echo "  kill               Force kill the VM"
      echo "  status             Show VM status"
      echo "  ssh                Connect via waypipe ssh (forwards Wayland apps)"
      echo "  ssh-term           Connect via plain ssh (terminal only)"
      echo "  usb-attach VID:PID Attach USB device (e.g. 0483:374b)"
      echo "  usb-detach VID:PID Detach USB device"
      echo "  usb-list           List host USB devices"
      exit 1
    }

    monitor_cmd() {
      if [ ! -S "$MONITOR_SOCK" ]; then
        echo "Error: monitor socket not found. Is the VM running?" >&2
        return 1
      fi
      echo "$1" | ${pkgs.socat}/bin/socat - UNIX-CONNECT:"$MONITOR_SOCK"
    }

    build_qemu_args() {
      local args=(
        -machine q35
        -cpu host
        -enable-kvm
        -m "$MEMORY"
        -smp "$CPUS"
        -drive "file=$DISK_PATH,if=virtio,format=qcow2,discard=unmap"
        -drive "file=$SEED_ISO,if=virtio,format=raw"
        -display none
        -device qemu-xhci
        -usb
        -device virtio-balloon
        -nic "user,model=virtio,hostfwd=tcp::''${SSH_PORT}-:22"
        -monitor "unix:$MONITOR_SOCK,server,nowait"
        -pidfile "$PID_FILE"
        -daemonize
      )

      echo "''${args[@]}"
    }

    cmd_setup() {
      mkdir -p "$(dirname "$DISK_PATH")"

      if [ ! -f "$DISK_PATH" ]; then
        echo "Downloading Ubuntu 24.04 cloud image..."
        ${pkgs.wget}/bin/wget -O "$DISK_PATH" "${cloudImageUrl}"
        echo "Resizing disk to $DISK_SIZE..."
        ${pkgs.qemu}/bin/qemu-img resize "$DISK_PATH" "$DISK_SIZE"
      else
        echo "Disk already exists at $DISK_PATH"
      fi

      if [ ! -f "$SEED_ISO" ]; then
        echo "Creating cloud-init seed ISO..."

        CLOUD_INIT_DIR=$(mktemp -d)
        trap "rm -rf $CLOUD_INIT_DIR" EXIT

        cat > "$CLOUD_INIT_DIR/user-data" << 'USERDATA'
    #cloud-config
    password: ubuntu
    chpasswd:
      expire: false
    ssh_pwauth: true
    packages:
      - waypipe
      - openssh-server
    USERDATA

        cat > "$CLOUD_INIT_DIR/meta-data" << 'METADATA'
    instance-id: stm32-ubuntu
    local-hostname: stm32-ubuntu
    METADATA

        ${pkgs.cloud-utils}/bin/cloud-localds "$SEED_ISO" \
          "$CLOUD_INIT_DIR/user-data" \
          "$CLOUD_INIT_DIR/meta-data"

        echo "Seed ISO created at $SEED_ISO"
      else
        echo "Seed ISO already exists at $SEED_ISO"
      fi

      echo "Starting VM..."
      cmd_start
    }

    cmd_start() {
      if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "VM is already running (PID $(cat "$PID_FILE"))"
        return 1
      fi

      echo "Starting VM..."
      ${pkgs.qemu}/bin/qemu-system-x86_64 $(build_qemu_args)
      echo "VM started (PID $(cat "$PID_FILE"))"
      echo "SSH available on port $SSH_PORT (may take a minute for first boot)"
    }

    cmd_stop() {
      if [ ! -S "$MONITOR_SOCK" ]; then
        echo "VM is not running (no monitor socket)"
        return 1
      fi

      echo "Sending ACPI shutdown..."
      monitor_cmd "system_powerdown"

      # Wait up to 30s for graceful shutdown
      for i in $(seq 1 30); do
        if [ ! -f "$PID_FILE" ] || ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
          echo "VM stopped"
          rm -f "$PID_FILE" "$MONITOR_SOCK"
          return 0
        fi
        sleep 1
      done

      echo "Graceful shutdown timed out, force killing..."
      cmd_kill
    }

    cmd_kill() {
      if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
          kill -9 "$pid"
          echo "VM killed (PID $pid)"
        else
          echo "VM is not running"
        fi
        rm -f "$PID_FILE" "$MONITOR_SOCK"
      else
        echo "No PID file found"
      fi
    }

    cmd_status() {
      if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "VM is running (PID $(cat "$PID_FILE"))"
      else
        echo "VM is not running"
        rm -f "$PID_FILE"
      fi
    }

    cmd_ssh() {
      exec ${pkgs.waypipe}/bin/waypipe ssh -p "$SSH_PORT" ubuntu@localhost
    }

    cmd_ssh_term() {
      exec ssh -p "$SSH_PORT" ubuntu@localhost
    }

    cmd_usb_attach() {
      local vid pid
      vid="''${1%%:*}"
      pid="''${1##*:}"
      echo "Attaching USB device $vid:$pid..."
      monitor_cmd "device_add usb-host,vendorid=0x$vid,productid=0x$pid,id=usb-$vid-$pid"
    }

    cmd_usb_detach() {
      local vid pid
      vid="''${1%%:*}"
      pid="''${1##*:}"
      echo "Detaching USB device $vid:$pid..."
      monitor_cmd "device_del usb-$vid-$pid"
    }

    cmd_usb_list() {
      echo "=== Host USB devices ==="
      ${pkgs.usbutils}/bin/lsusb
    }

    case "''${1:-}" in
      setup)      cmd_setup ;;
      start)      cmd_start ;;
      stop)       cmd_stop ;;
      kill)       cmd_kill ;;
      status)     cmd_status ;;
      ssh)        cmd_ssh ;;
      ssh-term)   cmd_ssh_term ;;
      usb-attach) cmd_usb_attach "''${2:?Missing VID:PID argument}" ;;
      usb-detach) cmd_usb_detach "''${2:?Missing VID:PID argument}" ;;
      usb-list)   cmd_usb_list ;;
      *)          usage ;;
    esac
  '';
in {
  options.ubuntuVm = {
    enable = mkEnableOption "Ubuntu VM for STM32 development";

    vmName = mkOption {
      type = types.str;
      default = "stm32-ubuntu";
      description = "Name for the VM";
    };

    memoryMiB = mkOption {
      type = types.int;
      default = 4096;
      description = "Memory allocated to the VM in MiB";
    };

    cpuCores = mkOption {
      type = types.int;
      default = 4;
      description = "Number of CPU cores for the VM";
    };

    diskPath = mkOption {
      type = types.str;
      default = "/home/${username}/VM/stm32-ubuntu.qcow2";
      description = "Path to the VM disk image";
    };

    diskSizeGB = mkOption {
      type = types.int;
      default = 50;
      description = "Disk size in GB (for initial creation)";
    };

    sshPort = mkOption {
      type = types.int;
      default = 2222;
      description = "Host port forwarded to guest port 22 for SSH";
    };

    zramSwap = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable zram swap on the host for better memory management";
      };

      memoryPercent = mkOption {
        type = types.int;
        default = 50;
        description = "Percentage of RAM to use for zram swap";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.qemu
      pkgs.usbutils
      pkgs.socat
      pkgs.cloud-utils
      pkgs.waypipe
      helperScript
    ];

    zramSwap = mkIf cfg.zramSwap.enable {
      enable = true;
      algorithm = "zstd";
      memoryPercent = cfg.zramSwap.memoryPercent;
    };
  };
}
