{
  pkgs,
  outputs,
  ...
}: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
    overlays = builtins.attrValues outputs.overlays;
  };

  time.timeZone = "Europe/Paris";

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = ["root" "lenny"];

  nix.settings.extra-substituters = [
    "https://nix-community.cachix.org/"
    "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr"
  ];
  nix.settings.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
    "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo="
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    zsh

    python314
    poetry
    docker-compose

    wget
    curl
    killall
    btop
    pciutils

    # Documentation
    man-pages
    man-pages-posix
  ];

  documentation.dev.enable = true;

  programs.zsh.enable = true;

  programs.nix-ld = {
    enable = true;
  };

  environment.shells = with pkgs; [bash zsh];

  environment.variables = {
    TERMINAL = "alacritty";
    EDITOR = "vim";
    VISUAL = "vim";
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}
