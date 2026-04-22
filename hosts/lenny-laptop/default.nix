{
  pkgs,
  username,
  config,
  stateVersion,
  outputs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./pkgslist.nix
    ./graphics.nix
    ../common/system/grub
    ../common/system/sddm
    ../common/system/pipewire
    ../common/system/plymouth
    ../common/games/steam
  ]
  ++ (builtins.attrValues outputs.nixosModules);

  networking.hostName = "lenny-laptop";
  networking.networkmanager.enable = true;

  natHotspot = {
    enable = true;
    internalInterface = "enp3s0";
    externalInterface = "wlp4s0";
  };

  nix.package = pkgs.nixVersions.latest;

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    # virtualbox.host.enable = true;
  };

  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "root";
    permissions = "u+rx,g+x,o+x";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
    rounded-mgenplus
  ];

  displayManager = {
    theme = pkgs.sddm-theme;
    sway.enable = true;
  };

  ubuntuVm = {
    enable = true;
    memoryMiB = 2048;
    cpuCores = 4;
    diskSizeGB = 50;
  };

  users.users = {
    "${username}" = {
      isNormalUser = true;
      description = "${username}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "dialout"
        "libvirtd"
        "kvm"
      ];
      uid = 1000;
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
    "guest" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 5000;
      extraGroups = [ config.users.groups.users.name ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "acpi_osi=Linux"
    ];
    loader = {
      timeout = null;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
    # Steam games compatibility
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
  nix.settings = {
    substituters = [ "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr" ];
    trusted-public-keys = [ "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=" ];
  };

  systemd.settings.Manager.RebootWatchdogSec = "0";

  system.stateVersion = stateVersion;
}
