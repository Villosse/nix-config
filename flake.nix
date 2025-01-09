{
  description = "test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";

    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
      inputs.hyprpanel.overlay
      ];
    };
  in
  {
    nixosConfigurations = {
      "ulterior-motives" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system pkgs; };

        modules = [
          ./hosts/ulterior-motives/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      lenny = pkgs.home-manager.lib.homeManagerConfiguration {
        user = "lenny";
        config = ./homes/lenny/home.nix;
      };
    };
  };
}
