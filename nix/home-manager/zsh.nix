{ pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
in {
  xdg.configFile."zsh".source = utils.linkConfig "zsh";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    history.path = "${config.xdg.dataHome}/zsh/history";

    # Don't care about world/group writable files (`compinit -u`). It's too
    # annoying to deal with, and I don't think this is going to the *the*
    # vector that infects me.
    completionInit = "autoload -U compinit && compinit -u";

    initExtraBeforeCompInit = ''
      zmodload zsh/complist
      # Use my custom completions too
      fpath=("''${XDG_CONFIG_HOME}/zsh/completion" $fpath)
    '';

    envExtra = ''
      source "''${XDG_CONFIG_HOME:-''${HOME}/.config}/shells/common"
      source "''${HOME}/.config/zsh/zshenv"
    '';

    initExtra = ''
      source "''${HOME}/.config/zsh/zshrc"
    '';
  };
}
