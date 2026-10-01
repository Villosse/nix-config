# GitHub Copilot: inline completion, Next Edit Suggestions, and chat.
#
# All three come from the single `copilot' package (0.9.0+), which bundles its
# own first-party chat. The separate `copilot-chat' package is deliberately NOT
# installed: both it and the bundled `copilot-chat.el' do `(provide
# 'copilot-chat)', so installing both makes load order decide the winner (which
# is what the old load-path hack here was fighting). Pick one -- this is the
# bundled one, which stays version-locked to copilot.el.
{lib, ...}: {
  programs.emacs.extraPackages = epkgs:
    with epkgs; [
      copilot # inline completion + Next Edit Suggestions + chat
    ];

  programs.emacs.extraConfig = lib.mkOrder 500 ''
    ;;; GitHub Copilot ------------------------------------------------------------
    ;; Nothing to install: nixpkgs patches `copilot-server-executable' to the
    ;; absolute store path of copilot-language-server, so do NOT set it here --
    ;; overriding it with a bare command name would downgrade a guaranteed store
    ;; path to a $PATH lookup. Authenticate once with `M-x copilot-login'.
    ;;
    ;; Completion keys are NOT bound here: `copilot-completion-map' already binds
    ;; TAB / <tab> to accept, C-<tab> to accept-by-word, and M-n / M-p to cycle.
    ;; Re-binding them via `:bind' would also force an eager load at daemon
    ;; startup, since use-package has to resolve the keymap.
    ;;
    ;; Opt-in per buffer with `M-x copilot-mode'. `M-x copilot-nes-mode' adds Next
    ;; Edit Suggestions (predicts the next edit elsewhere in the file, not just a
    ;; completion at point); NES does not start or sync the server itself, so it
    ;; needs `copilot-mode' enabled in the same buffer. `M-x copilot-menu' is a
    ;; transient covering all of it (transient comes in with magit).
    (use-package copilot
      :custom
      ;; Default chat model, sent to the server VERBATIM -- copilot.el does not
      ;; validate it, so an id this account lacks fails every turn with
      ;; "No model configuration found for id ...". Check what you actually have:
      ;;   M-: (mapcar (lambda (m) (plist-get m :id)) (copilot-chat--chat-models))
      ;; This account currently returns only "auto", the server-side router that
      ;; picks a model per turn -- naming a specific one (claude-opus-5.5 etc.)
      ;; requires a plan that grants it. "auto" follows plan upgrades for free
      ;; and never goes stale when GitHub retires a model (gpt-4o and
      ;; claude-sonnet-4.5 are already gone).
      ;;
      ;; Pinned rather than left nil on purpose: nil makes chat resolve the model
      ;; from the server, which returns nil when unauthenticated -- the request
      ;; then carries no model field and the server rejects it with the confusing
      ;; "A model id is required".
      ;;
      ;; Override per-session with `M-x copilot-chat-select-model' (reads the live
      ;; list) or `M-x copilot-menu'.
      (copilot-chat-model "auto")
      :commands (copilot-mode
                 copilot-nes-mode
                 copilot-login
                 copilot-logout
                 copilot-menu
                 copilot-chat
                 copilot-chat-display
                 copilot-chat-select-model))
  '';
}
