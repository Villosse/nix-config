# Theme, modeline, icons, and which-key.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      catppuccin-theme
      doom-modeline
      nerd-icons
      rainbow-delimiters
      which-key
    ];

  programs.emacs.extraConfig = lib.mkOrder 300 ''
    ;;; Theme + modeline ----------------------------------------------------------
    (use-package catppuccin-theme
      :init
      (setq catppuccin-flavor 'macchiato)   ; matches your btop/dunst theme
      :config
      (load-theme 'catppuccin :no-confirm))

    (use-package nerd-icons
      :custom
      ;; Use the dedicated symbol font (nerd-fonts.symbols-only) so all icons
      ;; render — IosevkaTerm's Nerd patch misses some (e.g. the .nix filetype icon).
      (nerd-icons-font-family "Symbols Nerd Font Mono"))

    (use-package doom-modeline
      :init (doom-modeline-mode 1)
      :custom (doom-modeline-height 28))

    (use-package rainbow-delimiters
      :hook (prog-mode . rainbow-delimiters-mode))

    (use-package which-key
      :init (which-key-mode)
      :custom (which-key-idle-delay 0.3))
  '';
}
