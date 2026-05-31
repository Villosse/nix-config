{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.ocaml;
in {
  options.languages.ocaml = {
    enable = lib.mkEnableOption "OCaml dev env";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs.ocamlPackages; [
        utop
        dune_3
        merlin
        ocaml-lsp
        ocp-indent
        menhir
        dune-build-info
      ];
      description = "Ocaml Packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.ocaml] ++ cfg.packages;
  };
}
