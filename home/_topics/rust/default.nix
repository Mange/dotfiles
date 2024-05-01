{ pkgs, ... }: {
  programs.bacon = {
    enable = true;
    settings = {
      wrap = true;
      keybindings = {
        j = "scroll-lines(1)";
        k = "scroll-lines(-1)";
        Space = "scroll-pages(1)";
        b = "toggle-backtrace";
        s = "toggle-summary";
        w = "toggle-wrap";

        # Custom jobs that must be defined inside of projects.
        t = "job:nextest";
        E = "job:check-examples";
        W = "job:check-win";
      };

      jobs = {
        nextest = {
          command = ["cargo" "nextest" "run" "--color" "always"];
          need_stdout = true;
          watch = ["tests"];
        };

        "check-win" = {
          command = ["cargo" "check" "--target" "x86_64-pc-windows-gnu" "--color" "always"];
        };

        "check-examples" = {
          command = ["cargo" "check" "--examples" "--color" "always"];
          watch = ["examples"];
        };
      };
    };
  };

  home.packages = with pkgs; [
    rustup
    cargo-update
    cargo-edit
    cargo-watch
  ];
}
