{ pkgs, ... }: {
  home.packages = with pkgs; [
    delta
    git-absorb
    github-cli
    hub # mostly for `git sync`; I should migrate away
  ];

  programs.git = {
    enable = true;

    userName = "Magnus Bergmark";
    userEmail = "me@mange.dev";

    aliases = {
      prune = "!git remote | xargs -n 1 git remote prune";
    };

    signing = {
      signByDefault = true;
      key = "2EA6F4AA110A1BF2227519A90443C69F6F022CDE";
    };

    extraConfig = {
      github.user = "Mange";

      # Newspeak is double-plus ungood
      init.defaultBranch = "master";

      mergetool = {
        prompt = true;
        keepBackup = false;
        vimdiff = {
          cmd = /*sh*/ ''nvim -d "$LOCAL" "$BASE" "$REMOTE" "$MERGED" -c "\$wincmd w" -c "wincmd J" -c "windo set wrap"'';
        };
      };

      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };

      diff.tool = "vimdiff";

      rebase = {
        autosquash = true;
        stat = true;
      };

      log = {
        showSignature = false;
        date = "format:%Y-%m-%d %H:%M";
      };

      color.branch = {
        remote = "blue";
        current = "bold green";
        local = "green";
      };
    };

    ignores = [
      #-- Vim doc tags --
      "doc/tags"

      #-- Crap and metadata --
      ".DS_Store"
      "?*~"

      #-- Project-specific things --
      ".*.local"
      "notes.local"
      ".ruby-gemset"

      #-- Editor-specific things --
      "*.swp"
      ".vimrc"
      ".nvimrc"
      ".nvim.lua"
      ".*.rs.rustfmt"
      ".#*"

      #-- direnv --
      ".envrc"
      ".direnv"
    ];

    delta = {
      enable = true;
    };
  };
}
