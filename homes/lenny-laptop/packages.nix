{
  pkgs,
  inputs,
  ovm,
  ...
}: {
  home.packages = with pkgs; [
    inputs.nixvim.packages.x86_64-linux.default
    inputs.ovm.packages.x86_64-linux.default
    nodejs_24
    yarn
    #    zulip

    docker-compose
    discord
  ];
}
