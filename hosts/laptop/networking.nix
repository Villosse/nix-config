{...}: {
  networking.hostName = "lenny-laptop";
  networking.networkmanager.enable = true;

  # Nothing on this host needs the network up before login, and waiting on the
  # WPA-Enterprise handshake cost ~57s of every boot. NetworkManager still
  # connects normally in the background.
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh.enable = true;

  nix.settings = {
    substituters = ["https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr"];
    trusted-public-keys = ["cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo="];
  };
}
