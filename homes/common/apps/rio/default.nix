{pkgs, ...}: {
  imports = [./terminfo.nix];

  programs.rio = {
    enable = true;
    package = pkgs.rio; # prebuilt binary from nixpkgs (no long Rust build)
    settings = {
      confirm-before-quit = false;

      # Extra key bindings that send the escape sequences TUI apps expect.
      bindings.keys = [
        # Ctrl+Left / Ctrl+Right -> word-wise cursor motion (xterm CSI 1;5 D/C).
        # Without these, rio sent nothing useful and claude-code ignored them.
        {
          key = "Left";
          "with" = "control"; # `with` is a Nix keyword -> must be quoted
          bytes = [27 91 49 59 53 68]; # \E[1;5D
        }
        {
          key = "Right";
          "with" = "control";
          bytes = [27 91 49 59 53 67]; # \E[1;5C
        }
        # Shift+Enter -> insert a literal newline in claude-code (esc + CR),
        # instead of submitting like a bare Enter does.
        {
          key = "Return";
          "with" = "shift";
          bytes = [27 13]; # \E\r
        }
      ];

      # Match the ghostty look.
      fonts = {
        family = "IosevkaTerm Nerd Font";
        size = 14;
      };

      window = {
        opacity = 0.85;
        decorations = "Disabled";
      };

      padding-x = 5;
      padding-y = [5 5];

      # Catppuccin Macchiato
      colors = {
        background = "#24273a";
        foreground = "#cad3f5";
        cursor = "#f4dbd6";
        selection-background = "#3a3e53";
        selection-foreground = "#cad3f5";
        black = "#494d64";
        red = "#ed8796";
        green = "#a6da95";
        yellow = "#eed49f";
        blue = "#8aadf4";
        magenta = "#f5bde6";
        cyan = "#8bd5ca";
        white = "#a5adcb";
        light_black = "#5b6078";
        light_red = "#ed8796";
        light_green = "#a6da95";
        light_yellow = "#eed49f";
        light_blue = "#8aadf4";
        light_magenta = "#f5bde6";
        light_cyan = "#8bd5ca";
        light_white = "#b8c0e0";
      };
    };
  };
}
