{pkgs, ...}: let
  # Rio's upstream terminfo entry is missing two capabilities that Emacs needs:
  #   - Sync (mode 2026): atomic frame repaint. Without it, async LSP updates
  #     interleave with stale glyphs -> ghost/duplicate lines needing C-l.
  #   - Tc / truecolor: without it colors quantize to xterm-256 (washed out).
  # Rio supports both at runtime; the terminfo just doesn't advertise them.
  # This entry inherits the packaged `rio` entry via use= and adds them.
  rio-fixed = pkgs.runCommand "rio-fixed-terminfo" {} ''
    mkdir -p $out/share/terminfo
    cat > entry.src <<'EOF'
    rio|rio with sync and truecolor,
      Tc,
      Sync=\E[?2026%?%p1%{1}%-%tl%eh%;,
      use=rio,
    EOF
    TERMINFO_DIRS=${pkgs.rio}/share/terminfo:${pkgs.ncurses}/share/terminfo \
      ${pkgs.ncurses}/bin/tic -x -o $out/share/terminfo entry.src
  '';
in {
  home.packages = [rio-fixed];
  # Make Emacs (and everything else) find the patched entry first.
  home.sessionVariables.TERMINFO_DIRS = "${rio-fixed}/share/terminfo:\${TERMINFO_DIRS}";
}
