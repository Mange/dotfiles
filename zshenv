export GOPATH="$HOME/Projects/gopath"

function {
  if [[ $customized_paths != "yes" ]]; then
    customized_paths="yes"

    path=(
      /usr/local/sbin
      /usr/sbin
      /sbin

      $HOME/bin
      $HOME/.local/bin

      .git/safe/../../bin

      $HOME/.rvm/bin
      $HOME/.cargo/bin
      $HOME/.yarn/bin

      $GOPATH/bin
      /usr/local/opt/go/libexec/bin

      /opt/*/bin(/N)
      /usr/local/*/bin(/N)
      /usr/local/opt/*/libexec/bin(/N)
      /usr/local/share/npm/bin

      /usr/local/bin

      /usr/local/opt/coreutils/libexec/gnubin(/N)

      "$path[@]"
    )
    typeset -Ugx path # uniq global export
  fi
}

# Non-interactive shells should still get a hold of rvm
# Vim runs zsh with -c; a tty is present but it still isn't interactive
if [ ! -t ] || [[ $VIM != "" ]]; then
  if [[ -s /usr/local/rvm/scripts/rvm ]]; then
    source /usr/local/rvm/scripts/rvm
  elif [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    source "$HOME/.rvm/scripts/rvm"
  fi
fi

