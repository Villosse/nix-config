{pkgs, ...}: {
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
    libvirtd.enable = true;
  };

  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "root";
    permissions = "u+rx,g+x,o+x";
  };
}
