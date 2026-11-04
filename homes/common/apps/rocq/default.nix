{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.rocq;

  # Wraps every binary with ROCQPATH, so rocq and coq-lsp find the stdlib even
  # from the Emacs daemon, which has no ROCQPATH of its own.
  rocqEnv = pkgs.rocq-core.withPackages (ps: [
    ps.stdlib
    ps.coq-lsp # LSP server
  ]);
in {
  options.languages.rocq.enable = lib.mkEnableOption "Rocq prover dev env";

  config = lib.mkIf cfg.enable {
    # Only the Rocq binaries: rocqEnv's bin/ also holds tools from Rocq's own
    # OCaml 4.14 set (menhir, ...), which must not clash with languages.ocaml.
    home.packages = [
      (pkgs.runCommand "rocq-tools" {} ''
        mkdir -p $out/bin
        ln -s ${rocqEnv}/bin/{rocq,rocqchk,coq-lsp} $out/bin/
      '')
    ];
  };
}
