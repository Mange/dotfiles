{
  config,
  pkgs,
  isLaptop,
  ...
}:
let
  utils = import ../../utils.nix { inherit config pkgs; };
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in
{
  xdg.configFile."niri/config.kdl".source = utils.linkConfig "niri/config.kdl";

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia-shell ipc call lockScreen lock";

        before_sleep_cmd = "loginctl lock-session; sleep 1;";
        # After waking up, sometimes the timeout listener for shutting off the
        # screens will shut them off again. Wait for that to settle…
        after_sleep_cmd = "sleep 0.5; niri msg action power-on-monitors";
      };

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
      ]
      ++ (
        if isLaptop then
          [
            {
              timeout = 1200; # 20 min
              on-timeout = "systemctl suspend-then-hibernate";
            }
          ]
        else
          [ ]
      );
    };
  };

  programs.noctalia-shell = {
    enable = true;
  };
}
