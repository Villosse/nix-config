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
      # newt (nmtui) defaults to cyan/blue windows, unreadable here. Only the 16
      # ANSI names are accepted; rio maps them to Catppuccin Macchiato.
      NEWT_COLORS = builtins.concatStringsSep ";" [
        "root=white,black"
        "roottext=white,black"
        "helpline=white,black"
        "window=white,black"
        "border=blue,black"
        "shadow=black,black"
        "title=brightmagenta,black"
        "label=white,black"
        "textbox=white,black"
        "acttextbox=black,blue"
        "entry=white,black"
        "disentry=gray,black"
        "checkbox=white,black"
        "actcheckbox=black,blue"
        "listbox=white,black"
        "actlistbox=black,blue"
        "sellistbox=black,brightmagenta"
        "actsellistbox=black,blue"
        "button=white,gray"
        "actbutton=black,blue"
        "compactbutton=white,black"
        "emptyscale=,black"
        "fullscale=,blue"
      ];
    };

    shellAliases = rec {
      v = "nvim";
      vim = "nvim";
      e = "emacsclient -nw -a emacs"; # terminal frame (patched rio terminfo = truecolor + sync)
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
