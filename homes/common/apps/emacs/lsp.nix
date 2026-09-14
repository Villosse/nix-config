# LSP (eglot) + eldoc, plus every language major-mode and the tree-sitter remaps.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      eglot
      tuareg # OCaml
      dune
      nix-mode
      markdown-mode
      yaml-mode
      typst-ts-mode # Typst
      paredit # structured Lisp editing
      sly # Common Lisp REPL/IDE
      treesit-grammars.with-all-grammars
    ];

  programs.emacs.extraConfig = lib.mkOrder 500 ''
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
      ;; Inlay hints clutter the code with `nmemb:` / `size:` style labels; off.
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

    ;; eldoc renders the LSP hover/signature docs. Keep the echo area to one line
    ;; and send the full docs to the *eldoc* buffer (C-c l d) to avoid clutter.
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
  '';
}
