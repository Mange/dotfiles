{ pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
in {
  xdg.configFile."zsh".source = utils.linkConfig "zsh";

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
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

    sessionVariables = {
      KEYTIMEOUT = "1"; # 10ms delay for Escape key

      # Default:   *?_-.[]~=/&;!#$%^(){}<>
      WORDCHARS = "*?[]~&;!#$%^(){}";

      VISUAL = "nvim";

      # Default less(1) options
      # --Raw-control-chars :: Support ANSI color control chars
      # --ignore-case       :: Smart case search (Ignore-case is normal case insensitive search)
      LESS = "--Raw-control-chars --quit-if-one-screen --ignore-case";

      MANPAGER = "nvim +Man!"; # Neovim makes a better manpager than less.
      BAT_THEME = "base16";
    };

    shellAliases = {
      ls = "exa --group-directories-first";
      l = "exa --group-directories-first --long --color-scale --git";
      tree = "tree -AC -I '.svn|.git|node_modules|bower_components'";
      t = "tree -L 3 --filelimit 50";
      fusage = "ls -Ssrh"; # Sort files by size and show human readable
      copy = "xsel --clipboard --input";
      paste = "xsel --clipboard --output";
      ping = "prettyping --nolegend";
      j = "jobs -l";

      git = "hub";
      checkout = "git checkout";
      master = "git checkout master";
      gadd = "git add";
      gco = "git commit -v";
      gpu = "git push";
      gb = "git branch -v";
      gba = "git branch -va";
      gbm = "git branch -v --merged";
      gm = "git merge --no-ff";
      gmo = "git merge --no-ff @{upstream}";
      gmm = "git merge --no-ff master";
      fixup = ''gco --fixup "$(git fshow)"'';
      gro = "git rebase @{upstream}";
      grm = "git rebase master";
      gri = "git rebase -i";
      grim = "git rebase -i master";
      grio = "git rebase -i @{upstream}";
      gf = "git fetch --prune";
      ff = "git merge --ff-only";
      ffm = "git merge --ff-only master";
      ffo = "git merge --ff-only @{upstream}";
      gup = "gf && ffo";
      gl="git log --no-show-signature --graph -n 1000 --format='tformat:%C(bold blue)%h%Creset %C(bold)%s%Creset%C(auto)%d%n%C(dim white)%ad %C(nodim green)(%ar)%Creset - %an%C(yellow)%+N%n%Creset'";
      s="git status --short --branch";
      gs="git show --show-signature";
      gd="git diff";
      gds="git diff | delta --side-by-side";
      staged="gd --cached";
    };

    # Don't care about world/group writable files (`compinit -u`). It's too
    # annoying to deal with, and I don't think this is going to the *the*
    # vector that infects me.
    completionInit = "autoload -U compinit && compinit -u";

    initExtraBeforeCompInit = /* zsh */ ''
      zmodload zsh/complist
      # Use my custom completions too
      fpath=("''${XDG_CONFIG_HOME}/zsh/completion" $fpath)
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