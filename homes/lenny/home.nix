{ inputs, config, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/git
    ../../modules/vim
    ../../modules/firefox
    ../../modules/nh
  ];

  users.users.lenny = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "input"
      "video"
      "audio"
      "libvirtd"
      "disk"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.lenny = { pkgs, ... }: {
      programs.home-manager.enable = true;
      xdg.enable = true;
      home.username = "lenny";
      home.homeDirectory = "/home/lenny";
      home.stateVersion = "23.11";
      home.sessionVariables = {
        EDITOR = "vim";
        BROWSER = "firefox";
        TERMINAL = "kitty";
      };
    };
  };

}
