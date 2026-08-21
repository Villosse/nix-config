{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    # Standard build (not pgtk): its terminal renderer is solid, so `e`
    # (emacsclient -t) doesn't get the ghost/duplicate-line corruption that
    # pgtk produces in a TTY. The GUI (`ec`) runs via XWayland — still fine.
    package = pkgs.emacs;

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

        # Completion stack (vertico family)
        vertico
        orderless
        consult
        marginalia
        corfu
        corfu-terminal # renders the corfu popup correctly in a TTY (emacsclient -t)
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
  ];

  # Single background daemon; `emacsclient` connects instantly.
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
  };
}
