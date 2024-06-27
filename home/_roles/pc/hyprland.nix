{ pkgs, config, lib, isLaptop, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
  playerctl = "${pkgs.playerctl}/bin/playerctl";

  # Until PR lands in nixos-unstable:
  # https://nixpk.gs/pr-tracker.html?pr=321575
  hyprland = pkgs.unstable.hyprland;
  hy3 = pkgs.unstable.hyprlandPlugins.hy3;
in 
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Avoid starting multiple instances of hyprlock.
        lock_cmd = "pidof hyprlock || ${hyprlock}";

        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";

        ignore_dbus_inhibit = false;
      } ;

      listener = [
        # Dim screen
        {
          timeout = 300; # 5 min
          on-timeout = "${brightnessctl} -s set 10";
          on-resume = "${brightnessctl} -r";
        }
        # Dim keyboard
        {
          timeout = 300; # 5 min
          on-timeout = "${brightnessctl} -sd rgb:kbd_backlight set 0";
          on-resume = "${brightnessctl} -rd rgb:kbd_backlight";
        }

        {
          timeout = 600; # 10 min
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 720; # 12 min
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ] ++ (
        if isLaptop then
          [{
            timeout = 1200; # 20 min
            on-timeout = "systemctl suspend-then-hibernate";
          }]
        else
          []
      );
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        # Allow unlocking immediately during first 5 seconds.
        grace = 5;
        pam_module = "hyprlock"; # Set up in system config
      };

      background = {
        path = "screenshot";
        blur_passes = 3;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      image = {
        path = "${./face.jpg}";
        size = 120;
        rounding = -1; # Circle
        border_size = 4;
        border_color = "rgba(255, 255, 255, 0.6)";
        position = "0, 100";
        halign = "center";
        valign = "center";
      };

      input-field = {
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(0, 0, 0, 0.5)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          font_family = "Inter";
          placeholder_text = "Enter password to unlock";
          hide_input = false;
          position = "0, -120";
          halign = "center";
          valign = "center";
      };

      label = [
        # TIME
        {
          text = "cmd[update:1000] date +\"%H:%M\"";
          color = "rgba(255, 255, 255, 0.9)";
          font_size = 100;
          font_family = "Inter Bold";
          position = "0, -300";
          halign = "center";
          valign = "top";
        }

        # USER
        {
            text = "How are you, $USER?";
            color = "rgba(255, 255, 255, 0.6)";
            font_size = 25;
            font_family = "Inter Light";
            position = "0, -40";
            halign = "center";
            valign = "center";
        }

        # CURRENT SONG
        {
            text = "cmd[update:1000] ${playerctl} metadata --format '{{title}}   {{artist}}'";
            color = "rgba(255, 255, 255, 0.6)";
            font_size = 18;
            font_family = "Inter";
            position = "0, 0";
            halign = "center";
            valign = "bottom";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland;
    plugins = [hy3];
    systemd.enable = true;

    # Systemd integration does not import all environment variables, when I
    # prefer it to import everything.
    # See https://github.com/hyprwm/Hyprland/issues/2800
    #
    # Also manually set up PATH so it works when using GDM, which does not run
    # a full shell when loading Hyprland.
    extraConfig = /*sh*/ ''
      env = PATH,$HOME/.local/bin:$PATH
      exec-once = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all";
      source = ./config/base.conf
      source = ./config/local.conf
    '';
  };
  # Set up symlinks for all the config files, and also create a mutable
  # `local.conf` for local config that you don't want committed to the repo.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";
  xdg.configFile."hypr/screens.conf".source = lib.mkDefault ( utils.linkConfig "hypr/default_screens.conf" );
  home.activation.localHyprConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
     $DRY_RUN_CMD touch $VERBOSE_ARG "''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/config/local.conf"
  '';
}
