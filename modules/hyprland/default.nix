{ inputs, config, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
    wl-clipboard
    kitty
  ];
}
