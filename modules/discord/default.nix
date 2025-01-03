{ config, pkgs, lib, ... }:

{
  options.vesktop.enable = lib.mkEnableOption "Enable Vesktop";

  config = lib.mkIf config.vesktop.enable {
    environment.systemPackages = with pkgs; [ vesktop wlr-randr ];
  };
}
