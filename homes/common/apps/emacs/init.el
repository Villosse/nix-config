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

;; Truecolor in the TTY is handled by launching emacsclient with
;; TERM=xterm-direct (see the `e` alias in zsh); no elisp needed for it.

;;; Theme + modeline ----------------------------------------------------------
(use-package catppuccin-theme
  :init
  (setq catppuccin-flavor 'macchiato)   ; matches your btop/dunst theme
  :config
  (load-theme 'catppuccin :no-confirm))

(use-package nerd-icons)

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

;; In a terminal frame (emacsclient -t), corfu's GUI child-frame popup renders
;; garbled/duplicated. corfu-terminal draws it as a plain-text overlay instead.
(use-package corfu-terminal
  :after corfu
  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode 1))
  ;; The daemon serves both GUI and TTY frames; toggle per frame on creation.
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (corfu-terminal-mode (if (display-graphic-p) -1 1)))))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;;; TTY redraw hardening ------------------------------------------------------
;; Since rio's terminfo now advertises Sync (mode 2026), Emacs repaints each
;; frame atomically, so the old "redraw the whole frame on every diagnostics
;; push" hack is no longer needed — and it caused a visible full-screen BLINK
;; while typing. Removed. Only the minibuffer/completion teardown paths (code
;; actions, corfu popup) can still leave a stale glyph at the bottom; repaint
;; just those, once, on their single teardown call. GUI frames are skipped.
;; The eglot code-action picker is a multi-line Vertico popup in the minibuffer
;; area. When it collapses, Emacs' *incremental* TTY redisplay sometimes decides
;; the vacated lines are unchanged and skips them -> intermittent stale glyph
;; (worked "sometimes"). `redraw-display` is diff-based so it inherits the same
;; skip; the deterministic fix is `redraw-frame`, which clears the frame
;; unconditionally. Hook it to VERTICO teardown specifically (not every
;; minibuffer exit) so normal typing never triggers a full clear = no blink.
;; Deferred to after the popup fully unwinds so the cleared lines stay cleared.
(defun my/tty-force-repaint (&rest _)
  "Deterministically clear+repaint every TTY frame after the current command.
Uses `redraw-frame' (unconditional) rather than `redraw-display' (diff-based,
which intermittently skips the vacated popup lines). Deferred so the cleared
lines stay cleared after the popup has fully unwound."
  (unless (display-graphic-p)
    (run-at-time 0 nil (lambda ()
                         (dolist (frame (frame-list))
                           (unless (display-graphic-p frame)
                             (redraw-frame frame)))))))

;; Only force the full clear when the minibuffer session actually used Vertico
;; (the eglot code-action picker does). Plain prompts (y/n, eval) don't, so
;; ordinary typing/commands never trigger a full-frame clear -> no blink.
(defun my/tty-repaint-if-vertico ()
  (when (bound-and-true-p vertico--input)
    (my/tty-force-repaint)))
(add-hook 'minibuffer-exit-hook #'my/tty-repaint-if-vertico)

(with-eval-after-load 'corfu
  ;; After the completion popup is dismissed.
  (advice-add 'corfu--teardown :after #'my/tty-force-repaint))

;;; Editing niceties ----------------------------------------------------------
(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package avy
  :bind (("C-:"   . avy-goto-char)
         ("C-'"   . avy-goto-char-2)
         ("M-g w" . avy-goto-word-1)))

;;; Project / VCS -------------------------------------------------------------
(use-package magit
  :bind ("C-x g" . magit-status))

(use-package projectile
  :init (projectile-mode 1)
  :bind-keymap ("C-c p" . projectile-command-map))

;;; GitHub Copilot ------------------------------------------------------------
;; Not enabled by default. Toggle per buffer with `M-x copilot-mode`.
;; First time: run `M-x copilot-install-server` is NOT needed (the server is
;; provided by Nix); instead authenticate once with `M-x copilot-login`.
(use-package copilot
  :commands (copilot-mode copilot-login)
  :custom
  ;; Use the Nix-provided copilot-language-server instead of a downloaded one.
  (copilot-server-executable "copilot-language-server")
  :bind (:map copilot-completion-map
              ("TAB"   . copilot-accept-completion)
              ("<tab>" . copilot-accept-completion)
              ("C-TAB" . copilot-accept-completion-by-word)
              ("C-<tab>" . copilot-accept-completion-by-word)))

;; The `copilot' package (0.5.0) bundles its own stub `copilot-chat.el', which
;; shadows the real standalone `copilot-chat' package (same feature name, so
;; load-order decides the winner). Force the standalone package's directory to
;; the FRONT of load-path so `require' resolves to the real one.
(let ((real-copilot-chat
       (seq-find (lambda (d)
                   (and (string-match-p "copilot-chat-[0-9]" d)
                        (file-exists-p (expand-file-name "copilot-chat.el" d))))
                 load-path)))
  (when real-copilot-chat
    (setq load-path (cons real-copilot-chat (delete real-copilot-chat load-path)))))

(use-package copilot-chat
  :commands (copilot-chat copilot-chat-display copilot-chat-set-model)
  :custom
  ;; Pick a default so the chat has a model on first use (was nil -> no reply).
  ;; Change via `M-x copilot-chat-set-model` if you want a different one.
  (copilot-chat-model "gpt-4o"))

;;; LSP (eglot) + languages ---------------------------------------------------
(use-package eglot
  :hook ((tuareg-mode      . eglot-ensure)  ; OCaml
         (nix-mode         . eglot-ensure)  ; Nix
         (c-mode           . eglot-ensure)  ; C
         (c++-mode         . eglot-ensure)  ; C++
         (c-ts-mode        . eglot-ensure)
         (c++-ts-mode      . eglot-ensure)
         (yaml-mode        . eglot-ensure)  ; YAML
         (yaml-ts-mode     . eglot-ensure)
         (typst-ts-mode    . eglot-ensure)  ; Typst
         (python-mode      . eglot-ensure)  ; Python
         (python-ts-mode   . eglot-ensure)
         (markdown-mode    . eglot-ensure)) ; Markdown (via LSP if present)
  :custom
  (eglot-autoshutdown t)
  ;; Don't let eglot show inline signature/type hints on the code (the source
  ;; of the terminal redraw corruption). Keep only diagnostics + highlight.
  (eglot-ignored-server-capabilities '(:inlayHintProvider))
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc-doc-buffer)) ; open docs in a real buffer
  :config
  ;; Nix: use nixd (nixd is on PATH via home.packages).
  (add-to-list 'eglot-server-programs '((nix-mode) . ("nixd")))
  ;; Typst: tinymist.
  (add-to-list 'eglot-server-programs '((typst-ts-mode) . ("tinymist"))))

;; eldoc renders the LSP hover/signature docs. In a TTY, a tall multi-line
;; echo-area message corrupts the redraw ("duplicated line + junk on the cursor
;; line"). Cap it to one line in the echo area and send full docs to a buffer.
(setq eldoc-echo-area-use-multiline-p 1)      ; at most 1 line inline
(setq eldoc-echo-area-prefer-doc-buffer t)    ; prefer the *eldoc* buffer if shown
(setq eldoc-idle-delay 0.3)

;;;; OCaml
(use-package tuareg
  :mode ("\\.mli?\\'" . tuareg-mode))
(use-package dune)

;;;; Nix
(use-package nix-mode
  :mode "\\.nix\\'")

;;;; C / C++ — clangd handled by eglot; nothing extra needed (built-in modes).

;;;; YAML / Markdown
(use-package yaml-mode)
(use-package markdown-mode)

;;;; Typst
(use-package typst-ts-mode
  :mode "\\.typ\\'")

;;;; Lisp — Emacs Lisp needs no LSP; Common Lisp uses Sly.
(use-package paredit
  :hook ((emacs-lisp-mode       . paredit-mode)
         (lisp-mode             . paredit-mode)
         (lisp-interaction-mode . paredit-mode)
         (scheme-mode           . paredit-mode)))

(use-package sly
  :commands (sly)
  :init
  ;; Point this at a CL implementation if you install one (e.g. sbcl).
  ;; (setq inferior-lisp-program "sbcl")
  )

;;;; Tiger (EPITA compilers course) — no LSP exists; basic syntax mode only.
(define-derived-mode tiger-mode prog-mode "Tiger"
  "Major mode for editing Tiger source files."
  (setq-local comment-start "/* ")
  (setq-local comment-end " */")
  (setq-local font-lock-defaults
              '((("\\_<\\(array\\|break\\|do\\|else\\|end\\|for\\|function\\|if\\|in\\|let\\|nil\\|of\\|then\\|to\\|type\\|var\\|while\\)\\_>"
                  . font-lock-keyword-face)
                 ("\\_<\\(int\\|string\\)\\_>" . font-lock-type-face)))))
(add-to-list 'auto-mode-alist '("\\.ti?g\\'" . tiger-mode))

;; Prefer tree-sitter modes where grammars are available (from Nix), giving
;; richer, more accurate syntax highlighting.
(setq treesit-font-lock-level 4)
(dolist (mapping '((c-mode          . c-ts-mode)
                   (c++-mode        . c++-ts-mode)
                   (c-or-c++-mode   . c-or-c++-ts-mode)
                   (yaml-mode       . yaml-ts-mode)
                   (json-mode       . json-ts-mode)
                   (js-mode         . js-ts-mode)
                   (python-mode     . python-ts-mode)
                   (bash-mode       . bash-ts-mode)))
  (add-to-list 'major-mode-remap-alist mapping))

(provide 'init)
;;; init.el ends here
