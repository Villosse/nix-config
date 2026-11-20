{...}: {
  networking.hostName = "lenny-laptop";
  networking.networkmanager.enable = true;

  # Nothing on this host needs the network up before login, and waiting on the
  # WPA-Enterprise handshake cost ~57s of every boot. NetworkManager still
  # connects normally in the background.
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh.enable = false;

  services.tailscale = {
    enable = true;
    # Opens UDP 41641 so peers can connect directly instead of via DERP.
    openFirewall = false;
    # Lets lenny run `tailscale up/down` without sudo.
    extraSetFlags = ["--operator=lenny"];
  };

  nix.settings = {
    substituters = ["https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr"];
    trusted-public-keys = ["cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo="];
  };
}
