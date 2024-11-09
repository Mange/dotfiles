{ pkgs, inputs, ... }: let
  flavor = "mocha";
  accent = "mauve";

  # Theme is created by gtk.catppuccin.icon.enable, but the name of the icon theme
  # is not exposed anywhere.
  # iconTheme = "cat-${flavor}-${accent}";
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

  gtk.catppuccin = {
    enable = true; # Deprecated, but I'm holding on for dear life…
    # This also installs the icon theme for all apps to be able to use. See
    # `iconTheme` variable.
    icon.enable = true;
  };

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

  # Set the icon theme for GTK again. Why? Because if my `iconTheme` variable
  # has a different value (i.e. is incorrect), then Nix will fail compilation
  # because Catpuccin and me are setting different values.
  # When this error happens, I can change my variable to match and things
  # should be working again!
  gtk.iconTheme.name = iconTheme;
}

