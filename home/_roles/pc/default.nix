{ config, pkgs, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
in {
  imports = [
    ./chat.nix
    ./cli.nix
    ./desktop.nix
    ./fonts.nix
    ./git.nix
    ./mako.nix
    ./media.nix
    ./niri.nix
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
    ../../_topics/kde-connect.nix
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
  xdg.mimeApps.enable = true;
  # Desktops replace this symlink with a file sometimes,
  # which will cause HM activation to fail.
  # Tell HM it's fine to replace this file.
  xdg.configFile."mimeapps.list".force = true;
}
