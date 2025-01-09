{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    flake = /home/lenny/myconf;
  };
}
