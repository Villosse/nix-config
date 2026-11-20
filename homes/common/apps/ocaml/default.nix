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

          # Libraries opam's ./configure looks up through findlib
          re
          base64
          ocamlgraph
          # opam wants cudf >= 0.11~rc1 but nixpkgs has 0.10, which opam builds
          # against fine: only the findlib label changes. Drop on a nixpkgs bump.
          (cudf.overrideAttrs (old: {
            doCheck = false;
            postInstall =
              (old.postInstall or "")
              + ''
                sed -i 's/^version = .*/version = "0.11"/' \
                  $out/lib/ocaml/${ocaml.version}/site-lib/cudf/META
              '';
          }))
          dose3
          opam-file-format
          spdx_licenses
          opam-0install-cudf
          jsonm
          uutf
          sha
          swhid_core
          patch
          tar
          checkseum
          decompress
          mccs

          # Their propagated deps: home.packages only links what is listed
          seq
          extlib
          stdlib-shims
          _0install-solver
          uchar
          optint
        ];
      description = "OCaml packages to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ocamlfind only searches its own store path otherwise. In .bashrc, not
    # home.sessionVariables: those need a re-login to reach new terminals.
    # Leaks into opam switches: `unset OCAMLPATH` there if libraries clash.
    programs.bash.initExtra = ''
      export OCAMLPATH="${config.home.profileDirectory}/lib/ocaml/${pkgs.ocamlPackages.ocaml.version}/site-lib"
    '';

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
