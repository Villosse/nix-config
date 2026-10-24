{
  pkgs,
  username,
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
      shell = pkgs.bash;
      ignoreShellProgramCheck = true;
    };
  };
}
