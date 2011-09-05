# Mac OS has this retarded notion that any PATH set should be reverted when starting subshells
# Check out /etc/zshenv for yourself!
if [[ -e /etc/zshenv && -x /usr/libexec/path_helper && $(uname) == 'Darwin' ]]; then
  source ~/.zshrc.d/*-path
  source ~/.zshrc.d/*-rvm
fi
