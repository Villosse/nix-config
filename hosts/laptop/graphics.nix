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
    # RTD3: the dGPU powers off when nothing is using it (needs prime.offload).
    powerManagement.finegrained = true;
    # NVIDIA's recommended kernel modules for Turing and newer (RTX 4050 = Ada).
    open = true;
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
