{ config, pkgs, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
in {
  imports = [
    ./xdg.nix

    ./shell.nix
    ./gui

    ../../_topics/fonts
    ../../_topics/neovim
    ../../_topics/toys.nix
  ];

  home = {
    language.base = "sv_SE.UTF-8";
    sessionVariables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh"; # gnome-keyring
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!"; # Neovim makes a better manpager than less.
      BAT_THEME = "base16";
    };

    # Setup symlinks.
    file.".face".source = ./face.jpg;

    packages = with pkgs; [
      # Building software common dependencies
      shared-mime-info

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
      glib # for "gio trash", etc.
      gnuplot
      killall
      libqalculate
      lsof
      psmisc # better pstree command
      tmux
      wget

      # Dev
      delta
      git
      git-absorb
      github-cli
      gnome.zenity
      http-prompt
      hub
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
  };

  # config/ directory
  # xdg.configFile = lib.pipe (utils.filesIn ../config) [
  #   (builtins.map (f: {
  #     "${f}".source = (utils.linkConfig f);
  #   }))
  #   (utils.mergeAttrs)
  # ];
  xdg.configFile = {
    "git".source = utils.linkConfig "git";
    "mako".source = utils.linkConfig "mako";
    "pgcli".source = utils.linkConfig "pgcli";
    "procs".source = utils.linkConfig "procs";
    # "rofi".source = utils.linkConfig "rofi";
    "rspec".source = utils.linkConfig "rspec";
    "ruby".source = utils.linkConfig "ruby";
    "shells".source = utils.linkConfig "shells";
    "swayidle".source = utils.linkConfig "swayidle";
    "tmux".source = utils.linkConfig "tmux";
    "waybar".source = utils.linkConfig "waybar";
    "xkb".source = utils.linkConfig "xkb";

    "locale.conf".source = ../../../config/locale.conf;
    "user-dirs.dirs".source = ../../../config/user-dirs.dirs.template;
  };

  xdg.dataFile."wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };

  # Environment variables
  systemd.user.sessionVariables = {
    # To allow gem mimemagic to be installed.
    # https://github.com/mimemagicrb/mimemagic/issues/160
    # https://github.com/mimemagicrb/mimemagic/pull/163
    FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  };

  # Keyring, SSH, GPG stuff
  # (Keybase is set up in GUI)
  services.gnome-keyring.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    settings = {
      keyserver = "hkp://keys.gnupg.net";
      use-agent = true;
      keyserver-options = "auto-key-retrieve";
      default-key = "DB2D6BB84D8E0309";
    };
  };
}
