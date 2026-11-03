# Antigravity CLI (`agy`), Google's Gemini agent in the terminal. It replaces
# gemini-cli, which stopped serving individual accounts on 2026-06-18.
#
# Mostly here so Claude Code can delegate to Gemini through the `antigravity`
# skill (homes/common/apps/claude/skills/antigravity). Unfree, allowed by
# homes/lenny/nixpkgs.nix. Log in once by running `agy` interactively.
{pkgs, ...}: {
  home.packages = [pkgs.antigravity-cli];
}
