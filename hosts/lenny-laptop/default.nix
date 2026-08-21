{
  pkgs,
  stateVersion,
  outputs,
  ...
}: {
  imports =
    [
      ./hardware.nix
      ./pkgslist.nix
      ./graphics.nix
      ./users.nix
      ./boot.nix
      ./virtualisation.nix
      ./networking.nix
      ./portals.nix
      ../common/system/grub
      ../common/system/sddm
      ../common/system/pipewire
      ../common/system/plymouth
      ../common/games/steam
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  nix.package = pkgs.nixVersions.latest;

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
    rounded-mgenplus
    fira-sans
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

  systemd.settings.Manager.RebootWatchdogSec = "0";

  system.stateVersion = stateVersion;
  services.usbmuxd.enable = true;
}
