# Theme, modeline, icons, which-key, and the startup dashboard.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      catppuccin-theme
      doom-modeline
      nerd-icons
      rainbow-delimiters
      which-key
      dashboard # startup splash / home screen
      page-break-lines # pretty section dividers for dashboard
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

    ;;; Dashboard (startup home screen) -------------------------------------------
    (use-package dashboard
      :after nerd-icons
      :init
      (dashboard-setup-startup-hook)
      :custom
      (dashboard-banner-logo-title "Welcome back, Lenny")
      (dashboard-startup-banner 'logo)          ; use the Emacs logo
      (dashboard-center-content t)
      (dashboard-vertically-center-content t)
      (dashboard-set-heading-icons t)
      (dashboard-set-file-icons t)
      (dashboard-icon-type 'nerd-icons)
      (dashboard-display-icons-p t)
      (dashboard-projects-backend 'projectile)
      (dashboard-items '((recents   . 5)
                         (projects  . 5)
                         (bookmarks . 5)))
      :config
      ;; Show the dashboard for `emacsclient` frames too (daemon), not just the
      ;; very first Emacs frame.
      (setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name))))
  '';
}
