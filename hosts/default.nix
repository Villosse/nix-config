{
  inputs,
  outputs,
  ...
}: {
  laptop = let
    username = "lenny";
    stateVersion = "25.05";
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
        stateVersion = stateVersion;
        username = username;
      };
      modules = [
        ./laptop
        ./configuration.nix
      ];
    };
}
