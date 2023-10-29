{ config, pkgs, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
in {
  imports = [
    ./chat.nix
    ./cli.nix
    ./fonts.nix
    ./git.nix
    ./hyprland.nix
    ./mako.nix
    ./media.nix
    ./rofi.nix
    ./security.nix
    ./syncthing.nix
    ./timers.nix
    ./udiskie.nix
    ./wallpapers.nix
    ./wayland.nix
    ./wezterm.nix
    ./xdg.nix
    ./zathura.nix
    ./zsh.nix

    ../../_topics/catppuccin
    ../../_topics/neovim
    ../../_topics/ruby
    ../../_topics/rust
    ../../_topics/toys.nix
    ../../_topics/webdev
  ];

  home.language = {
    base = "sv_SE.UTF-8";
    time = "sv_SE.UTF-8";
    collate = "sv_SE.UTF-8";
  };

  # Setup symlinks.
  home.file.".face".source = ./face.jpg;

  gtk.enable = true;
  qt.enable = true;

  home.packages = with pkgs; [
    # Standard computing
    brave
    firefox
    shotwell
    obsidian
    transmission-remote-gtk
    pavucontrol # Volume control
    xdg-utils

    # Mobile integration
    scrcpy
    android-file-transfer

    # Media
    imagemagick # for image previews, etc.
    ghostscript # imagemagick optional dependency for PDF support

    # Misc
    gnome.zenity
    gnuplot
    libqalculate
  ];

  # config/ directory
  # xdg.configFile = lib.pipe (utils.filesIn ../config) [
  #   (builtins.map (f: {
  #     "${f}".source = (utils.linkConfig f);
  #   }))
  #   (utils.mergeAttrs)
  # ];
  xdg.configFile = {
    "procs".source = utils.linkConfig "procs";
    "shells".source = utils.linkConfig "shells";
    "xkb".source = utils.linkConfig "xkb";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Media/Music";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Documents/Templates";
    videos = "${config.home.homeDirectory}/Media/Videos";
  };

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Thunar as my default GUI file manager
      "inode/directory" = "thunar.desktop";

      # Brave as my default browser
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/mailto" = "brave-browser.desktop";
      "x-scheme-handler/webcal" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };
}
