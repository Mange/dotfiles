# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ outputs, config, pkgs, inputs, lib, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.android-nixpkgs.hmModule

    # You can also split up your configuration and import pieces of it here:

    ./xdg.nix

    ./android-dev.nix
    ./neovim.nix
    ./toys.nix

    ./shell.nix
    ./gui
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      inputs.android-nixpkgs.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "mange";
    homeDirectory = "/home/mange";
    language.base = "sv_SE.UTF-8";
    sessionVariables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh"; # gnome-keyring
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!"; # Neovim makes a better manpager than less.
      BAT_THEME = "base16";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];

    # Setup symlinks.
    file.".face".source = ./face.jpg;
    file.".local/bin" = {source = ../bin; recursive = true; };

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

      # Fonts
      (
        nerdfonts.override {
          fonts = [
            "JetBrainsMono"
            "Overpass"
            "NerdFontsSymbolsOnly"
          ];
        }
      )

      jetbrains-mono
      overpass

      noto-fonts-emoji # Emoji
      noto-fonts-extra # etc.
      dejavu_fonts
      liberation_ttf # Arial, Times New Roman, etc.
      roboto # Android
      # Eastern fonts, for Kaomoji, when opening Japanese websites, etc.
      ipafont # Japanese
      arphic-uming # Chinese
      baekmuk-ttf # Korean
      lohit-fonts.kannada # Indic; includes ಠ_ಠ

      # ancient fonts - Just because it is cool
      # https://dn-works.com/ufas/
      aegan
      aegyptus
      symbola
      unidings
      eemusic
      textfonts
      assyrian
      akkadian
      maya
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

    "locale.conf".source = ../config/locale.conf;
    "user-dirs.dirs".source = ../config/user-dirs.dirs.template;
  };

  xdg.dataFile = lib.pipe (utils.filesIn ../data) [
    (builtins.map (f: {
      "${f}" = { source = ../data/. + ("/" + f); recursive = true; };
    }))
    (utils.mergeAttrs)
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Environment variables
  systemd.user.sessionVariables = {
    # To allow gem mimemagic to be installed.
    # https://github.com/mimemagicrb/mimemagic/issues/160
    # https://github.com/mimemagicrb/mimemagic/pull/163
    FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  };

  programs.home-manager.enable = true;

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

  fonts.fontconfig.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
