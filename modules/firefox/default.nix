{ lib, config, ... }:
with lib;
let
  cfg = config.lenny.firefox;
in
{
  options.lenny.firefox = { enable = mkEnableOption "firefox"; };
  config = mkIf cfg.enable {
    programs.firefox.enable = true;
  };
}
