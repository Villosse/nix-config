{pkgs, ...}: let
  nvidiaEnv = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "PRIME_render_offload";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
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
          --set __GLX_VENDOR_LIBRARY_NAME nvidia
      '';
    })
  ];
}
