;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; Packages are provided by Nix (see default.nix), so package.el is unused.
(require 'use-package)
(setq use-package-always-ensure nil)

;;; UI ------------------------------------------------------------------------
(menu-bar-mode -1)
(tool-bar-mode -1)
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(column-number-mode 1)
(global-display-line-numbers-mode 1)

;;; Sane defaults -------------------------------------------------------------
(setq-default indent-tabs-mode nil)      ; spaces, not tabs
(setq-default tab-width 2)
(setq require-final-newline t)
(delete-selection-mode 1)                ; typing replaces the selection
(global-auto-revert-mode 1)              ; reload files changed on disk
(save-place-mode 1)                      ; remember cursor position

;; Keep backups and autosaves out of the working tree.
(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory))))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))

(provide 'init)
;;; init.el ends here
