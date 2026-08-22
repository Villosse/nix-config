{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    # pgtk = native Wayland: alpha-background transparency works (XWayland
    # doesn't composite it). GUI-only now, so pgtk's old TTY-renderer bug is
    # irrelevant (terminal editing is vim).
    package = pkgs.emacs-pgtk;

    # Packages installed via Nix so they're available to init.el.
    extraPackages = epkgs:
      with epkgs; [
        use-package

        # Theme + UI
        catppuccin-theme
        doom-modeline
        nerd-icons
        rainbow-delimiters
        which-key
        dashboard # startup splash / home screen
        page-break-lines # pretty section dividers for dashboard

        # Completion stack (vertico family)
        vertico
        orderless
        consult
        marginalia
        corfu
        cape
        nerd-icons-completion
        nerd-icons-corfu

        # Editing niceties
        expand-region
        avy

        # Project / VCS
        magit
        projectile

        # AI
        copilot # inline ghost-text suggestions
        copilot-chat # chat buffer

        # LSP + language major-modes
        eglot
        tuareg # OCaml
        dune
        nix-mode
        markdown-mode
        yaml-mode
        typst-ts-mode # Typst
        paredit # structured Lisp editing
        sly # Common Lisp REPL/IDE
        treesit-grammars.with-all-grammars
      ];

    # Literal init.el kept in the repo, deployed by home-manager.
    extraConfig = builtins.readFile ./init.el;
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
