{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.lenny.grub;
  themes = pkgs.callPackage ./themes.nix {};
in
{
  options.lenny.grub = { enable = mkEnableOption "grub"; };
  config = mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      enableCryptodisk = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      splashImage = null;
      theme = themes.fallout;

    };
  };
}
