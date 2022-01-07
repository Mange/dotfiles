#!/usr/bin/env bash
# Run after installing dotfiles to perform extra work.

# Install zsh plugins
if [[ -d "${XDG_CONFIG_HOME}/zsh/fzf-tab" ]]; then
  (cd "${XDG_CONFIG_HOME}/zsh/fzf-tab" && git pull --rebase --quiet)
else
  git clone https://github.com/Aloxaf/fzf-tab "${XDG_CONFIG_HOME}/zsh/fzf-tab"
fi

# Clean up left-overs, if found
[ -d ~/.fzf ] && rm -rf ~/.fzf
rm -f ~/.fzf.*

# Migrate some XDG stuff
migrate_xdg() {
  local from="$1"
  local to="$2"

  if [[ -n "$to" ]] && [[ -d "$from" ]] && ! [[ -d "$to" ]]; then
    echo "Moving $from → $to"
    mkdir -p "$(dirname "$to")" && mv "$from" "$to"
  fi
}
migrate_xdg ~/go "$GOPATH"
migrate_xdg ~/.cargo "$CARGO_HOME"
migrate_xdg ~/.rustup "$RUSTUP_HOME"
migrate_xdg ~/.gnupg "$GNUPGHOME"

if [[ "$SHELL" != *zsh ]]; then
  echo "Warning: You seem to be using a shell different from zsh (${SHELL})" >/dev/stderr
  echo "Fix this by running:" >/dev/stderr
  echo "  chsh -s \$(which zsh)" >/dev/stderr
fi
