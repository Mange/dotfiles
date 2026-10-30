{ lib, config, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Magnus Bergmark";
        email = "me@mange.dev";
      };

      signing = {
        # Drop signatures by default. Signing happens at push time.
        # (git.sign-on-push)
        behavior = "drop";
        backend = "gpg";
      };

      git = {
        sign-on-push = true;
        colocate = false;
        private-commits = "description('wip:*') | description('private:*')";
      };

      merge-tools.difftastic = {
        program = "difft";
        diff-args = [
          "--color=always"
          "$left"
          "$right"
        ];
      };

      ui = {
        default-command = "log";
        diff-formatter = lib.mkIf config.programs.difftastic.enable "difftastic";
        # Might be slow to always do…
        # show-cryptographic-signatures = true;
        editor = [
          "nvim"
          "+$line"
        ];
      };

      revsets = {
        # Basically: By default advance bookmarks to @, unless it's empty, in
        # which case advance to @-.
        bookmark-advance-to = "closest_pushable(@)";
      };

      revset-aliases = {
        # Closest revision that is mutable, described and either non-empty or a merge
        "closest_pushable(to)" = ''
          heads(::to & mutable() & ~description(exact:"") & (~empty() | merges()))
        '';
      };

      templates = {
        draft_commit_description = ''
          concat(
            builtin_draft_commit_description,
            indent("JJ: ", diff.git()),
          )
        '';
      };
    };
  };

  programs.jjui = {
    enable = true;
    settings = {
      actions = [
        {
          name = "arrange";
          lua = ''jj_interactive("arrange", "-r", jjui.revisions.current() .. "::")'';
          key = "alt+a";
          scope = "revisions";
          desc = "arrange";
        }
      ];
    };
  };
}
