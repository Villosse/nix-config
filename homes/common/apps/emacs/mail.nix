# mu4e — Emacs mail UI. The sync/send/index stack lives in the `mail` module
# (modules/home-manager/mail); this only wires the Emacs side, and is active
# only when mail.enable = true.
#
# mu4e's elisp is the separate `emacsPackages.mu4e' package (the `mu' package
# ships no .el files). Adding it to extraPackages puts it on the daemon's
# load-path, so `require'/`use-package' resolve with no manual load-path hacks.
# It must be the SAME version as the `mu' server (both 1.14.1 in this pin).
{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.emacs.extraPackages = epkgs:
    lib.optionals config.mail.enable [epkgs.mu4e];

  programs.emacs.extraConfig = lib.mkIf config.mail.enable (lib.mkOrder 500 ''
    ;;; mu4e (mail) ---------------------------------------------------------------
    (use-package mu4e
      :commands (mu4e mu4e-compose-new)
      :bind ("C-c m" . mu4e)                    ; launch mu4e
      :custom
      ;; Identity — without these, Emacs builds From:/Message-ID from the machine
      ;; hostname (lenny@lenny-laptop.mail-host-address-is-not-set). Pull the real
      ;; values from the mail module so nothing is hardcoded.
      (user-mail-address "${config.mail.address}")
      (user-full-name "${config.mail.realName}")
      ;; FQDN used for the Message-ID domain; use the mail domain, not the host.
      (message-user-fqdn "gmail.com")
      (mu4e-compose-reply-to-address "${config.mail.address}")
      (mu4e-mail-fetching t)
      ;; mbsync is the sync backend; run it from inside mu4e with `U`.
      (mu4e-get-mail-command "mbsync gmail")
      (mu4e-update-interval 300)                ; also auto-refresh every 5 min
      (mu4e-maildir "~/.mail/gmail")
      (mu4e-change-filenames-when-moving t)     ; required for mbsync
      (mu4e-attachment-dir "~/Downloads")
      (mu4e-context-policy 'pick-first)
      (mu4e-compose-context-policy 'ask-if-none)
      ;; Gmail handles its own copies to [Gmail]/Sent Mail — don't duplicate.
      (mu4e-sent-messages-behavior 'delete)
      ;; Gmail special folders (flavor = gmail.com in accounts.email).
      (mu4e-drafts-folder "/[Gmail]/Drafts")
      (mu4e-sent-folder   "/[Gmail]/Sent Mail")
      (mu4e-trash-folder  "/[Gmail]/Trash")
      (mu4e-refile-folder "/[Gmail]/All Mail")
      ;; Prefer plain-text; render HTML readably when that's all there is.
      (mu4e-view-show-images t)
      (mu4e-view-prefer-html nil)
      (message-kill-buffer-on-exit t)
      ;; Send via msmtp (configured in the mail module). msmtp reads the account
      ;; from the From: header, so let it choose.
      (sendmail-program "${pkgs.msmtp}/bin/msmtp")
      (send-mail-function 'smtpmail-send-it)
      (message-send-mail-function 'message-send-mail-with-sendmail)
      (message-sendmail-extra-arguments '("--read-envelope-from"))
      (message-sendmail-f-is-evil t)
      :config
      ;; Handy searches on the mu4e main view.
      (setq mu4e-bookmarks
            '((:name "Unread messages" :query "flag:unread AND NOT flag:trashed" :key ?u)
              (:name "Today's messages" :query "date:today..now" :key ?t)
              (:name "Last 7 days" :query "date:7d..now" :key ?w)
              (:name "Inbox" :query "maildir:/INBOX" :key ?i))))
  '');
}
