{ inputs, config, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    #../../modules/git
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

  time.timeZone = "Europe/Paris";
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    sharedModules = [
      { imports = [ ../../modules/git ]; }
    ];
    users.lenny = { pkgs, ... }: {
      programs.home-manager.enable = true;
      xdg.enable = true;
      home.username = "lenny";
      home.homeDirectory = "/home/lenny";
      home.stateVersion = "23.11";
      home.packages = with pkgs; [ tree vscode ];
      home.sessionVariables = {
        EDITOR = "vim";
        BROWSER = "firefox";
        TERMINAL = "kitty";
      };
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };

}
