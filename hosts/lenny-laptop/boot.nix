{pkgs, ...}: {
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
  };

  # Compressed swap — reduces RAM pressure without a swap partition
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Lid close → suspend; don't wake on lid-open from a bag
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleSuspendKey = "suspend";
    IdleAction = "ignore";
  };
}
