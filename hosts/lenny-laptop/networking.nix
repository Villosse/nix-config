{ ... }:
{
  networking.hostName = "lenny-laptop";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;

  nix.settings = {
    substituters = [ "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr" ];
    trusted-public-keys = [ "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=" ];
  };
}
