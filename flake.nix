{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    futils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };

    fine-cmdline = {
      url = "github:vonheikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, futils, home-manager, stylix, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (futils.lib) eachDefaultSystemMap;

      system = "x86_64-linux";
      username = "lenny";

      mkDefaultArgs = system:
        let
          pkgs = import nixpkgs {
            config.allowUnfree = true;
            config.allowUnsupportedSystem = true;
            inherit system;
          };
          pkgs-local = self.packages.${system};
        in
        {
          inherit (self) inputs;
          inherit
            pkgs
            pkgs-local
            system
            username
            lib
            ;
        };

      generateModules = modules: lib.attrsets.genAttrs modules (name: import (./modules + "/${name}"));

      defaultArgs = mkDefaultArgs system;
    in rec {
      packages = eachDefaultSystemMap (system:
        let
          defaultArgs = mkDefaultArgs system;
        in
        {
          home-manager = home-manager.defaultPackage.${system};
        } // (import ./packages defaultArgs));

      nixosModules = (generateModules [
        "grub"
        "nh"
        "sddm"
        "steam"
        "stylix"
      ]);

      homeManagerModules = generateModules [
        "alacritty"
        "bemenu"
        "dunst"
        "firefox"
        "git"
        "gtk"
        "i3"
        "hyprland"
        "mako"
        "nvim"
        "polybar"
        "waybar"
        "zsh"
      ];

      nixosConfigurations =
        let
          modules = {
            homeManager = lib.attrsets.attrValues homeManagerModules;
            nixos = lib.attrsets.attrValues nixosModules;
          };
        in
        (
          import ./hosts (defaultArgs // {
            inherit modules;
          })
        );

      homeConfigurations = (
        import ./homes (defaultArgs // {
          modules = lib.attrsets.attrValues homeManagerModules;
        })
      );

      formatter = eachDefaultSystemMap (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
