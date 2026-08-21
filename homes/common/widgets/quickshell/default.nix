{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.quickshell];
  xdg.configFile."quickshell".source = ./config;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell bar";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target" "sway-session.target"];
      Wants = ["sway-session.target"];
    };
    Service = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'until ${pkgs.sway}/bin/swaymsg -t get_version &>/dev/null; do sleep 0.5; done'";
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = 2;
      RestartTriggers = [config.xdg.configFile."quickshell".source];
      Environment = "PATH=${pkgs.lib.makeBinPath [pkgs.bash pkgs.coreutils pkgs.gawk pkgs.procps pkgs.sway pkgs.pipewire pkgs.networkmanager pkgs.brightnessctl]}:/run/current-system/sw/bin";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
