# Editing niceties: expand-region + avy jumps.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      expand-region
      avy
    ];

  programs.emacs.extraConfig = lib.mkOrder 500 ''
    ;;; Editing niceties ----------------------------------------------------------
    (use-package expand-region
      :bind ("C-=" . er/expand-region))

    (use-package avy
      :bind (("C-:"   . avy-goto-char)
             ("C-'"   . avy-goto-char-2)
             ("M-g w" . avy-goto-word-1)))
  '';
}
