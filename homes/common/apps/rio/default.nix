{pkgs, ...}: {
  imports = [./terminfo.nix];

  programs.rio = {
    enable = true;
    # Prebuilt binary from nixpkgs (no long Rust build), wrapped so Vulkan only
    # sees the AMD iGPU. Even with `performance = "Low"`, wgpu loads the NVIDIA
    # driver while enumerating adapters and keeps /dev/nvidia0 open, which
    # stops the dGPU from powering off (RTD3). The GL backend is worse: it
    # renders on NVIDIA outright.
    package = pkgs.symlinkJoin {
      name = "rio";
      paths = [pkgs.rio];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/rio \
          --set VK_DRIVER_FILES /run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
      '';
    };
    settings = {
      confirm-before-quit = false;

      # Low-power adapter = the AMD iGPU.
      renderer.performance = "Low";

      # Drop the wrapper's VK_DRIVER_FILES for the shell, so programs run from
      # the terminal (nvidia-offload, vulkaninfo, games) still see the dGPU.
      shell = {
        program = "${pkgs.coreutils}/bin/env";
        args = ["-u" "VK_DRIVER_FILES" "/run/current-system/sw/bin/bash"];
      };

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
        # No client-side title bar (sway draws none either).
        decorations = "Disabled";
      };

      # No tab strip / app-name bar at the top.
      navigation = {
        mode = "Plain";
        use-terminal-title = false;
        hide-if-single = true;
      };

      padding-x = 5;
      padding-y = [5 5];

      # Paper palette, dark side: the quickshell bar's ink as background and
      # its cream as text; accents from the wallpaper (teal, coral, mustard).
      colors = {
        background = "#2b2a27";
        foreground = "#f3e9c6";
        cursor = "#9ad8c8";
        selection-background = "#4a463e";
        selection-foreground = "#f3e9c6";
        black = "#45423b";
        red = "#e07a5f";
        green = "#8fb996";
        yellow = "#d8a24a";
        blue = "#6fa8b8";
        magenta = "#c98a9a";
        cyan = "#9ad8c8";
        white = "#d9cfb0";
        light_black = "#6e6656";
        light_red = "#ec9a83";
        light_green = "#a8cfae";
        light_yellow = "#e8bc6a";
        light_blue = "#8cc0cf";
        light_magenta = "#dba8b5";
        light_cyan = "#b6e6da";
        light_white = "#f3e9c6";
      };
    };
  };
}
