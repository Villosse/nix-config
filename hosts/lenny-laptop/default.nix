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
    # Full Nerd Font symbol set ("Symbols Nerd Font Mono") that nerd-icons uses
    # for its glyphs. IosevkaTerm's patch misses some (e.g. the .nix filetype
    # icon rendered as tofu); this covers the complete range.
    nerd-fonts.symbols-only
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
