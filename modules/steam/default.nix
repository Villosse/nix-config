{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.lenny.steam;
in
{
  options.lenny.steam = { enable = mkEnableOption "steam"; };
  config = mkIf cfg.enable {
    # Steam Configuration
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
