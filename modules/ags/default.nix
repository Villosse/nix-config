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
      inputs.ags.packages.${system}.default
      bun
      dart-sass
      fd
      brightnessctl
      swww
      inputs.astal.packages.${system}.default
      slurp
      wf-recorder
      wl-clipboard
      wayshot
      swappy
      hyprpicker
      pavucontrol
      networkmanager
      gtk3
    ];
    home-manager.users.lenny = {
      home.file.".config/ags".source = config.ags.configFolder;
    };
  };
}
