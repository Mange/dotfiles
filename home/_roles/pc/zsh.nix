{
  pkgs,
  config,
  lib,
  ...
}:
let
  utils = import ../../utils.nix { inherit config pkgs; };
in
{
  programs.zsh.dotDir = "${config.xdg.configHome}/zsh";
  xdg.configFile."zsh".source = utils.linkConfig "zsh";

  programs = {
    dircolors.enableZshIntegration = true;
    direnv.enableZshIntegration = true;
    fzf.enableZshIntegration = true;
    yazi.enableZshIntegration = true;

    # Wezterm is not configured through home-manager. See wezterm.nix.
    # wezterm.enableZshIntegration = true;

    zsh = {
      enable = true;
      defaultKeymap = "viins";
      history = {
        path = "${config.xdg.dataHome}/zsh/history";
        append = true;
        expireDuplicatesFirst = true;
        extended = true;
        ignoreAllDups = true;
        share = false;
        ignoreSpace = true;
        save = 20000;
      };

      enableVteIntegration = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      historySubstringSearch = {
        enable = true;
        searchUpKey = [ "^N" ];
        searchDownKey = [ "^P" ];
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

        # Default less(1) options
        # --Raw-control-chars :: Support ANSI color control chars
        # --ignore-case       :: Smart case search (Ignore-case is normal case insensitive search)
        LESS = "--Raw-control-chars --quit-if-one-screen --ignore-case";
      };

      shellAliases = {
        l = "ll"; # Set up by eza aliases.
        t = "lt --level=3"; # Set up by eza aliases.
        tree = "lt"; # Set up by eza aliases.

        ping = "prettyping --nolegend";
        j = "jobs -l";

        # Look for store path of some package. Autocomplete works in ZSH.
        nix-locate = "nix-build --no-out-link '<nixpkgs>' -A";

        wer = "watchexec --debounce 500 -c -e rb,yml,erb --no-shell --";
      };

      completionInit = "recomp";

      initContent = lib.mkMerge [
        (lib.mkOrder 550 /* zsh */ ''
          zmodload zsh/complist
          autoload -U compinit add-zsh-hook

          function recomp() {
            fpath+=(
              "''${XDG_CONFIG_HOME}/zsh/funcs"
              "''${XDG_CONFIG_HOME}/zsh/completion"

              # Auto-discover ZSH directories from used Nix packages (like nix-shell,
              # flakes, etc.)
              ''${^''${(M)path:#/nix/store/*}}/../share/zsh/{site-functions,$ZSH_VERSION/functions,vendor-completions}(N-/)
              ''${^''${(z)NIX_PROFILES}}/share/zsh/{site-functions,$ZSH_VERSION/functions,vendor-completions}(N-/)
            )
            # Don't care about world/group writable files (`compinit -u`). It's too
            # annoying to deal with, and I don't think this is going to be *the*
            # vector that infects me.
            compinit -u
          }

          local _auto_recomp_xdg_data_dirs="$XDG_DATA_DIRS"
          function _auto_recomp() {
            if [[ "$_auto_recomp_xdg_data_dirs" != "$XDG_DATA_DIRS" ]]; then
              _auto_recomp_xdg_data_dirs="$XDG_DATA_DIRS"
              recomp
            fi
          }

          add-zsh-hook precmd recomp
        '')
        # Note: 1000 is default, so that is where most other generic Nix configs
        # will insert things.
        (lib.mkOrder 1100 /* zsh */ ''
          source "''${HOME}/.config/zsh/zshrc"
        '')
        # This should try to be inserted last
        (lib.mkOrder 9999 /* zsh */ ''
          # Claude code captures all my aliases, which really causes issues for the AI as
          # it assumes commands are like their normal selves. Especially problematic with
          # my "ls" alias for `eza`, which fails to run in some cases. See:
          # https://github.com/eza-community/eza/issues/1725
          #
          # Why not skipping to define aliases inside this mode? Well, because nix is
          # setting up my aliases and it doesn't wrap them in a conditional as they are
          # added to the zshrc file, which IS NOT SUPPOSED TO BE USED IN NON-INTERACTIVE
          # SHELLS. Claude DGAF and sources it anyway.
          if [[ -n "$CLAUDECODE" ]]; then
            unalias -a
          fi

          # Chain with true to avoid $? being false
          [ -f "''${XDG_CONFIG_HOME}/zsh/zshrc.after.local" ] && source "''${XDG_CONFIG_HOME}/zsh/zshrc.after.local" || true
        '')
      ];

      envExtra = /* zsh */ ''
        source "''${XDG_CONFIG_HOME:-''${HOME}/.config}/shells/common"
      '';
    };
  };
}
