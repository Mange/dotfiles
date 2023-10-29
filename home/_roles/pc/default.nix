{ config, pkgs, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
in {
  imports = [
    # Old
    ./shell.nix
    ./gui

    # New
    ./catppuccin.nix
    ./cli.nix
    ./git.nix
    ./security.nix
    ./timers.nix
    ./xdg.nix

    ../../_topics/fonts
    ../../_topics/neovim
    ../../_topics/ruby
    ../../_topics/toys.nix
  ];

  home.language = {
    base = "sv_SE.UTF-8";
    time = "sv_SE.UTF-8";
    collate = "sv_SE.UTF-8";
  };

  # Setup symlinks.
  home.file.".face".source = ./face.jpg;
  xdg.dataFile."wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };

  home.packages = with pkgs; [
    # Bluetooth
    bluez
    bluez-tools
    blueman

    # Network
    curl
    httpie
    nmap
    rsync

    # Other hardware
    lm_sensors

    # Modern UNIX replacements
    bat
    fd
    htop
    prettyping
    procs
    ripgrep

    # CLI
    duplicity
    file
    gnuplot
    killall
    libqalculate
    lsof
    psmisc # better pstree command
    wget

    # Dev
    gnome.zenity
    http-prompt
    jq
    nodejs
    parallel
    pastel
    pgcli
    rustup
    watchexec

    cargo-update
    cargo-edit
    cargo-watch

    # Archives
    atool
    p7zip
    unrar
    unzip
    xz
    zip

    # Gaming
    steam

    # Mobile integration
    scrcpy
    android-file-transfer

    # Media
    mediainfo
    youtube-dl
    imagemagick # for image previews, etc.
    ghostscript # imagemagick optional dependency for PDF support

    # Other
    monero
  ];

  # config/ directory
  # xdg.configFile = lib.pipe (utils.filesIn ../config) [
  #   (builtins.map (f: {
  #     "${f}".source = (utils.linkConfig f);
  #   }))
  #   (utils.mergeAttrs)
  # ];
  xdg.configFile = {
    "mako".source = utils.linkConfig "mako";
    "pgcli".source = utils.linkConfig "pgcli";
    "procs".source = utils.linkConfig "procs";
    # "rofi".source = utils.linkConfig "rofi";
    "shells".source = utils.linkConfig "shells";
    "swayidle".source = utils.linkConfig "swayidle";
    "waybar".source = utils.linkConfig "waybar";
    "xkb".source = utils.linkConfig "xkb";

    "user-dirs.dirs".source = ../../../config/user-dirs.dirs.template;
  };
}
