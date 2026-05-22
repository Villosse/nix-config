{
  inputs,
  outputs,
  ...
}: let
  inherit (inputs) home-manager;
  rootPath = ../.;
in {
  home-manager.useGlobalPkgs = true;
  "lenny@laptop" = home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {
      username = "lenny";
      rootPath = rootPath;
      stateVersion = "25.05";
      inherit inputs outputs;
    };

    modules = [
      ./lenny-laptop
    ];
  };
}
