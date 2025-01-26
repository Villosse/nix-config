{ inputs
, pkgs
, modules
, pkgs-local
, ...
}:
let
  inherit (inputs) home-manager;
  rootPath = ../.;
in
{
  home-manager.useGlobalPkgs = true;
  "pie" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      username = "lenny.chiadmi-delage";
      rootPath = rootPath;
      stateVersion = "25.05";
      inherit pkgs-local;
    };

    modules = [
      ./pie.nix
    ] ++ modules;
  };
}
