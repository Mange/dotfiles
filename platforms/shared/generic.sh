install-fzf() {
  if [[ ! -d ~/.fzf ]]; then
    header "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
  fi
}
