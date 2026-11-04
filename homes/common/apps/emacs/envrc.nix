# Per-buffer direnv environments. The daemon never sees a `nix develop` shell, so
# a project's tools only reach eglot, compile, etc. through its `.envrc`.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs: [epkgs.envrc];

  # Order 900: the global mode must be set up after the other modes, so that it
  # applies a buffer's environment before they look up executables.
  programs.emacs.extraConfig = lib.mkOrder 900 ''
    ;;; direnv ---------------------------------------------------------------------
    (use-package envrc
      :hook (after-init . envrc-global-mode)
      :config
      (define-key envrc-mode-map (kbd "C-c e") 'envrc-command-map))
  '';
}
