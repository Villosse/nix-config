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
