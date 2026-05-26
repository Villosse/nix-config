{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.windowManager;
in
  lib.mkIf cfg.fnKeys.enable {
    wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
      "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && touch /tmp/qs-audio-refresh";
      "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && touch /tmp/qs-audio-refresh";
      "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && touch /tmp/qs-audio-refresh";

      "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%- && touch /tmp/qs-brightness-refresh";
      "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+ && touch /tmp/qs-brightness-refresh";
    };
  }
