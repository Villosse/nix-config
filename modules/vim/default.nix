{ pkgs, lib, ... }: {
  programs.vim = {
    enable = true;
    package = pkgs.vim;
  };
}
