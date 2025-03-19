{ config, pkgs, isLaptop, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
in {
  xdg.configFile."niri/config.kdl".source = utils.linkConfig "niri/config.kdl";

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Avoid starting multiple instances of hyprlock.
        # Then show the startup reminder after the lock has
        # ended.
        lock_cmd = "(pidof hyprlock || ${hyprlock}); startup-reminder";

        before_sleep_cmd = "loginctl lock-session; sleep 1;";
        # After waking up, sometimes the timeout
        # listener to shut off the screens will
        # shut them off again. Wait for that to settle…
        after_sleep_cmd = "sleep 0.5; niri msg action power-on-monitors";
      } ;

      listener = [
        # Monitor power save
        {
          timeout = 720; # 12 min
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }

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
}
