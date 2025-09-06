{ lib, pkgs, inputs, ... }: let
  flavor = "mocha";
  accent = "mauve";

  iconTheme = "Papirus-Dark";
in {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    inherit flavor;
    inherit accent;

    cursors.enable = true;
    cursors.accent = "dark";

    # My Neovim is not configured with home-manager directly.
    nvim.enable = false;
    # I use my own theme style instead. See below.
    rofi.enable = false;
    # Same with hyprlock.
    hyprlock.enable = false;
  };

  home.pointerCursor = {
    size = 32;
    gtk.enable = true;
    x11.enable = true;

    # Override selection made by Catppuccin module, as it will want to build
    # all flavors and all colors, which takes 10-20 minutes.
    package = lib.mkOverride 0 pkgs.catppuccin-cursors.mochaDark;
  };

  # KDE is not supported by the catppuccin module, so add it manually.

  home.packages = with pkgs; [
    (catppuccin-kde.override {
      flavour = [ flavor ];
      accents = [ accent];
      winDecStyles = [ "modern" ];
    })
    (catppuccin-kvantum.override {
      variant = "mocha";
      accent = "mauve";
    })
  ];

  qt = {
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # Link config file rather than including it in the module to make it easier
  # to adjust it.
  xdg.configFile."rofi/catpuccin.rasi".source = ./rofi/catpuccin.rasi;
  programs.rofi = {
    theme = "catpuccin.rasi";
    extraConfig = {
      icon-theme = iconTheme;
    };
  };

  gtk.iconTheme.name = iconTheme;
}

