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

## Jujutsu / JJ

> [!NOTE]
> `jj` **is not Git**. I don't know why I need to state this.
>
> If a project uses `jj` instead of `git`, then the Git rules above do not
> apply.

- Before making changes to a JJ repo, make sure you are on a new unnamed commit,
  or create a new commit for the task.
  - JJ's workflow is to create a new commit **first** then make changes.
- Try to split up large changes into smaller logical commits. This helps
  reviewing and makes history surgery much easier.
- Always pass `--tool=:git` to `jj diff` to get a standard, non-visual,
  diff. I use a custom differ.
- Never push to a remote. Pushing commits will sign them with the user's GPG
  key, so only the user is allowed to push.

## Sandboxing

Assume you are running in a sandbox, so if you cannot connect to Github, local
docker containers (Postgres, Redis, etc.) or similar services, try it without
the sandbox first before prompting the user to fix something.
