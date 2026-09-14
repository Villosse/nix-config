# Emacs entry point. Each topic lives in its own module (imported below) and
# contributes its own packages + elisp; home-manager merges `extraPackages`
# and concatenates `extraConfig` (ordered via `lib.mkOrder`) into one default.el.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./ui.nix # core UI, sane defaults, font, transparency   (order 200)
    ./theme.nix # theme, modeline, icons, which-key          (order 300)
    ./completion.nix # vertico family + corfu + cape          (order 500)
    ./editing.nix # expand-region, avy                        (order 500)
    ./vcs.nix # magit, projectile                             (order 500)
    ./ai.nix # copilot + copilot-chat                         (order 500)
    ./lsp.nix # eglot + language modes                        (order 500)
  ];

  programs.emacs = {
    enable = true;
    # pgtk = native Wayland: alpha-background transparency works (XWayland
    # doesn't composite it). GUI-only now, so pgtk's old TTY-renderer bug is
    # irrelevant (terminal editing is vim).
    package = pkgs.emacs-pgtk;

    # Packages not owned by a topic module: the use-package bootstrap and the
    # keycast HUD (shows keystrokes/commands — toggle with `M-x keycast-mode`).
    extraPackages = epkgs:
      with epkgs; [
        use-package
        keycast
      ];

    # Bootstrap: runs first (order 100) so every topic module's `use-package`
    # forms resolve. Packages come from Nix, so package.el is unused.
    extraConfig = lib.mkOrder 100 ''
      ;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

      ;; Packages are provided by Nix (see default.nix), so package.el is unused.
      (require 'use-package)
      (setq use-package-always-ensure nil)
    '';
  };

  # LSP servers must be on PATH for eglot. Since Emacs runs as a systemd
  # daemon, they need to be in home.packages (the daemon's environment),
  # not just an interactive shell.
  home.packages = with pkgs; [
    ocamlPackages.ocaml-lsp # OCaml
    nixd # Nix
    clang-tools # C / C++ (clangd)
    yaml-language-server # YAML
    tinymist # Typst
    pyright # Python
    copilot-language-server # GitHub Copilot agent (used by copilot.el)

    # Launch a GUI Emacs frame off the daemon. Named so bemenu-run (which lists
    # $PATH executables) finds it — search "emacs-gui" in the launcher.
    (writeShellScriptBin "emacs-gui" ''
      exec ${pkgs.emacs-pgtk}/bin/emacsclient -c -a emacs "$@"
    '')
  ];

  # Single background daemon; `emacsclient` connects instantly.
  # defaultEditor is false: TTY editing is vim now, GUI Emacs is launched via
  # `emacs-gui` (bemenu) or the `ec` alias.
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = false;
  };
}
