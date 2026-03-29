{
  inputs,
  pkgs,
  ...
}:
{
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
    neofetch
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
    blueberry
    firefox

    # VM
    qemu
    waypipe
    virt-viewer

    # Haskell
    ghc

    # ?
    noto-fonts-color-emoji
    adwaita-icon-theme
    where-is-my-sddm-theme
  ];

  programs = {
    xwayland.enable = true;
    dconf.enable = true;
    sway = {
      enable = true;
    };
    steam.gamescopeSession.enable = true;
  };
}
