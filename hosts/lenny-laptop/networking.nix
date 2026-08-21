{...}: {
  networking.hostName = "lenny-laptop";
  networking.networkmanager.enable = true;

  networking.wg-quick.interfaces.wg0 = {
    address = ["10.0.0.5/32"];
    dns = ["1.1.1.1"];
    privateKey = "yO3X5GzXjzw8xn+wJ/1DF9x88kigdjcWnq5gziehGHY=";
    peers = [
      {
        publicKey = "GjZbc3Jv8casTWtyn2bT9GwBRimarnMfG0Air07pykE=";
        endpoint = "bastion.assistants.ing.iaas.epita.fr:2222";
        allowedIPs = ["10.0.0.1/32"];
        persistentKeepalive = 25;
      }
    ];
  };

  services.openssh.enable = true;

  nix.settings = {
    substituters = ["https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr"];
    trusted-public-keys = ["cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo="];
  };
}
