{ pkgs, ... }: {
  programs.tmux.plugins = [ pkgs.tmuxPlugins.catppuccin ];

  xdg.configFile."rofi/catpuccin.rasi".source = ./rofi/catpuccin.rasi;
  programs.rofi = {
    theme = "catpuccin.rasi";
    extraConfig = {
      icon-theme = "Papirus-Dark";
    };
  };

  programs.zathura = {
    extraConfig = builtins.readFile ./zathura-catppuccin-mocha;
  };

  home.packages = with pkgs; [
    gsettings-desktop-schemas

    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
      winDecStyles = [ "modern" ];
    })

    (catppuccin-kvantum.override {
      variant = "Mocha";
      accent = "Mauve";
    })
  ];

  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 32;

    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    theme = {
      name = "Catppuccin-Mocha-Compact-Mauve-Dark";
      package = (pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "compact";
        tweaks = []; # You can also specify multiple tweaks here
        variant = "mocha";
      });
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = (pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      });
    };
  };

  qt = {
    platformTheme = "kde";
    style.name = "kvantum";
  };
}

