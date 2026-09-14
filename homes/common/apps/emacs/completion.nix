# Completion stack: vertico family (minibuffer) + corfu (in-buffer) + cape.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      vertico
      orderless
      consult
      marginalia
      corfu
      cape
      nerd-icons-completion
      nerd-icons-corfu
    ];

  programs.emacs.extraConfig = lib.mkOrder 500 ''
    ;;; Completion stack (vertico family) -----------------------------------------
    (use-package vertico
      :init (vertico-mode))

    (use-package orderless
      :custom
      (completion-styles '(orderless basic))
      (completion-category-overrides '((file (styles basic partial-completion)))))

    (use-package marginalia
      :init (marginalia-mode))

    (use-package nerd-icons-completion
      :after marginalia
      :config
      (nerd-icons-completion-mode)
      (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

    (use-package consult
      :bind (("C-s"   . consult-line)          ; search in buffer
             ("C-x b" . consult-buffer)        ; switch buffer
             ("M-y"   . consult-yank-pop)      ; kill-ring browser
             ("M-g g" . consult-goto-line)
             ("M-g i" . consult-imenu)
             ("C-c r" . consult-ripgrep)))     ; grep across project

    ;; In-buffer completion popup.
    (use-package corfu
      :init (global-corfu-mode)
      :custom
      (corfu-auto t)
      (corfu-auto-delay 0.1)
      (corfu-auto-prefix 2)
      (corfu-cycle t))

    (use-package nerd-icons-corfu
      :after corfu
      :config
      (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

    (use-package cape
      :init
      (add-to-list 'completion-at-point-functions #'cape-file)
      (add-to-list 'completion-at-point-functions #'cape-dabbrev))
  '';
}
