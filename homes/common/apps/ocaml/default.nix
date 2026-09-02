{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.ocaml;
in {
  options.languages.ocaml = {
    enable = lib.mkEnableOption "OCaml / OxCaml dev env";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default =
        # Toolchain from nixpkgs (tied to the nixpkgs OCaml compiler). When an
        # opam switch is active — e.g. the OxCaml `5.2.0+ox` switch — its
        # `+ox` builds of lsp/ocamlformat/utop take precedence via the
        # switch's PATH; these stay as a zero-setup fallback.
        with pkgs.ocamlPackages; [
          utop # REPL
          dune_3 # build system
          dune-build-info
          merlin # editor intelligence
          ocaml-lsp # LSP server (ocamllsp)
          ocamlformat # formatter
          ocp-indent # indentation
          menhir # parser generator
          findlib # library manager (ocamlfind)
        ];
      description = "OCaml packages to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [
        pkgs.ocaml # compiler
        pkgs.opam # package manager — used to create/manage the OxCaml switch

        # Native from-source build deps. opam builds every package (including
        # the OxCaml compiler switch `5.2.0+ox`) locally from source — no
        # Docker — so the full C/build toolchain must be on PATH.
        pkgs.gnumake
        pkgs.gcc
        pkgs.pkg-config
        pkgs.m4 # OCaml compiler + many opam pkgs need it to configure
        pkgs.rsync # OxCaml's build invokes rsync
        pkgs.unzip # opam unpacks some source archives with it
        pkgs.git # opam fetches repos/pins over git
        pkgs.patch # opam applies package patches
        pkgs.bubblewrap # opam build sandboxing (Linux)
      ]
      ++ cfg.packages;
  };
}
