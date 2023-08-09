{ inputs, pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
  hy3 = inputs.hy3;
in 
{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [hy3.packages.x86_64-linux.hy3];
    extraConfig = ''
      source = ./config/base.conf
    '';
  };

  # Set up symlinks for all the config files.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";

  home.packages = with pkgs; [
    bibata-cursors # Cursor theme
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
  ];
}
