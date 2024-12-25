{ config, lib, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  /*boot.loader.systemd-boot.allowMismatchedLocales = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Allow dual boot with windows.";
  };
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  environment.systemPackages = with pkgs; [
    sbctl
  ];*/
}
