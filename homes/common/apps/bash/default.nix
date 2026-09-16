{pkgs, ...}: {
  imports = [
    ./starship.nix
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = ["ignoredups" "ignorespace"];
    historySize = 100000;
    historyFileSize = 100000;

    sessionVariables = {
      COLORTERM = "truecolor";
      # TERM is deliberately NOT set here: the terminal emulator (rio)
      # exports its own entry, which supports synchronized output
      # (mode 2026). Forcing `xterm-256color` broke Emacs' atomic TTY repaint.
      EDITOR = "nvim"; # TTY editing = vim; GUI Emacs (emacs-gui / ec) for real work
      PGDATA = "$HOME/postgres_data"; # carried over from the pre-Nix ~/.bashrc
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

    initExtra = ''
      shopt -s histappend checkwinsize globstar

      # Only downgrade TERM for a remote host that doesn't know the current one,
      # so local rio keeps its native terminfo.
      if [[ -n "$SSH_CONNECTION" ]] && ! infocmp "$TERM" &>/dev/null; then
        export TERM=xterm-256color
      fi
    '';
  };
}
