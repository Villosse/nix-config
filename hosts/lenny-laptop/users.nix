{
  pkgs,
  username,
  ...
}: {
  fileSystems."/home/guest" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=2G"
      "mode=0700"
      "uid=5000"
      "gid=100"
      "nodev"
      "nosuid"
      "noexec"
    ];
  };

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
      shell = pkgs.bash;
      uid = 5000;
      home = "/home/guest";
      initialPassword = "guest";
      # No extraGroups — keeps guest isolated from other users' home dirs
      # /home/guest is a tmpfs mount — wiped on every reboot
    };
  };
}
