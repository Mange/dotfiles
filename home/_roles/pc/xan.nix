{ pkgs, lib, ... }: {
  home.packages = [pkgs.xan];

  programs.zsh.initContent = lib.mkMerge [
    # Generated through `xan completions zsh`
    (lib.mkOrder 1200 /* zsh */ ''
      # Xan completions
      autoload -Uz bashcompinit && bashcompinit
      function __xan {
        xan compgen "$1" "$2" "$3"
      }
      complete -F __xan -o default xan
    '')
  ];
}
