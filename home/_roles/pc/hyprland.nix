{ inputs, pkgs, config, lib, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
  hy3 = inputs.hy3;
in 
{
  # tray.target is only created when X11 is enabled, so manually create it so
  # that other services can properly depend on it.
  # See https://github.com/nix-community/home-manager/issues/2064
  # systemd.user.targets.tray = {
  #   Unit = {
  #     Description = "Home Manager System Tray";
  #     Requires = [ "graphical-session-pre.target" ];
  #   };
  # };

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
      source = ./config/local.conf
    '';
  };
  # Set up symlinks for all the config files, and also create a mutable
  # `local.conf` for local config that you don't want committed to the repo.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";
  home.activation.localHyprConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
     $DRY_RUN_CMD touch $VERBOSE_ARG "''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/config/local.conf"
  '';
}
