{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    escapeTime = 0;
    terminal = "screen-256color";

    # start window indexing at one instead of zero, 0 and 1 is nowhere close
    baseIndex = 1;

    # I like being able to select text in the terminal window
    mouse = false;

    # I am not a fucking idiot
    clock24 = true;

    # Auto-spawn session when attaching a session that does not exist.
    newSession = true;
  };

  home.packages = with pkgs; [
    # A fast documentation searcher for Nix
    manix
  ];
}
