{ inputs, pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
  hy3 = inputs.hy3;
in 
{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [hy3.packages.x86_64-linux.hy3];

    # The automatic systemd integration does not load PATH and some other
    # variables I want, so I manually replace it below.
    # See https://github.com/hyprwm/Hyprland/issues/2800
    systemdIntegration = false;

    # Combined settings will be:
    #  1. SystemD integration
    #  2. Plugins
    #  3. `extraConfig`
    extraConfig = ''
      env = PATH,$HOME/.local/bin:$PATH
      exec-once = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all";
      source = ./config/base.conf
    '';
  };

  # Set up symlinks for all the config files.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";

  home.packages = with pkgs; [
    cava # Music visualizer
    grim # Screenshot tool
    ksnip # Screenshots + annotations
    mako # Notifications
    pavucontrol # Volume control
    playerctl # MPRIS control
    rsibreak # Work breaks
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
      name = "Catppuccino-Mocha-Dark-Cursors";
    };
  };
}
