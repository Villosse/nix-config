---
name: lean-code
description: Use when writing or editing code. Smallest correct diff, matching the repo's style, no filler.
---

# Lean code

- Smallest diff that solves the task. Don't touch unrelated code.
- Match surrounding style: naming, idiom, formatting, comment density.
- No unrequested abstractions, helpers, options, wrappers, or "future-proofing".
- No defensive checks for cases that can't happen; validate only at real boundaries.
- Comments say *why*, never narrate *what*. Don't add docstrings to untouched code.
- Reuse existing functions in the repo before writing new ones.
- No new dependencies unless asked.
- OSS/team repos: follow CONTRIBUTING, commit conventions, and keep changes PR-sized.
- Reply tersely: what changed and anything the user must do. No recap of the diff.
