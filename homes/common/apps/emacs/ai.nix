# GitHub Copilot: inline ghost-text suggestions + chat buffer.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      copilot # inline ghost-text suggestions
      copilot-chat # chat buffer
    ];

  programs.emacs.extraConfig = lib.mkOrder 500 ''
    ;;; GitHub Copilot ------------------------------------------------------------
    ;; Not enabled by default. Toggle per buffer with `M-x copilot-mode`.
    ;; The Copilot agent server is provided by Nix (copilot-language-server on
    ;; PATH), so there's nothing to install — just authenticate once with
    ;; `M-x copilot-login`.
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
  '';
}
