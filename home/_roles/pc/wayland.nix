{ config, pkgs, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
in {
  # Work breaks
  services.safeeyes.enable = true;

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

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "loginctl lock-session";
        text = "Lock";
        keybind = "1";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "2";
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "Logout";
        keybind = "3";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "4";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "5";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "6";
      }
    ];
    style = ./wlogout/style.css;
  };
  xdg.configFile."wlogout/icons".source = ./wlogout/icons;

  # Utilities for wayland
  home.packages = with pkgs; [
    # Screenshotting, screen recording, etc.
    grim
    slurp
    wf-recorder
    ksnip # Screenshots + annotations

    # CLipboard control
    wl-clipboard
    cliphist # Clipboard history

    # Other
    ripdrag # drag-n-drop

    # Deprecated
    (waybar.override {
      hyprlandSupport = true;
      runTests = false;
      cavaSupport = true;
    })
  ];

  # Custom commands
  home.file.".local/bin/wfrecord".source = ./bin/wfrecord;

  xdg.configFile = {
    "waybar".source = utils.linkConfig "waybar";
  };
}
