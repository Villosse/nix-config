{ inputs, config, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/git
    ../../modules/vim
    ../../modules/firefox
    ../../modules/nh
    ../../modules/discord
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
  
  vesktop.enable = true;

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
      #home.packages = with pkgs; [ tree ];
      home.sessionVariables = {
        EDITOR = "vim";
        BROWSER = "firefox";
        TERMINAL = "kitty";
      };
    };
  };

}
