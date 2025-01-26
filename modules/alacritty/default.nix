{ config, lib, ... }:
with lib;
let
  cfg = config.lenny.alacritty;
in
{
  options.lenny.alacritty = { enable = mkEnableOption "alacritty"; };
  config = mkIf cfg.enable {
    home.file.".config/alacritty" = {
      recursive = true;
      source = ./config;
    };

    programs.alacritty.enable = true;
  };
}
