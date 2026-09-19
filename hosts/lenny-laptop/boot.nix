{
  pkgs,
  lib,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "acpi_osi=Linux"
      # Prevent spurious wakeups from USB and network while suspended
      "usbcore.autosuspend=1"
    ];
    loader = {
      timeout = null;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    tmp.cleanOnBoot = true;

    # Unlock the encrypted swap partition (nvme1n1p3) alongside root in initrd.
    initrd.luks.devices."luks-c4dc5a27-dbce-4dce-84d7-edc4ca3adce5".device = "/dev/disk/by-uuid/c4dc5a27-dbce-4dce-84d7-edc4ca3adce5";
  };

  systemd.services.bluetooth-unblock = {
    description = "Unblock bluetooth via rfkill";
    wantedBy = ["bluetooth.service"];
    before = ["bluetooth.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/rfkill unblock bluetooth";
    };
  };

  zramSwap = {
    enable = lib.mkForce false;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Disk swap. Without it, a build that outgrew RAM had nowhere to spill and
  # thrashed the machine instead of failing.
  # mkForce overrides `swapDevices = []` in the generated hardware.nix.
  swapDevices = lib.mkForce [
    {
      device = "/dev/mapper/luks-c4dc5a27-dbce-4dce-84d7-edc4ca3adce5";
    }
  ];

  # Lid close → suspend; don't wake on lid-open from a bag
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleSuspendKey = "suspend";
    IdleAction = "ignore";
  };
}
