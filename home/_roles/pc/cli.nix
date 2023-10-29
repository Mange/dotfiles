{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    # Sets up aliases: `ls`, `ll`, `la`, `lla`, `lt`.
    enableAliases = true;
    icons = true;
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--hyperlink" 
      "--color-scale"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
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
    # Modern UNIX replacements
    bat
    fd
    htop
    prettyping
    procs
    ripgrep

    # Basics
    file
    watchexec
    psmisc # better pstree command
    lsof

    # Network tools
    curl
    nmap
    rsync
    wget

    # Hardware commands
    lm_sensors

    # Archive commands and support
    atool
    p7zip
    unrar
    unzip
    xz
    zip

    # Misc development
    manix # A fast documentation searcher for Nix
    tmate # Pair-programming through tmux
    parallel
  ];
}
