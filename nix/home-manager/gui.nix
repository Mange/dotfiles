{ inputs, pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
  hy3 = inputs.hy3;
in 
{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [hy3.packages.x86_64-linux.hy3];
    systemdIntegration = true;

    # Systemd integration does not import all environment variables, when I
    # prefer it to import everything.
    # See https://github.com/hyprwm/Hyprland/issues/2800
    #
    # Also manually set up PATH so it works when using GDM, which does not run
    # a full shell when loading Hyprland.
    extraConfig = ''
      env = PATH,$HOME/.local/bin:$PATH
      exec-once = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all";
      source = ./config/base.conf
    '';
  };

  # Work breaks
  services.safeeyes.enable = true;

  # Set up symlinks for all the config files.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";

  # Night light
  services.gammastep = {
    enable = true;
    tray = true;
    temperature.night = 3600;
    settings = {
      general = {
        adjustment-method = "wayland";
      };
    };
    # Sweden/Stockholm
    provider = "manual";
    latitude = 59.3;
    longitude = 17.8;
  };

  # Other packages
  home.packages = with pkgs; [
    cava # Music visualizer
    grim # Screenshot tool
    ksnip # Screenshots + annotations
    mako # Notifications
    pavucontrol # Volume control
    playerctl # MPRIS control
    slurp # Screenshot tool
    swayidle # Trigger stuff when idle
    swaylock-effects # Lockscreen
    swww # Wallpaper
    udiskie # Device manager
    wl-clipboard # Clipboard

    (waybar.override {
      hyprlandSupport = true;
      runTests = false;
      cavaSupport = true;
    })

    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
      winDecStyles = [ "modern" ];
    })
  ];

  gtk = {
    enable = true;
    font = {
      name = "Overpass";
      size = 12;
      package = pkgs.overpass;
    };
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
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "Catppuccin-Mocha-Dark-Cursors";
    };
  };
}
