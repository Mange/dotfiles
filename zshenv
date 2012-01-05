# Mac OS has this retarded notion that any PATH set should be reverted when starting subshells
# Check out /etc/zshenv for yourself!
if [[ -e /etc/zshenv && $(uname) == 'Darwin' ]] && grep --quiet -e "/usr/libexec/path_helper" /etc/zshenv; then
  echo "================"
  echo "Warning: /etc/zshenv present; this will cause trouble with RVM! Recommending a swift"
  echo "  sudo mv /etc/zshenv /etc/zshprofile"
  echo "================"
  source ~/.zshrc.d/*-path
fi
