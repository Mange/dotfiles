{ pkgs, ... }: {
  programs.bat = {
    enable = true;
  };

  programs.dircolors = {
    enable = true;
    settings = {
      # Files that I don't have to pay attention to
      ".nfo" = "90";
      ".sfv" = "90";
      ".srt" = "90";
      ".sub" = "90";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    # Sets up aliases: `ls`, `ll`, `la`, `lla`, `lt` by default.
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--color-scale" "all"
      "--hyperlink" 
    ];
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --level 5 {} | head -200'"
    ];
  };

  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        sort_dir_first = true;
      };
    };
  };

  programs.htop = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.tmate.enable = true;
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
    prettyping
    procs

    # Basics
    file
    watchexec
    psmisc # better pstree command
    lsof
    glib # "gio trash", etc.

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
    parallel
    xan # CSV tools
    duckdb # Helpful when working with large CSV/JSON files.
  ];
}
