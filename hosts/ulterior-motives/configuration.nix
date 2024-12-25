{ config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../homes/lenny/home.nix
    ../../modules/grub
    #../../modules/systemdboot
    ../../modules/hyprland
    ../../modules/sddm
    ../../modules/eww
  ];
  networking.networkmanager.enable = true;
  networking.hostName = "lennyAsNIX";
  environment.systemPackages = with pkgs; [];
  system.stateVersion = "25.05";
}