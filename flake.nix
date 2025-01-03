{
  description = "test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    marble = {
      url = "git+ssh://git@github.com/marble-shell/shell.git";
      inputs.nixpkgs.follows = "nixpkgs";
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
