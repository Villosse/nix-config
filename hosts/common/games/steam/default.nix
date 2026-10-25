{
  pkgs,
  username,
  ...
}: let
  nvidiaEnv = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "PRIME_render_offload";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Expose only the RTX 4050 to Vulkan (the trailing `!` hides the AMD iGPU),
    # so no game can pick RADV. CS2 crashed in its Vulkan renderer with both
    # drivers loaded.
    MESA_VK_DEVICE_SELECT = "10de:28a1!";
  };
in {
  # Steam Configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.steam.override {
      extraEnv = nvidiaEnv;
    };
    # GE-Proton for Windows games that stock Proton handles badly; pick it per
    # game in Properties > Compatibility.
    extraCompatPackages = [pkgs.proton-ge-bin];
    protontricks.enable = true;
  };

  # `gamemoderun %command%`: performance governor + renice while a game runs.
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };
  users.users.${username}.extraGroups = ["gamemode"];

  # `gamescope -f -- %command%`: nested compositor, so a game sees one plain
  # fullscreen output instead of sway's fractional 1.5 scale through XWayland.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "heroic";
      paths = [pkgs.heroic];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/heroic \
          --set __NV_PRIME_RENDER_OFFLOAD 1 \
          --set __VK_LAYER_NV_optimus PRIME_render_offload \
          --set __GLX_VENDOR_LIBRARY_NAME nvidia \
          --set MESA_VK_DEVICE_SELECT '10de:28a1!'
      '';
    })
  ];
}
