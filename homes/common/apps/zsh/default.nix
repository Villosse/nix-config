{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.apps.zsh;
in {
  options.apps.zsh = {
    enable = lib.mkEnableOption "zsh shell";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
        {
          name = "you-should-use";
          src = pkgs.zsh-you-should-use;
          file = "share/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh";
        }
      ];

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };

      sessionVariables = {
        COLORTERM = "truecolor";
        # TERM is deliberately NOT set here: the terminal emulator (rio)
        # exports its own entry, which supports synchronized output
        # (mode 2026). Forcing `xterm-256color` broke Emacs' atomic TTY repaint.
        EDITOR = "nvim"; # TTY editing = vim; GUI Emacs (emacs-gui / ec) for real work
      };

      shellAliases = rec {
        v = "nvim";
        vim = "nvim";
        e = "emacsclient -t -a emacs"; # terminal frame (patched rio terminfo = truecolor + sync)
        ec = "emacsclient -c -a emacs"; # GUI frame
        ls = "lsd";
        lst = "${ls} --tree";
        tree = "${ls} --tree";
        la = "${ls} --all";
        k = "kubectl";
        c = "clear";
        shell = "${pkgs.my-scripts.shell}";
        ":wq" = "exit";
        reload = "~/afs/setup.sh";
      };

      initContent = ''
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)

        # Only downgrade TERM for a remote host that doesn't know the current one,
        # so local rio keeps its native terminfo.
        if [[ -n "$SSH_CONNECTION" ]] && ! infocmp "$TERM" &>/dev/null; then
          export TERM=xterm-256color
        fi
      '';
    };
  };
}
