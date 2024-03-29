{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    catppuccin-cursors.mochaDark

    (catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "compact";
      tweaks = []; # You can also specify multiple tweaks here
      variant = "mocha";
    })

    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "mauve";
    })
  ];

  boot.plymouth = {
    themePackages = [
      (pkgs.catppuccin-plymouth.override {
        variant = "mocha";
      })
    ];
    theme = "catppuccin-mocha";
  };

  environment.variables = {
    ICON_THEME_NAME = "Papirus-Dark";
    XCURSOR_THEME = "Catppuccin-Mocha-Dark-Cursors";
    XCURSOR_SIZE = "32";
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };
}
