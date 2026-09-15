# Mail — option-based home-manager module.
#
# Owns everything OUTSIDE Emacs for mail: the sops-encrypted password, the
# account definition, IMAP sync (mbsync/isync), SMTP sending (msmtp) and the
# `mu` indexer. The mu4e Emacs UI is configured separately in
# homes/common/apps/emacs/mail.nix.
#
# Enable from a profile with:  mail.enable = true;
#
# The account password is read from a sops secret (see .sops.yaml and
# secrets/mail.yaml); nothing secret is committed in plaintext.
{
  lib,
  config,
  pkgs,
  username,
  rootPath,
  ...
}:
with lib; let
  cfg = config.mail;
in {
  options.mail = {
    enable = mkEnableOption "mu4e mail stack (isync + msmtp + mu)";

    address = mkOption {
      type = types.str;
      description = "Primary email address.";
      example = "you@example.com";
    };

    realName = mkOption {
      type = types.str;
      description = "Display name used in the From: header.";
      default = "";
    };

    maildir = mkOption {
      type = types.str;
      description = "Base directory for local Maildirs.";
      default = "/home/${username}/.mail";
    };

    sopsFile = mkOption {
      type = types.path;
      description = "sops-encrypted YAML file containing the account password.";
      default = "${rootPath}/secrets/mail.yaml";
    };

    passwordKey = mkOption {
      type = types.str;
      description = "Dotted key of the password inside the sops file.";
      default = "gmail/app-password";
    };

    syncFrequency = mkOption {
      type = types.str;
      description = "systemd OnCalendar spec for the periodic mbsync timer.";
      default = "*:0/5";
    };
  };

  config = mkIf cfg.enable {
    # --- Secret ---------------------------------------------------------------
    # Decrypted at activation to a tmpfs path readable only by this user.
    sops = {
      age.sshKeyPaths = ["/home/${username}/.ssh/id_ed25519"];
      defaultSopsFile = cfg.sopsFile;
      secrets.${cfg.passwordKey} = {};
    };

    # --- Account --------------------------------------------------------------
    # accounts.email drives mbsync + msmtp + mu4e config generation.
    accounts.email = {
      maildirBasePath = cfg.maildir;
      accounts.gmail = {
        primary = true;
        address = cfg.address;
        userName = cfg.address;
        realName = cfg.realName;
        flavor = "gmail.com"; # IMAP/SMTP hosts + Gmail folder conventions

        passwordCommand = "cat ${config.sops.secrets.${cfg.passwordKey}.path}";

        imap.host = "imap.gmail.com";
        smtp = {
          host = "smtp.gmail.com";
          port = 587;
          tls.useStartTls = true;
        };

        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          patterns = ["*" "!\"[Gmail]/All Mail\"" "!\"[Gmail]/Important\""];
        };
        msmtp.enable = true;
        mu.enable = true;
      };
    };

    # --- Tooling --------------------------------------------------------------
    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.mu.enable = true; # provides `mu` + the mu4e Emacs package

    # Periodic background sync + reindex.
    services.mbsync = {
      enable = true;
      frequency = cfg.syncFrequency;
      postExec = "${pkgs.mu}/bin/mu index";
    };
  };
}
