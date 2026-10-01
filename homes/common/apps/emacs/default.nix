# Emacs entry point. Each topic lives in its own module (imported below) and
# contributes its own packages + elisp; home-manager merges `extraPackages`
# and concatenates `extraConfig` (ordered via `lib.mkOrder`) into one default.el.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./ui.nix # core UI, sane defaults, font, transparency   (order 200)
    ./theme.nix # theme, modeline, icons, which-key          (order 300)
    ./completion.nix # vertico family + corfu + cape          (order 500)
    ./editing.nix # expand-region, avy                        (order 500)
    ./vcs.nix # magit, projectile                             (order 500)
    ./ai.nix # copilot + copilot-chat                         (order 500)
    ./lsp.nix # eglot + language modes                        (order 500)
    ./mail.nix # mu4e mail UI                                 (order 500)
  ];

  programs.emacs = {
    enable = true;
    # pgtk = native Wayland: alpha-background transparency works (XWayland
    # doesn't composite it). GUI-only now, so pgtk's old TTY-renderer bug is
    # irrelevant (terminal editing is vim).
    package = pkgs.emacs-pgtk;

    # Packages not owned by a topic module: the use-package bootstrap and the
    # keycast HUD (shows keystrokes/commands — toggle with `M-x keycast-mode`).
    extraPackages = epkgs:
      with epkgs; [
        use-package
        keycast

        # early-init: loaded BEFORE `package-activate-all' (nixpkgs patches
        # Emacs to load an `early-default' library right after early-init.el).
        # home-manager's `extraConfig' only writes default.el, which runs AFTER
        # activation -- too late for these fixes, hence this package. Both are
        # upstream bugs in other people's files; drop each when fixed there.
        (trivialBuild {
          pname = "early-default";
          version = "1";
          src = pkgs.writeText "early-default.el" ''
            ;;; early-default.el --- pre-activation fixes -*- lexical-binding: t; -*-

            ;; typst-ts-mode's generated autoloads inline a
            ;; `define-compilation-mode' form without requiring `compile' first
            ;; (unlike typst-ts-compile.el, which does). At package activation
            ;; the macro is undefined, logging "Error loading autoloads:
            ;; (void-function define-compilation-mode)". Define it in time.
            (require 'compile)

            ;; Several OCaml CLI packages (dune, merlin, utop, ...) ship .el
            ;; files into ~/.nix-profile/share/emacs/site-lisp, which nix's
            ;; site-start.el puts at the FRONT of `load-path'. Those bare .el
            ;; copies shadow the properly byte-compiled epkgs versions, and
            ;; dune.el/dune-flymake.el lack a `lexical-binding' cookie -- so
            ;; loading dune warned on every startup. Move the profile dir to the
            ;; BACK so the epkgs .elc wins (no warning, and it is compiled).
            ;; The profile dir stays on the path as a fallback for tools with no
            ;; epkgs equivalent (merlin, ocp-indent, utop).
            (let ((profile-site-lisp
                   (expand-file-name "~/.nix-profile/share/emacs/site-lisp")))
              (when (member profile-site-lisp load-path)
                (setq load-path
                      (append (delete profile-site-lisp load-path)
                              (list profile-site-lisp)))))
          '';
        })
      ];

    # Bootstrap: runs first (order 100) so every topic module's `use-package`
    # forms resolve. Packages come from Nix, so package.el is unused.
    extraConfig = lib.mkOrder 100 ''
      ;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

      ;; Packages are provided by Nix (see default.nix), so package.el is unused.
      (require 'use-package)
      (setq use-package-always-ensure nil)
    '';
  };

  # LSP servers must be on PATH for eglot. Since Emacs runs as a systemd
  # daemon, they need to be in home.packages (the daemon's environment),
  # not just an interactive shell.
  home.packages = with pkgs; [
    ocamlPackages.ocaml-lsp # OCaml
    nixd # Nix
    clang-tools # C / C++ (clangd)
    yaml-language-server # YAML
    tinymist # Typst
    pyright # Python
    # Not needed by copilot.el (nixpkgs patches `copilot-server-executable' to
    # this binary's absolute store path, so no $PATH lookup happens). Kept for
    # interactive use; it's already in the closure via epkgs.copilot, so free.
    copilot-language-server

    # Launch a GUI Emacs frame off the daemon. Named so bemenu-run (which lists
    # $PATH executables) finds it — search "emacs-gui" in the launcher.
    (writeShellScriptBin "emacs-gui" ''
      exec ${pkgs.emacs-pgtk}/bin/emacsclient -c -a emacs "$@"
    '')
  ];

  # Single background daemon; `emacsclient` connects instantly.
  # defaultEditor is false: TTY editing is vim now, GUI Emacs is launched via
  # `emacs-gui` (bemenu) or the `ec` alias.
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = false;
  };
}
