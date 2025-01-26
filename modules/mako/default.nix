{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.lenny.mako;
in
{
  options.lenny.mako = { enable = mkEnableOption "mako"; };
  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      anchor = "top-right";
      defaultTimeout = 10000;
    };
  };
}
