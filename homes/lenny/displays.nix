# Machine-specific settings for the laptop this user profile runs on.
# Kept out of default.nix because the home config is keyed by user, not by host:
# everything in here is the one part that would change on a different machine.
{rootPath, ...}: {
  windowManager = {
    # quotidien.png outside Halloween
    wallpaper = "${rootPath}/assets/Wallpapers/spooky-pixel.png";
    lockscreen = "${rootPath}/assets/Wallpapers/guitarGirlOnAtower.png";
    primaryDisplay = {
      # Matched by make/model/serial, not "eDP-N": the connector number depends
      # on which GPU driver registers first at boot. Since the open NVIDIA
      # modules, the dGPU's (unused) eDP takes eDP-1 and the panel became eDP-2.
      port = "BOE 0x0C85 Unknown";
      scale = 1.5;
      width = 2560;
      height = 1600;
      refreshRate = 120;
    };
    secondaryDisplay = {
      port = "HDMI-A-1";
      scale = 1;
      x = 1920;
      y = 0;
      transform = 0;
    };

    fnKeys.enable = true;
  };
}
