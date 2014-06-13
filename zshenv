export GOPATH="$HOME/Projects/gopath"

function {
  if [[ $customized_paths != "yes" ]]; then
    customized_paths="yes"

    # Macs do unholy things to the PATH when spawning subshells; so we work
    # around it by clearing first to a sane default
    if [ -d /etc/paths.d ]; then
      path=(
        $(cat /etc/paths /etc/paths.d/*(N))(/N)

        /usr/local/bin
        /usr/bin
        /bin
      )
    fi

    path=(
      /usr/local/sbin
      /usr/sbin
      /sbin

      $HOME/bin
      $HOME/.rvm/bin
      $GOPATH/bin
      /opt/*/bin(/N)
      /usr/local/*/bin(/N)
      /usr/local/opt/*/libexec/bin(/N)
      /usr/local/share/npm/bin

      /usr/local/bin

      $(whence -p brew >/dev/null && brew --prefix coreutils)/libexec/gnubin(/N)

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

