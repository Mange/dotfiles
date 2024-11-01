{ pkgs, ... }: {
  home.packages = with pkgs; [
    git-absorb

    github-cli
    hub # mostly for `git sync`; I should migrate away

    delta
    difftastic
    tig
  ];

  home.shellAliases = {
    git = "hub";
    checkout = "git checkout";
    master = "git checkout master";
    gco = "git commit -v";
    gpu = "git push";
    gb = "git branch -v";
    gba = "git branch -va";
    gbm = "git branch -v --merged";
    gm = "git merge --no-ff";
    gmo = "git merge --no-ff @{upstream}";
    gmm = "git merge --no-ff master";
    fixup = /*sh*/ ''gco --fixup "$(git fshow)"'';
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
    gs="git show --show-signature --ext-diff";
    gd="git diff --ext-diff";
    gdd="git diff --no-ext-diff | delta";
    gds="git diff --no-ext-diff | delta --side-by-side";
    staged="gd --cached";
  };

  programs.git = {
    enable = true;

    userName = "Magnus Bergmark";
    userEmail = "me@mange.dev";

    difftastic = {
      enable = true;
      background = "dark";
    };

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

      # Note: `diff.external` is set up using `difftastic.enable` above.
      diff.tool = "vimdiff";

      rerere.enabled = true;

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

      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
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

      #-- Lsp junk --
      ".ccls-cache/"
    ];
  };
}
