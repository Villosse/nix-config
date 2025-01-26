{ pkgs
, username
, rootPath
, stateVersion
, ...
}:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  manual.manpages.enable = false;
  fonts.fontconfig.enable = true;

  lenny = {
    alacritty.enable = true;
    bemenu.enable = true;
    dunst.enable = true;
    gtk.enable = true;
    i3 = {
      enable = true;
      wallpaper = "${rootPath}/assets/Wallpapers/touhousa.png";
      barCmd = "polybar-msg cmd quit; polybar main 2>&1 | tee -a /tmp/polybar.log & disown";
    };
    mako.enable = true;
    nvim.enable = true;
    polybar.enable = true;
    zsh.enable = true;
  };

  lenny.git = {
    enable = true;
    editor = "nvim";
    username = "lenny.chiadmi-delage";
    email = "lenny.chiadmi-delage@epita.fr";
  };

  home = {
    packages = with pkgs; [
      lsd
      nerd-fonts.iosevka-term
    ];
  };

  services.ssh-agent.enable = true;
  programs.home-manager.enable = true;

  home.stateVersion = stateVersion;
}
