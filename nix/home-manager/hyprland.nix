{ inputs, pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
in 
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      source = ./config/base.conf
    '';
  };

  # Set up symlinks for all the config files.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";
}
