{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelParams = ["acpi_osi=Linux"];
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
}
