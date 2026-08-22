{pkgs, ...}: {
  imports = [./terminfo.nix];

  programs.rio = {
    enable = true;
    package = pkgs.rio; # prebuilt binary from nixpkgs (no long Rust build)
    settings = {
      confirm-before-quit = false;

      # Extra key bindings that send the escape sequences TUI apps expect.
      bindings.keys = [
      ];

      # Match the ghostty look.
      fonts = {
        family = "IosevkaTerm Nerd Font";
        size = 14;
      };

      window = {
        opacity = 0.85;
        #decorations = "Disabled";
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
