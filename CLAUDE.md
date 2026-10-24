# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key commands

```bash
# Apply home-manager config (most common)
home-manager switch --flake .#lenny --refresh

# Apply NixOS system config
sudo nixos-rebuild switch --flake .#laptop
# NB: the flake attr is `laptop` but networking.hostName is still `lenny-laptop`,
# so the attr must always be given explicitly — bare `--flake .` will not resolve.

# Format nix files
nix fmt

# After home-manager switch, reload sway config
swaymsg reload

# Restart a systemd user service manually
systemctl --user restart <service>
```

## Architecture

This is a Nix flake managing both NixOS system configs (`nixosConfigurations`) and home-manager configs (`homeConfigurations`) for a single user (lenny) on a laptop.

- `flake.nix` — entry point, wires inputs (nixpkgs unstable + stable, home-manager, nixvim, ovm) and outputs
- `hosts/` — NixOS system configurations (hardware, kernel, system packages)
- `homes/` — home-manager configurations per user/machine
  - `homes/common/` — shared modules imported by all profiles: apps, windowManagers, widgets, scripts
  - `homes/lenny/` — the user profile, imports from common; `homes/lenny/displays.nix` holds the machine-specific bits (display ports, scale, wallpaper, lockscreen, Fn keys) via the `windowManager` option
- `modules/` — custom NixOS and home-manager modules (option declarations)
- `pkgs/` — custom packages
- `overlays/` — nixpkgs overlays

## Quickshell bar

The bar is managed by `homes/common/widgets/quickshell/`. Config lives in `./config/` (QML files), deployed via `xdg.configFile."quickshell".source = ./config`. Quickshell runs as a systemd user service that carries `X-Restart-Triggers` on the config path (must be a string: `"${...}"`). As with Emacs, that doesn't reliably restart user units, so run `systemctl --user restart quickshell` after a switch.

- `bar/Bar.qml` — root panel window, layout only (left/center/right)
- `bar/Theme.qml` — `pragma Singleton` palette (Catppuccin Macchiato), font, pill metrics. Quickshell picks the singleton up without a `qmldir`. Never hardcode hex colours in widgets.
- `bar/BarPill.qml` — base for every pill (`text`, `tooltip`, `clicked`/`rightClicked`/`wheel(delta)`)
- `bar/Tooltip.qml` — `PopupWindow` anchored below its target. Tooltips must be popups: anything drawn above y=0 inside the bar is clipped.
- `bar/SystemRings.qml` — CPU/RAM/GPU rings polled via `Process`. The GPU ring shows `--` when `nvidia-smi` fails, typically "Driver/library version mismatch" after a rebuild bumps the NVIDIA driver without a reboot.
- `bar/RingWidget.qml` — single ring: arc canvas + icon + percentage inline at center
- `bar/Notifications.qml` — swaync state via `swaync-client --subscribe-waybar`. Left click toggles DND, right click opens the panel.
- Workspaces/window title use `Quickshell.I3` / `ToplevelManager`, and audio uses `Quickshell.Services.Pipewire`. No polling for these (Fn volume keys need no refresh hook). Brightness, battery, network and CPU/RAM still poll.
- All `sh -c` commands in QML need `PATH` set — handled in the systemd service `Environment`
- Test the working tree without switching: `quickshell -p homes/common/widgets/quickshell/config` (runs a second bar; Ctrl-C to stop)

## Sway

Config in `homes/common/windowManagers/sway/default.nix`. The `windowManager` option (defined in `modules/home-manager`) lets each machine profile set display ports, scale, wallpaper, lockscreen. Gaps: `inner=5, outer=0`.

## Emacs

Config in `homes/common/apps/emacs/`:

- `default.nix` — installs **`pkgs.emacs-pgtk`** (native Wayland), Emacs packages via `extraPackages`, and runs Emacs as a systemd **daemon** (`services.emacs`). Also puts LSP server binaries in `home.packages`, plus an `emacs-gui` wrapper (`emacsclient -c -a emacs`) so bemenu can launch a GUI frame.
- Per-topic modules — there is **no `init.el`** (it was removed in `b320ed7`). Each module contributes its own `extraPackages` + `extraConfig`, which home-manager merges and concatenates (ordered via `lib.mkOrder`) into one generated `default.el`: `ui.nix` (core UI, font, transparency, temp-file settings — order 200), `theme.nix` (theme, modeline, icons, which-key — 300), then at order 500 `completion.nix`, `editing.nix`, `vcs.nix`, `ai.nix` (Copilot), `lsp.nix`, `mail.nix`.

**Editor split (important):** GUI Emacs is the primary editor for real work; **vim (nvim) is the TTY editor**. The TTY Emacs renderer could never guarantee zero ghost lines on async LSP updates, so terminal editing was abandoned. Wiring: `EDITOR=nvim` in zsh, `core.editor=nvim` in git, `services.emacs.defaultEditor = false`. Launch GUI Emacs via `emacs-gui` (search it in bemenu) or the `ec` alias. The `e` alias (`emacsclient -t`) still exists but is not the default.

Key facts (gotchas that cost real debugging):

- **Must be `pkgs.emacs-pgtk`, not `pkgs.emacs`.** GUI transparency (`alpha-background`) only composites on native Wayland; the standard build runs via XWayland where sway won't composite it. `ui.nix` sets `alpha-background 85` on `default-frame-alist` + the current frame + `after-make-frame-functions` (the daemon serves frames created after startup).
- **LSP servers must be in `home.packages`**, not just an interactive shell — the daemon's PATH is what eglot sees. Servers: ocaml-lsp, nixd, clang-tools (clangd), yaml-language-server, tinymist (typst), pyright.
- **eglot inlay hints are disabled** (`:inlayHintProvider`) — they cluttered code with `nmemb:` / `size:` style labels.
- **nerd-icons need the dedicated symbol font.** Install `nerd-fonts.symbols-only` (SYSTEM font, `hosts/laptop/default.nix` → needs `nixos-rebuild`) AND set `nerd-icons-font-family "Symbols Nerd Font Mono"` in `theme.nix`. IosevkaTerm's Nerd patch is incomplete and renders some icons (e.g. the `.nix` filetype icon) as tofu. IosevkaTerm Nerd Font remains the *default text* face.
- **No color emoji in GUI — do not add `emojify`.** This pgtk build renders color-emoji fonts (Noto CBDT, Twitter SBIX) as tofu. `emojify` renders emoji as images but does network I/O + a stdin y/n prompt at startup, which crash-loops then freezes the headless daemon. One dashboard-footer emoji shows as a box; that's accepted.
- **Copilot chat — install exactly one implementation.** copilot.el (0.9.0+) bundles a full first-party `copilot-chat.el`, so the standalone `copilot-chat` package is deliberately **not** installed and `ai.nix` has no `load-path` hack. Both files `(provide 'copilot-chat)`, so adding the separate package back makes load order decide which wins. Also do **not** set `copilot-server-executable`: nixpkgs already patches it to copilot-language-server's absolute store path, and overriding it with a bare name downgrades that to a `$PATH` lookup. Completion keys (TAB, C-<tab>, M-n/M-p) are bound upstream in `copilot-completion-map` — re-binding them via `:bind` forces an eager load at daemon startup.
- **No temp files:** backups, autosaves, and lockfiles are all disabled in `ui.nix`.

### AI in Emacs — current state and options

**Copilot chat is pinned to `copilot-chat-model = "auto"` because the GitHub Copilot
Student plan allows nothing else.** As of GitHub's 2026-03-12 change, free student accounts
cannot self-select premium models (Claude Opus/Sonnet, GPT-5.4); the model picker is
reduced to `auto`, which routes to those models server-side without naming one. This is an
account entitlement, not a config bug — restarting the daemon or the language server will
not add models. Verified on this account: the server returns exactly `("auto")`.

Check what the account actually offers (authoritative — beats guessing a slug, since
`copilot-chat-model` is sent verbatim and an id you lack fails every turn with
"No model configuration found for id ..."):

```elisp
M-: (mapcar (lambda (m) (plist-get m :id)) (copilot-chat--chat-models))
```

If that errors with "Not authenticated ... 401", the token is stale: `M-x copilot-logout`,
`M-x copilot-login`, then restart the daemon (copilot.el caches a failed model lookup for
the whole session, so chat keeps failing until that cache clears).

Unlocking manual model selection requires Copilot Pro/Pro+/Enterprise. Inline completion
and NES are unaffected by the restriction and work fully on the student plan.

**If explicit Gemini/Claude model choice is wanted later**, these are in nixpkgs-unstable
(none currently installed):

- `gptel` — backends for Anthropic, Gemini, OpenAI, Ollama, Kagi, Bedrock, plus
  `gptel-gh.el` (a Copilot backend, which would hit the same `auto`-only entitlement, so
  it is not a workaround). Per-buffer/per-request model choice.
- `claude-code` — wraps the Claude Code CLI in a vterm buffer (needs `vterm`;
  `projectile` is already installed via `vcs.nix`).
- `aidermacs` — Emacs frontend to `aider`, multi-file agentic edits.
- `ellama` — Ollama, fully local.

**Billing gotcha worth remembering:** a Claude Pro/Max or Gemini Advanced *chat*
subscription is NOT API access. `gptel` needs an API key from console.anthropic.com or
aistudio.google.com, billed separately. Two no-extra-cost routes: the Google AI Studio
**free** Gemini API tier (no card), or `claude-code`, which runs on an existing Claude
Pro/Max subscription with no key. Any API key belongs in sops (`sops-nix` is already wired
here — see the mu4e mail secret for the pattern), never in the repo.

After editing config: `home-manager switch` then `systemctl --user restart emacs` (the `X-Restart-Triggers` on the unit does not reliably restart user services under home-manager — "Keeping old units" — so restart it yourself). Frame hooks only apply to frames created after the restart, so reopen your Emacs frame.

## Terminal (rio)

Terminal emulator is **rio** (`homes/common/apps/rio/`), replacing ghostty. Uses `pkgs.rio` (prebuilt; building from source is slow). Config in `programs.rio.settings` (Catppuccin Macchiato, IosevkaTerm Nerd Font, `opacity = 0.85`, `confirm-before-quit = false` so Mod+Q closes instantly). sway launches it (`Mod+Return`, default `terminal`).

- **Patched terminfo (`rio/terminfo.nix`).** rio's packaged terminfo lacks `Sync` (mode 2026) and `Tc` (truecolor) even though rio supports both at runtime → caused Emacs TTY ghost lines + washed-out colors. The module compiles a patched `rio` entry (`use=rio` + `Sync` + `Tc`) via `tic -x` and puts it first on `TERMINFO_DIRS`.
- **Extra keybinds for TUI apps** (`bindings.keys`): Ctrl+Left/Right send `\E[1;5D`/`\E[1;5C` (word motion), Shift+Enter sends `\E\r` (newline in claude-code). Note `with` is a Nix keyword — quote it as `"with"`.

## Claude Code

`homes/common/apps/claude/` enables home-manager's `programs.claude-code`, which puts
`pkgs.claude-code` on PATH. Before this it was only run from an ad-hoc `nix-shell`.

**Skills are managed and auto-discovered.** Drop a folder
`homes/common/apps/claude/skills/<name>/` containing a `SKILL.md` (frontmatter `name` +
`description`) and it is linked as `~/.claude/skills/<name>/` on the next switch — no
per-skill wiring. This uses the *attrset* form of `skills` (one link per skill), so
`~/.claude/skills/` stays a real directory and the CLI's own `synced/` skills keep working.
Never use the *path* form (`skills = ./skills;`): it replaces the whole directory with a
store symlink. Upstream skills are cherry-picked from pinned `fetchFromGitHub` sources in
the same module (`avsm/ocaml-claude-marketplace`, `obra/superpowers`) — read a skill before
adding it to a `pick` list, and bump `rev` + `hash` together to update.

**Everything else is deliberately unset.** The module can also manage `settings`
(`~/.claude/settings.json`), `context` (`~/.claude/CLAUDE.md`), `plugins`,
`mcpServers` and `lspServers` — but each deploys a read-only store symlink into `~/.claude`,
which the CLI writes to itself (`/config`, memory, credentials, session state). Two
consequences if you turn them on: the switch fails on any pre-existing unmanaged file
(`~/.claude/settings.json` already exists), and `/config` can no longer save. Note
`settings.json` is only written when `settings != {}`, so a bare `enable = true` touches
nothing under `~/.claude`.

## OCaml / OxCaml

Dev toolchain lives in `homes/common/apps/ocaml/default.nix` (option `languages.ocaml.enable`, turned on in the laptop profile). It installs, **globally on PATH**, the OCaml tooling from nixpkgs — `ocaml`, `dune`, `utop`, `merlin` (`ocamlmerlin`), `ocaml-lsp` (`ocamllsp`), `ocamlformat`, `ocp-indent`, `menhir`, `findlib` — plus `opam` and the full native build toolchain (`gcc`, `gnumake`, `pkg-config`, `m4`, `rsync`, `unzip`, `git`, `patch`, `bubblewrap`).

The point of the native toolchain is that **you can compile OxCaml / OCaml / opam packages / dune projects from source, with no Docker.** `opam` builds everything locally against these tools. The **OxCaml compiler itself is intentionally NOT installed** — it is not in nixpkgs and does not build reliably under Nix; when you want it you build it via opam yourself:

```bash
opam switch create 5.2.0+ox --repos ox=git+https://github.com/oxcaml/opam-repository.git,default
```

but that is a manual, on-demand step — the module only guarantees the *packages needed to compile* are present, not the OxCaml compiler on PATH.

## Formatter

Uses `alejandra` (`nix fmt`). Always format before committing.
