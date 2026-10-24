---
name: nix-debug
description: Use when a nix eval/build, home-manager switch, or nixos-rebuild fails in this flake.
---

# Nix debugging

1. Reproduce narrowly instead of a full switch:
   - HM option: `nix eval .#homeConfigurations.lenny.config.<option>`
   - HM build: `nix build .#homeConfigurations.lenny.activationPackage`
   - System: `nix build .#nixosConfigurations.laptop.config.system.build.toplevel`
2. Add `--show-trace`; the useful frame is usually the last one in a repo file.
3. Common causes:
   - New file not `git add`ed → invisible to the flake ("does not exist").
   - Bare `--flake .` → always give `#laptop` / `#lenny`.
   - "would be clobbered" → an unmanaged file exists at the target path.
   - Option renamed upstream → check the module source in the store, not memory.
4. `nix fmt` (alejandra) before finishing.
5. Apply: `home-manager switch --flake .#lenny`; restart affected user services
   yourself (`systemctl --user restart <svc>`), HM may keep old units.
