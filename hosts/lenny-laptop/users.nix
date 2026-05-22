{
  pkgs,
  username,
  config,
  ...
}: {
  users.users = {
    "${username}" = {
      isNormalUser = true;
      description = "${username}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "dialout"
        "libvirtd"
        "kvm"
      ];
      uid = 1000;
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
    "guest" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 5000;
      extraGroups = [config.users.groups.users.name];
    };
  };
}
