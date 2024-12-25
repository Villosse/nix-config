{ config, pkgs, ... }:
let
  themes = pkgs.callPackage ./themes.nix {};
in
{
  environment.systemPackages = [
    pkgs.libsForQt5.qt5.qtgraphicaleffects
    themes.astronaut
  ];
  services.displayManager = 
  {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "astronaut";
      settings.Theme.CursorTheme = "Bibata-Modern-Classic";
    };
  };
}
