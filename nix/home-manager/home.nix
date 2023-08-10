# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ outputs, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./hyprland.nix
    ./rofi.nix
    ./zsh.nix
    ./neovim.nix
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
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  # programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Environment variables
  systemd.user.sessionVariables = {
  };

  # Keyring, SSH, GPG stuff
  services.gnome-keyring.enable = true;
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
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    pinentryFlavor = "tty";
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

    # Modern UNIX replacements
    bat
    exa
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
    pulsemixer
    tmux
    tree
    wget

    # Dev
    delta
    git
    github-cli
    hub
    jq
    nodejs
    parallel
    pastel
    ruby
    watchexec

    # GUI
    brave
    firefox
    google-chrome
    libnotify
    obsidian
    slack
    spotify
    telegram-desktop
    wezterm
    xdg-utils

    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })

    # Archives
    atool
    p7zip
    unrar
    unzip
    xz
    zip

    # Gaming
    steam

    # Toys
    dotacat
    figlet

    # Media
    mediainfo
    youtube-dl
    imagemagick
    ghostscript

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

  fonts.fontconfig.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
