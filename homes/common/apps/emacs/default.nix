{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    # Wayland-native (pure GTK) build. Provides both a GUI window and
    # terminal use via `emacsclient -nw`.
    package = pkgs.emacs-pgtk;

    # Packages installed via Nix so they're available to init.el.
    extraPackages = epkgs:
      with epkgs; [
        use-package
      ];

    # Literal init.el kept in the repo, deployed by home-manager.
    extraConfig = builtins.readFile ./init.el;
  };

  # Run Emacs as a background daemon; `emacsclient` connects instantly.
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
  };
}
