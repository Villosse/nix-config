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
      :commands (copilot-mode
                 copilot-nes-mode
                 copilot-login
                 copilot-menu
                 copilot-chat
                 copilot-chat-display
                 copilot-chat-select-model))
  '';
}
