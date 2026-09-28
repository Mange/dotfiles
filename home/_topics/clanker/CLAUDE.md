# Global preferences

- I primarily work in Rust and TypeScript, on Linux (usually NixOS).
- Use Bash (`/usr/bin/env bash`) for scripts and general commands, not my
  customized ZSH.
- Python is not installed unless the project needs it. `jq`, `rg`
  (ripgrep) and `fd` are always available.

## Git

- Try to split up large changes into smaller logical commits. This helps
  reviewing and makes history surgery much easier.
- Never sign commits: always pass `--no-gpg-sign` to `git commit` and
  `git rebase`. Signing is for human-made actions.
- Always pass `--no-ext-diff` to git commands that produce diffs.

## Sandboxing

Assume you are running in a sandbox, so if you cannot connect to Github, local
docker containers (Postgres, Redis, etc.) or similar services, try it without
the sandbox first before prompting the user to fix something.
