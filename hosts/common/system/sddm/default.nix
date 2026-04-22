{ ... }:
{
  services.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
    wayland.enable = true;
  };

  services.libinput.enable = true;
}
