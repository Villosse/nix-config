# Theme, modeline, icons, and which-key.
{lib, ...}: let
  # Startup theme: "paper" (the bar/terminal palette, ink background) or any
  # stock Catppuccin flavor ("macchiato", "mocha", ...). C-c t toggles
  # paper <-> macchiato at runtime.
  flavor = "paper";
in {
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
      :config
      ;; "paper": Catppuccin's face coverage with the paper palette (same as
      ;; rio and the quickshell bar), slot by slot from dark to light.
      (define-catppuccin-flavor-from 'macchiato 'paper
        '((crust . "#1d1c1a") (mantle . "#242320") (base . "#2b2a27")
          (surface0 . "#37352f") (surface1 . "#45423b") (surface2 . "#524e45")
          (overlay0 . "#6e6656") (overlay1 . "#7f7665") (overlay2 . "#908673")
          (subtext0 . "#b5ab92") (subtext1 . "#d9cfb0") (text . "#f3e9c6")
          (rosewater . "#e8d5b5") (flamingo . "#dba8b5") (pink . "#dba8b5")
          (mauve . "#9ad8c8") (red . "#e07a5f") (maroon . "#ec9a83")
          (peach . "#e3a35c") (yellow . "#d8a24a") (green . "#8fb996")
          (teal . "#7fc4b8") (sky . "#8cc0cf") (sapphire . "#6fa8b8")
          (blue . "#8cc0cf") (lavender . "#b6e6da")))
      (setq catppuccin-flavor '${flavor})
      (load-theme 'catppuccin :no-confirm)

      (defun my/theme-toggle ()
        "Switch between the paper palette and Catppuccin Macchiato."
        (interactive)
        (catppuccin-load-flavor (if (eq catppuccin-flavor 'paper) 'macchiato 'paper)))
      (keymap-global-set "C-c t" #'my/theme-toggle))

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
