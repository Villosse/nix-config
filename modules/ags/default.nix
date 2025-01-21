{ config, inputs, pkgs, lib, ... }:

{
  imports = [
  ];

  options.ags = {
    enable = lib.mkEnableOption "Enable AGS";
    configFolder = lib.mkOption {
      type = lib.types.path;
      default = ./config;
      description = "Path to the AGS config";
    };
  };

  config = lib.mkIf config.ags.enable {
    environment.systemPackages = with pkgs; [
            ags
            gtk3
            gtk4
            glib
            gjs
            nodePackages.typescript
            gobject-introspection
            cairo
            pango
            gdk-pixbuf
            webkitgtk
            libdbusmenu-gtk3
            playerctl
            networkmanager
            brightnessctl
            pavucontrol
            pamixer
            bluez
            upower
            accountsservice

    ];
    home-manager.users.lenny = {
      home.file.".config/ags".source = config.ags.configFolder;
    };
  };
}
