handle-failure() {
  echo ${red}Command failed!${reset}
  echo "Continue? [Yn]"
  read -r answer
  if [[ $answer != "" && $answer != "y" && $answer != "Y" ]]; then
    echo "Aborting"
    exit 1
  fi
}

install-fzf() {
  if [[ ! -d ~/.fzf ]]; then
    header "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
  fi
}
