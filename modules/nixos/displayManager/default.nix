{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.displayManager;
in {
  options.displayManager = {
    theme = mkOption {
      type = types.nullOr types.package;
      description = "Display manager theme";
      default = null;
    };

    i3.enable = mkOption {
      type = types.bool;
      description = "Enable i3 as window manager manager";
      default = false;
    };

    maomaowm.enable = mkOption {
      type = types.bool;
      description = "Enable maomaowm as window manager";
      default = false;
    };

    sway.enable = mkOption {
      type = types.bool;
      description = "Enable sway as window manager";
      default = false;
    };
  };

  config = mkIf (cfg.theme != null) {
    services.displayManager.sddm = {
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
      ];
    };
    environment.systemPackages = [cfg.theme];
  };
}
