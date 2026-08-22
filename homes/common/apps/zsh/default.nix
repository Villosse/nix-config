{pkgs, ...}: {
  imports = [
    ./starship.nix
  ];

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
      /*
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "030ac861f5f1536747407ac7baf208fd3990602a";
          sha256 = "0gx7gs5ds35vw15ygp98m6v8ryzgd1b57fwwn60zf4svpka43xc8";
        };
      }
      */
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
      # TERM is deliberately NOT set here: the terminal emulator (ghostty)
      # exports its own `xterm-ghostty`, which supports synchronized output
      # (mode 2026). Forcing `xterm-256color` broke Emacs' atomic TTY repaint.
      EDITOR = "emacsclient -t -a emacs";
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
      # so local ghostty keeps its native xterm-ghostty terminfo.
      if [[ -n "$SSH_CONNECTION" ]] && ! infocmp "$TERM" &>/dev/null; then
        export TERM=xterm-256color
      fi
    '';
  };
}
