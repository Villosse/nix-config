{
  pkgs,
  outputs,
  inputs,
  username,
  stateVersion,
  ...
}: {
  imports =
    [
      inputs.sops-nix.homeManagerModules.sops

      ./nixpkgs.nix
      ./packages.nix
      ./displays.nix

      ../common/scripts

      ../common/apps/emacs
      ../common/apps/git
      ../common/apps/cava
      ../common/apps/fzf
      ../common/apps/rio
      ../common/apps/bash
      ../common/apps/zsh
      ../common/apps/direnv

      ../common/launchers/bemenu

      ../common/notifications/swaync

      ../common/windowManagers/sway

      ../common/widgets/gtk
      ../common/widgets/quickshell
      ../common/widgets/wlogout
      ../common/apps/ocaml
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  languages.ocaml.enable = true;

  mail = {
    enable = true;
    address = "lenny.chiadmi@gmail.com";
    realName = "Lenny Chiadmi-Delage";
  };

  manual.manpages.enable = false;
  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "lenny.chiadmi-delage";
      email = "lenny.chiadmi-delage@epita.fr";
    };
  };

  services.ssh-agent.enable = true;
  programs.home-manager.enable = true;
}
