# Core UI + sane editor defaults + font + transparency.
{lib, ...}: {
  programs.emacs.extraConfig = lib.mkOrder 200 ''
    ;;; UI ------------------------------------------------------------------------
    (menu-bar-mode -1)
    (tool-bar-mode -1)
    (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
    (setq inhibit-startup-screen t)
    (setq ring-bell-function 'ignore)
    (setq use-short-answers t)              ; y/n instead of yes/no
    (column-number-mode 1)
    (global-display-line-numbers-mode 1)
    (dolist (mode '(term-mode-hook shell-mode-hook eshell-mode-hook vterm-mode-hook))
      (add-hook mode (lambda () (display-line-numbers-mode 0))))
    (show-paren-mode 1)
    (electric-pair-mode 1)                   ; auto-insert matching ) ] } " etc.
    (setq show-paren-delay 0)
    (global-font-lock-mode 1)                ; syntax highlighting everywhere
    (setq scroll-conservatively 101         ; smooth-ish scrolling
          scroll-margin 3)

    ;; Font. Uses the Nerd Font already installed system-wide (see hosts config),
    ;; so nerd-icons glyphs render in the GUI. Adjust family/height to taste.
    (set-face-attribute 'default nil :family "IosevkaTerm Nerd Font" :height 120)

    ;; Slightly translucent background for GUI frames (85% opaque). Applied to both
    ;; existing and future frames; the daemon serves frames created after startup,
    ;; so also set it via `after-make-frame-functions`.
    (setq default-frame-alist (cons '(alpha-background . 85) default-frame-alist))
    (set-frame-parameter nil 'alpha-background 85)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (when (display-graphic-p frame)
                  (set-frame-parameter frame 'alpha-background 85))))

    ;;; Sane defaults -------------------------------------------------------------
    (setq-default indent-tabs-mode nil)      ; spaces, not tabs
    (setq-default tab-width 2)
    (setq require-final-newline t)
    (delete-selection-mode 1)                ; typing replaces the selection
    (global-auto-revert-mode 1)              ; reload files changed on disk
    (setq global-auto-revert-non-file-buffers t)
    (save-place-mode 1)                      ; remember cursor position
    (savehist-mode 1)                        ; persist minibuffer history
    (recentf-mode 1)                         ; recent files list

    ;; No temporary files: disable backups, autosave files, and lock files.
    (setq make-backup-files nil)             ; no  file~
    (setq auto-save-default nil)             ; no  #file#
    (setq create-lockfiles nil)              ; no  .#file
    (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
    (when (file-exists-p custom-file) (load custom-file))
  '';
}
