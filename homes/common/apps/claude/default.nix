# Claude Code, Anthropic's official CLI.
#
# Uses home-manager's `programs.claude-code` module, which puts
# `pkgs.claude-code` on PATH. Before this it was only ever run from an ad-hoc
# `nix-shell`, so nothing pinned it.
#
# Skills are managed: every folder in ./skills (holding a SKILL.md) is picked
# up automatically and linked as ~/.claude/skills/<name>/. This uses the
# attrset form of `skills`, which links each skill separately, so
# ~/.claude/skills itself stays a real directory the CLI can still write to
# (it keeps its own `synced/` skills there). Never switch to the path form
# (`skills = ./skills;`): it replaces the whole directory with a store symlink.
#
# `settings` (~/.claude/settings.json), `context` (~/.claude/CLAUDE.md),
# `plugins`, `mcpServers` and `lspServers` are deliberately left unset — they
# deploy read-only store symlinks into files the CLI writes to itself
# (`/config`, memory, credentials, session state). A managed settings.json
# would both fail the switch by clobbering the existing file and stop
# `/config` from being able to save. Left hand-managed.
{
  lib,
  pkgs,
  ...
}: let
  skillsDir = ./skills;
  ownSkills =
    lib.mapAttrs (name: _: skillsDir + "/${name}")
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir));

  # Upstream skills, pinned and cherry-picked: only the listed folders are
  # linked. Read a skill before adding it here; it becomes instructions to Claude.
  pick = src: dir: names: lib.genAttrs names (name: "${src}/${dir}/${name}");

  # OCaml / OxCaml (ISC).
  ocamlSkills =
    pick (pkgs.fetchFromGitHub {
      owner = "avsm";
      repo = "ocaml-claude-marketplace";
      rev = "9a580e6e3d660ed2f9cd55ceaa64f6d1e90d4f01";
      hash = "sha256-yh0d/Qyo0dNcdDyaxnAoPhbdUfTjWKVY0xvnlgkzREs=";
    }) "plugins/ocaml-dev/skills" [
      "ocaml"
      "code-style"
      "doc-style"
      "testing"
      "result"
      "effects"
      "eio"
      "logs"
      "cmdliner"
      "memtrace"
      "oxcaml"
      "review-ocaml"
    ];

  # General engineering discipline (MIT). Only the light, on-demand ones: the
  # rest of superpowers forces plans/brainstorming/subagents on every task.
  superpowersSkills =
    pick (pkgs.fetchFromGitHub {
      owner = "obra";
      repo = "superpowers";
      rev = "2ce8aa15d05bd57213e6f746f953aafb7ded7a8b";
      hash = "sha256-9+69YEdjdaDu5sWTyAbufSVcZgGD7h6wAq4nUVY2syE=";
    }) "skills" [
      "systematic-debugging"
      "verification-before-completion"
      "receiving-code-review"
    ];
in {
  programs.claude-code = {
    enable = true;
    # Own skills last, so they win on a name clash.
    skills = ocamlSkills // superpowersSkills // ownSkills;
  };
}
