{ inputs, pkgs, ... }: let
  flavor = "mocha";
  accent = "mauve";

  icons = pkgs.catppuccin-papirus-folders.override {
    inherit flavor accent;
  };
  # You just have to know that the icon theme will be named this…
  iconTheme = "Papirus-Dark";
in {
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  environment.systemPackages = [
    icons
    pkgs.catppuccin-cursors.mochaDark

    # KDE is not supported by the catppuccin module, so add it manually.
    (pkgs.catppuccin-kde.override {
      flavour = [ flavor ];
      accents = [ accent ];
      winDecStyles = [ "modern" ];
    })
    (pkgs.catppuccin-kvantum.override {
      variant = "mocha";
      accent = "mauve";
    })
  ];

  catppuccin = {
    enable = true;
    inherit flavor;
    inherit accent;
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

  # Make SVG icons work in wlogout stylesheet.
  # https://github.com/ArtsyMacaw/wlogout/issues/61#issuecomment-2457317617
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
}
