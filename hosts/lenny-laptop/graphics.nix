{
  pkgs,
  config,
  ...
}: let
  nvidia-bus-id = "PCI:1:0:0";
  amd-bus-id = "PCI:7:0:0";
in {
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "${amd-bus-id}";
      nvidiaBusId = "${nvidia-bus-id}";
    };
  };
}
