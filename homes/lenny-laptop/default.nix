{
  pkgs,
  rootPath,
  outputs,
  username,
  stateVersion,
  ...
}:
{
  imports = [
    ./nixpkgs.nix
    ./packages.nix

    ../common/scripts

    ../common/apps/git
    ../common/apps/cava
    ../common/apps/fzf
    ../common/apps/ghostty
    ../common/apps/tmux
    ../common/apps/zsh

    ../common/launchers/bemenu

    ../common/notifications/swaync

    ../common/windowManagers/sway

    ../common/widgets/gtk
    ../common/widgets/waybar
    ../common/widgets/wlogout
  ]
  ++ (builtins.attrValues outputs.homeManagerModules);

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  manual.manpages.enable = false;
  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "lenny.chiadmi-delage";
      email = "lenny.chiadmi-delage@epita.fr";
    };
  };

  windowManager = {
    wallpaper = "${rootPath}/assets/Wallpapers/quotidien.png";
    lockscreen = "${rootPath}/assets/Wallpapers/guitarGirlOnAtower.png";
    primaryDisplay = {
      port = "eDP-1";
      scale = 1.5;
      width = 2560;
      height = 1600;
      refreshRate = 120;
    };
    secondaryDisplay = {
      port = "HDMI-A-1";
      scale = 1;
      x = 1920;
      y = 0;
      transform = 0;
    };
  };

  services.ssh-agent.enable = true;
  programs.home-manager.enable = true;
}
