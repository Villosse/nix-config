# Claude Code, Anthropic's official CLI.
#
# Uses home-manager's `programs.claude-code` module, which puts
# `pkgs.claude-code` on PATH. Before this it was only ever run from an ad-hoc
# `nix-shell`, so nothing pinned it.
#
# Only `enable` is set on purpose. The module can also manage `settings`
# (~/.claude/settings.json), `context` (~/.claude/CLAUDE.md), `skills`,
# `plugins`, `mcpServers` and `lspServers` — but those deploy read-only store
# symlinks into ~/.claude, which the CLI writes to itself (`/config`, memory,
# credentials, session state). ~/.claude already holds live state, and a
# managed settings.json would both fail the switch by clobbering the existing
# file and stop `/config` from being able to save. Left hand-managed.
{
  programs.claude-code = {
    enable = true;
  };
}
