{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    eww
  ];
}
