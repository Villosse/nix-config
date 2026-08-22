{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.windowManager;
  mod = "Mod4";
  rio = "${inputs.rio.packages.${pkgs.system}.default}/bin/rio";

  bemenu-launcher = pkgs.writeShellScriptBin "bemenu-launcher" ''
    exec ${pkgs.bemenu}/bin/bemenu-run \
      --ab '#24273a' \
      --af '#cad3f5' \
      --binding vim \
      --cw 15 \
      --fb '#24273a' \
      --ff '#cad3f5' \
      --fn 'IosevkaTerm Nerd Font Semi-Bold 14' \
      --hb '#24273a' \
      --hf '#eed49f' \
      --hp 10 \
      --ignorecase \
      --line-height 38 \
      --nb '#24273a' \
      --nf '#cad3f5' \
      --prompt '  ' \
      --tb '#24273a' \
      --tf '#ed8796' \
      --vim-esc-exits \
      --wrap
  '';
in {
  imports = [./fn-keys.nix];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland = true;
    extraOptions = ["--unsupported-gpu"];

    extraSessionCommands = ''
      export NIXOS_OZONE_WL=1
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland
      export GDK_BACKEND=wayland,x11
      export SDL_VIDEODRIVER=x11
      export MOZ_ENABLE_WAYLAND=1
      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export GTK_IM_MODULE=simple
      export QT_IM_MODULE=fcitx
      export SDL_IM_MODULE=fcitx
      export XMODIFIERS=@im=fcitx
      export GLFW_IM_MODULE=ibus
      export QT_QPA_PLATFORMTHEME=qt5ct
      export QT_AUTO_SCREEN_SCALE_FACTOR=1
      export QT_QPA_PLATFORM="wayland;xcb"
    '';

    config = {
      modifier = mod;
      terminal = rio;
      bars = [];

      startup = [
        {
          command = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
        }
        {command = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";}
        {command = "${pkgs.swaynotificationcenter}/bin/swaync";}
        {command = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular --reconnect-tries 0";}
        {command = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";}
        {command = "${pkgs.wpaperd}/bin/wpaperd";}
      ];

      # Catppuccin Macchiato colors
      colors = {
        focused = {
          border = "#c6a0f6";
          background = "#24273a";
          text = "#cad3f5";
          indicator = "#c6a0f6";
          childBorder = "#c6a0f6";
        };
        unfocused = {
          border = "#1e2030";
          background = "#24273a";
          text = "#cad3f5";
          indicator = "#1e2030";
          childBorder = "#1e2030";
        };
        focusedInactive = {
          border = "#1e2030";
          background = "#24273a";
          text = "#cad3f5";
          indicator = "#1e2030";
          childBorder = "#1e2030";
        };
        urgent = {
          border = "#ed8796";
          background = "#24273a";
          text = "#cad3f5";
          indicator = "#ed8796";
          childBorder = "#ed8796";
        };
      };

      gaps = {
        inner = 5;
        outer = 0;
      };

      window = {
        border = 4;
        titlebar = false;
      };
      floating = {
        border = 4;
        titlebar = false;
        modifier = mod;
      };

      fonts = {
        names = ["IosevkaTerm Nerd Font"];
        size = 10.0;
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "intl";
          xkb_options = "ctrl:nocaps";
          repeat_rate = "25";
          repeat_delay = "600";
          xkb_numlock = "enabled";
        };
        "type:touchpad" = {
          tap = "enabled";
          tap_button_map = "lrm";
          drag = "enabled";
          drag_lock = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
          accel_profile = "adaptive";
        };
      };

      output = {
        "${cfg.primaryDisplay.port}" = {
          resolution = "${toString cfg.primaryDisplay.width}x${toString cfg.primaryDisplay.height}@${toString cfg.primaryDisplay.refreshRate}Hz";
          scale = "${toString cfg.primaryDisplay.scale}";
          position = "${toString cfg.primaryDisplay.x} ${toString cfg.primaryDisplay.y}";
        };
        "*" = {
          bg = "${cfg.wallpaper} fill";
        };
      };

      focus = {
        followMouse = false;
        wrapping = "yes";
      };

      keybindings = lib.mkOptionDefault {
        # Applications
        "${mod}+d" = "exec ${bemenu-launcher}/bin/bemenu-launcher";
        "${mod}+Return" = "exec ${rio}";
        "${mod}+x" = "exec ${pkgs.swaylock}/bin/swaylock -i ${cfg.lockscreen} --indicator-radius 100";
        "${mod}+s" = "exec ${pkgs.my-scripts.screenshot}";

        # Session
        "${mod}+q" = "kill";
        "${mod}+m" = "exit";
        "${mod}+Shift+r" = "reload";

        # Focus (vim-like)
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Tab" = "focus next";
        "${mod}+u" = "focus parent";

        # Move windows
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Move floating windows (pixel-based)
        "Ctrl+Shift+h" = "move left 50px";
        "Ctrl+Shift+j" = "move down 50px";
        "Ctrl+Shift+k" = "move up 50px";
        "Ctrl+Shift+l" = "move right 50px";

        # Resize
        "Ctrl+Alt+h" = "resize shrink width 20px";
        "Ctrl+Alt+j" = "resize grow height 20px";
        "Ctrl+Alt+k" = "resize shrink height 20px";
        "Ctrl+Alt+l" = "resize grow width 20px";
        "${mod}+Alt+h" = "resize shrink width 50px";
        "${mod}+Alt+l" = "resize grow width 50px";

        # Window state
        "${mod}+v" = "floating toggle";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+f" = "fullscreen toggle global";

        # Layout
        "${mod}+e" = "layout toggle split";
        "${mod}+t" = "layout tabbed";
        "${mod}+n" = "layout toggle all";

        # Scratchpad
        "${mod}+i" = "move scratchpad";
        "${mod}+Shift+i" = "scratchpad show";
        "Alt+z" = "scratchpad show";

        # Workspaces
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";

        # Monitor focus
        "Alt+Shift+h" = "focus output left";
        "Alt+Shift+l" = "focus output right";
        "Alt+Shift+j" = "focus output down";
        "Alt+Shift+k" = "focus output up";

        # Move container to monitor
        "${mod}+Alt+Shift+h" = "move container to output left; focus output left";
        "${mod}+Alt+Shift+l" = "move container to output right; focus output right";
        "${mod}+Alt+Shift+j" = "move container to output down; focus output down";
        "${mod}+Alt+Shift+k" = "move container to output up; focus output up";

        # Gaps
        "Alt+Shift+x" = "gaps inner current plus 1";
        "Alt+Shift+z" = "gaps inner current minus 1";
        "Alt+Shift+r" = "gaps inner current set 5, gaps outer current set 0";
      };
    };

    extraConfig = ''
      # Start on workspace 1
      exec swaymsg workspace number 1

      # Cursor
      seat * xcursor_theme Bibata-Modern-Ice 24

      # Window rules
      for_window [app_id="flameshot"] fullscreen enable
      for_window [app_id="yesplaymusic"] floating enable, resize set 1500 900
      for_window [app_id="clash-verge"] floating enable, resize set 1500 900
      for_window [app_id="blueman-manager"] floating enable, resize set 1500 900
      for_window [app_id="mpv"] floating enable, resize set 1500 900

      # Workspace assignments
      assign [app_id="firefox"] workspace number 2
      assign [app_id="qutebrowser"] workspace number 2
      assign [app_id="Discord"] workspace number 4

      # Gestures
      bindgesture swipe:right workspace prev
      bindgesture swipe:left workspace next
    '';
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-fancy;
  };

  services.wpaperd = {
    enable = true;
    settings = {
      any = {
        path = cfg.wallpaper;
      };
    };
  };
}
