{ pkgs, inputs, ... }: let
  flavor = "mocha";
  accent = "mauve";

  iconTheme = "Papirus-Dark";
in {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    flavor = flavor;
    accent = accent;

    pointerCursor.enable = true;
    pointerCursor.accent = "dark";
  };

  # My Neovim is not configured with home-manager directly.
  programs.neovim.catppuccin.enable = false;

  home.pointerCursor = {
    size = 32;
    gtk.enable = true;
    x11.enable = true;
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
    catppuccin.enable = false; # Use my own style instead
    theme = "catpuccin.rasi";
    extraConfig = {
      icon-theme = iconTheme;
    };
  };

  gtk.iconTheme.name = iconTheme;
}

