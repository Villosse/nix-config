{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      # "paper" matches the bar/terminal; "catppuccin_macchiato" is the old look
      palette = "paper";
      scan_timeout = 10;
      character = {
        success_symbol = " [[♥ ](green)  ](maroon)";
        error_symbol = "[ ](red)";
        vimcmd_symbol = "[ ](green)";
      };
      directory = {
        style = "bold lavender";
      };
      shlvl = {
        disabled = false;
        format = "[$shlvl ](bold peach)";
        threshold = 2;
      };
      # Only the names used above: green/maroon/red (prompt), lavender (dir),
      # peach (shlvl). Same accents as rio's paper palette.
      palettes.paper = {
        green = "#8fb996";
        maroon = "#ec9a83";
        red = "#e07a5f";
        lavender = "#9ad8c8";
        peach = "#d8a24a";
      };
      palettes.catppuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };
    };
  };
}
