# Project + VCS: magit and projectile.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      magit
      projectile
    ];

  programs.emacs.extraConfig = lib.mkOrder 500 ''
    ;;; Project / VCS -------------------------------------------------------------
    (use-package magit
      :bind ("C-x g" . magit-status))

    (use-package projectile
      :init (projectile-mode 1)
      :bind-keymap ("C-c p" . projectile-command-map))
  '';
}
