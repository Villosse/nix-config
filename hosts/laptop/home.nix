{ pkgs
, stateVersion
, lib
, rootPath
, username
, ...
}:
{
  lenny = {
    alacritty.enable = true;
    bemenu.enable = true;
    firefox.enable = true;
    gtk.enable = true;
    hyprland = {
      enable = true;
      wallpaper = "${rootPath}/assets/Wallpapers/mario.gif";
    };
    mako.enable = true;
    nvim.enable = true;
    waybar.enable = true;
    zsh.enable = true;
  };

  lenny.git = {
    enable = true;
    editor = "nvim";
    username = "lenny.chiadmi-delage";
    email = "lenny.chiadmi-delage@epita.fr";
  };

  home = {
    inherit stateVersion;
    packages = with pkgs; [
      vivaldi
    ];
  };

  services.ssh-agent.enable = true;
  programs.home-manager.enable = true;
}
