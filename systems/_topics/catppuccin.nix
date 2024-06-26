{ inputs, pkgs, ... }: let
  flavor = "mocha";
  accent = "mauve";

  icons = (pkgs.catppuccin-papirus-folders.override {
    inherit flavor accent;
  });
  # You just have to know that the icon theme will be named this…
  iconTheme = "Papirus-Dark";
in {
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  environment.systemPackages = [
    icons
    pkgs.catppuccin-cursors.mochaDark
    (pkgs.catppuccin-gtk.override {
      variant = flavor;
      accents = [ accent ];
      size = "compact";
      tweaks = []; # You can also specify multiple tweaks here
    })

    # KDE is not supported by the catppuccin module, so add it manually.
    (pkgs.catppuccin-kde.override {
      flavour = [ flavor ];
      accents = [ accent ];
      winDecStyles = [ "modern" ];
    })
    (pkgs.catppuccin-kvantum.override {
      variant = "Mocha";
      accent = "Mauve";
    })
  ];

  catppuccin = {
    enable = true;
    flavor = flavor;
    accent = accent;
  };

  environment.variables = {
    ICON_THEME_NAME = iconTheme;
    XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
    XCURSOR_SIZE = "32";
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };
}
