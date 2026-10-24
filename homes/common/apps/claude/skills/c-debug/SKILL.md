---
name: c-debug
description: Use for C build errors, crashes, undefined behavior, or memory bugs.
---

# C debugging

- Build the way the project does (make/cmake/meson); don't add a build system.
- Debug build: `-Wall -Wextra -g -O0 -fsanitize=address,undefined`. Fix warnings
  that relate to the bug.
- Crash: `gdb -batch -ex run -ex bt --args ./prog <args>`; read the first frame in
  project code.
- clangd needs `compile_commands.json` (cmake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`).
- Tests: use the project's harness; otherwise a minimal `assert`-based test binary
  reproducing the bug, run under the sanitizers.
- Fix the root cause, not the symptom. No casts to silence warnings.
