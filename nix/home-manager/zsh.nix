{ pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
in {
  xdg.configFile."zsh".source = utils.linkConfig "zsh";

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--preview '(bat --style=numbers --color=always {} || cat {} || tree -C {}) 2> /dev/null | head -200'"
    ];
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    history = { 
      path = "${config.xdg.dataHome}/zsh/history";
      share = false;
    };

    enableVteIntegration = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = ["^N"];
      searchDownKey = ["^P"];
    };
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    # Don't care about world/group writable files (`compinit -u`). It's too
    # annoying to deal with, and I don't think this is going to the *the*
    # vector that infects me.
    completionInit = "autoload -U compinit && compinit -u";

    initExtraBeforeCompInit = /* zsh */ ''
      zmodload zsh/complist
      # Use my custom completions too
      fpath=("''${XDG_CONFIG_HOME}/zsh/completion" $fpath)

      command-exist() { whence $1 > /dev/null; }

      ### fzf-tab
      zstyle ":completion:*:git-checkout:*" sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # give a preview when completing `kill`
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
      zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts '--preview=echo $(<{f})' --preview-window=down:3:wrap

      if command-exist exa; then
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
      else
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
      fi

      ### FZF stuff
      bindkey -M vicmd "/" fzf-history-widget
      bindkey "^P" fzf-file-widget
    '';

    envExtra = /* zsh */ ''
      source "''${XDG_CONFIG_HOME:-''${HOME}/.config}/shells/common"
      source "''${HOME}/.config/zsh/zshenv"
    '';

    initExtra = /* zsh */ ''
      source "''${HOME}/.config/zsh/zshrc"
    '';
  };
}
