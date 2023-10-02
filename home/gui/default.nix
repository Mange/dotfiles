{ inputs, pkgs, config, ... }: let
  utils = import ../utils.nix { inherit config pkgs; };
  hy3 = inputs.hy3;
in 
{
  imports = [
    ./rofi.nix
  ];

  # tray.target is only created when X11 is enabled, so manually create it so
  # that other services can properly depend on it.
  # See https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

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
  # Set up symlinks for all the config files.
  xdg.configFile."hypr/config".source = utils.linkConfig "hypr/config";

  # Work breaks
  services.safeeyes.enable = true;

  # Device manager
  services.udiskie = {
    enable = true;
    automount = false;
    tray = "auto"; # Smart tray icon; only show when a device is connected
  };

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

  # PDF and comics
  programs.zathura = {
    enable = true;
    extraConfig = ''
      include catppuccin-mocha
    '';
  };
  xdg.configFile."zathura/catppuccin-mocha".source = ./zathura/catppuccin-mocha;

  # Keybase
  services.kbfs.enable = true;
  services.keybase.enable = true;

  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

  # GUI-based utilities
  home.file.".local/bin/wfrecord".source = ./bin/wfrecord;

  # Other configs
  xdg.configFile."wezterm" = {
    source = ./wezterm;
    recursive = true;
  };

  # Other packages
  home.packages = with pkgs; [
    # Browsers
    brave
    firefox
    google-chrome

    # Media
    cava # Music visualizer
    jellyfin-media-player
    krita
    mpv
    pavucontrol # Volume control
    playerctl # MPRIS control
    pulsemixer
    shotwell

    # Chat and comms
    slack
    spotify
    telegram-desktop

    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })

    # Other apps
    ksnip # Screenshots + annotations
    obsidian
    ripdrag # drag-n-drop
    transmission-remote-gtk
    wezterm
    yubikey-manager
    yubikey-manager-qt

    # Screenshotting, screen recording, etc.
    grim
    slurp
    wf-recorder

    # Utils / libraries / daemons / theme support
    cliphist # Clipboard history
    libnotify
    mako # Notifications
    swayidle # Trigger stuff when idle
    swaylock-effects # Lockscreen
    swww # Wallpaper
    udiskie # to get access to CLI tools not enabled through services.udiskie
    wl-clipboard # Clipboard control
    xdg-utils

    (waybar.override {
      hyprlandSupport = true;
      runTests = false;
      cavaSupport = true;
    })

    # Themes
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
      size = 32;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "kvantum";
  };

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";

      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/mailto" = "brave-browser.desktop";
      "x-scheme-handler/webcal" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";

      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";

      "video/mp4" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";

      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/vnd.comicbook+zip" = "org.pwmt.zathura-djvu.desktop";
    };
  };
}
