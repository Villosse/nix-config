{
  inputs,
  pkgs,
  ...
}: {
  # List System Programs
  environment.systemPackages = with pkgs; [
    #Get things online
    wget
    curl
    git

    #Build tools
    cmake
    pkg-config
    meson
    appimage-run
    gnumake
    gcc
    gdb

    #Useful bin
    wl-clipboard
    grim
    slurp
    libnotify
    playerctl
    unrar
    pulseaudio
    # globalprotect-openconnect

    # Nix package bullshit
    nix-prefetch-git
    fd

    # Terminal utils
    btop
    lsd
    fastfetch
    tree
    ripgrep
    vim

    # User apps
    pavucontrol
    slack
    #discord
    wayshot
    komikku
    gimp
    firefox

    # VM
    qemu
    waypipe

    # Haskell
    ghc

    # ?
    noto-fonts-color-emoji
    adwaita-icon-theme
    where-is-my-sddm-theme

    direnv
    devenv

    # VHDL
    #    quartus-prime-lite
    #ghdl-llvm
    #surfer
    teams-for-linux
  ];

  programs = {
    xwayland.enable = true;
    dconf.enable = true;
    sway = {
      enable = true;
    };
    #    steam.gamescopeSession.enable = true;
  };
}
