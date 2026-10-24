---
name: ocaml-dev
description: Use for OCaml/OxCaml work — dune builds, type errors, opam switches, tests.
---

# OCaml / OxCaml

Build loop
- `dune build 2>&1 | head -40`; fix the first error first, rebuild.
- Format with `dune fmt` only if the project has `.ocamlformat`.

Type errors
- Read expected vs actual type; check the `.mli` before changing an implementation.
- Inspect types with `ocamlmerlin` or `dune utop` instead of guessing.

Tests
- Use the repo's existing framework. Default: ppx_expect inline tests,
  `dune runtest` then `dune promote` after checking the diff is intended.
- Cover the changed behavior only; no snapshot spam.

OxCaml
- Compiler lives in an opam switch (e.g. `5.2.0+ox`), not on the global PATH:
  check `opam switch show` and run tools via `opam exec --`.
- Preserve existing mode/layout annotations (`local_`, `@ local`, unboxed layouts);
  don't strip them to make code compile.
