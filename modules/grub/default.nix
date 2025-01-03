{ config, pkgs, ... }:
let
  themes = pkgs.callPackage ./themes.nix {};
in
{

  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    splashImage = null;
    efiInstallAsRemovable = true;
    
    theme = themes.fallout;
  };
}
