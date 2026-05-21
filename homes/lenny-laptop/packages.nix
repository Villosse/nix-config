{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.nixvim.packages.x86_64-linux.default
    nodejs_20
    yarn
    zulip
    obsidian
    docker-compose
    discord
  ];
}
